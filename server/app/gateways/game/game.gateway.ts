/* eslint-disable no-case-declarations */
/* eslint-disable @typescript-eslint/no-unused-expressions */
/* eslint-disable no-unused-expressions */
/* eslint-disable no-underscore-dangle */
/* eslint-disable max-params */
import { AccountManagerService } from '@app/services/account-manager/account-manager.service';
import { GameService } from '@app/services/game/game.service';
import { MessageManagerService } from '@app/services/message-manager/message-manager.service';
import { RoomsManagerService } from '@app/services/rooms-manager/rooms-manager.service';
import { NOT_FOUND } from '@common/constants';
import { ChannelEvents, GameEvents, GameModes, GameState, MessageTag } from '@common/enums';
import { Chat, Coordinate, Game } from '@common/game-interfaces';
import { Injectable, Logger } from '@nestjs/common';
import { ConnectedSocket, MessageBody, OnGatewayConnection, SubscribeMessage, WebSocketGateway, WebSocketServer } from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { DELAY_BEFORE_EMITTING_TIME } from './game.gateway.constants';

@WebSocketGateway({
    namespace: '/game',
})
@Injectable()
export class GameGateway implements OnGatewayConnection {
    @WebSocketServer() private server: Server;
    games = new Map<string, Game>();
    timers = new Map<string, NodeJS.Timeout>();

    constructor(
        private readonly logger: Logger,
        private readonly accountManager: AccountManagerService,
        private readonly gameService: GameService,
        private readonly roomsManager: RoomsManagerService,
        private readonly messageManager: MessageManagerService,
    ) {}

    // ------------------ CLASSIC MODE && LIMITED MODE ------------------
    @SubscribeMessage(GameEvents.StartGame)
    async startGame(@ConnectedSocket() socket: Socket, @MessageBody() lobbyId: string) {
        socket.data.state = GameState.InGame;
        socket.join(lobbyId);

        // Pour démarrer tout le monde en même temps
        if (Array.from(await this.server.in(lobbyId).fetchSockets()).length === this.roomsManager.lobbies.get(lobbyId).players.length) {
            if (this.roomsManager.lobbies.get(lobbyId).mode === GameModes.Classic) {
                await this.gameService.getGameById(this.roomsManager.lobbies.get(lobbyId).gameId).then((game) => {
                    // Mettre une copie de game(db) vers game(game) et l'identifier par le lobbyId
                    const clonedGame: Game = structuredClone({
                        lobbyId,
                        name: game.name,
                        original: game.originalImage,
                        modified: game.modifiedImage,
                        gameId: game._id,
                        differences: JSON.parse(game.differences) as Coordinate[][],
                        nDifferences: JSON.parse(game.differences).length,
                    });
                    this.games.set(lobbyId, clonedGame);
                });
                // Cheat differences is cheat enabled
                this.server.to(lobbyId).emit(GameEvents.StartGame, this.roomsManager.lobbies.get(lobbyId));
                this.logger.log(`Game started in lobby -> ${lobbyId}`);
            } else if (this.roomsManager.lobbies.get(lobbyId).mode === GameModes.Limited) {
                // Start Limited Mode
                // const allGameIds : string[] = this.gameService.get
                this.logger.error('Not implemented yet, sorry... 😭');
            }
            // Set timer indivually for each lobby
            const timerId = setInterval(() => {
                if (!this.roomsManager.lobbies.get(lobbyId)) {
                    clearInterval(timerId);
                    this.timers.delete(lobbyId);
                    return;
                }
                if (this.roomsManager.lobbies.get(lobbyId).time <= 0) {
                    this.server.to(lobbyId).emit(GameEvents.EndGame, 'Temps écoulé !');
                    clearInterval(timerId);
                    return;
                }
                this.roomsManager.lobbies.get(lobbyId).time -= 1;
                this.server.to(lobbyId).emit(GameEvents.TimerUpdate, this.roomsManager.lobbies.get(lobbyId).time);
            }, DELAY_BEFORE_EMITTING_TIME);
            this.timers.set(lobbyId, timerId);
        }
    }

    @SubscribeMessage(GameEvents.Clic)
    clic(@ConnectedSocket() socket: Socket, @MessageBody('lobbyId') lobbyId: string, @MessageBody('coordClic') coordClic: Coordinate) {
        this.logger.warn('Clic happened in lobby ' + lobbyId);
        const index: number = this.games
            .get(lobbyId)
            .differences.findIndex((difference) => difference.some((coord: Coordinate) => coord.x === coordClic.x && coord.y === coordClic.y));
        const commonMessage =
            index !== NOT_FOUND
                ? `${this.accountManager.connectedUsers.get(socket.data.accountId).credentials.username}, 'a trouvé une différence !`
                : `${this.accountManager.connectedUsers.get(socket.data.accountId).credentials.username}, 's'est trompé !`;

        if (this.roomsManager.lobbies.get(lobbyId).mode === GameModes.Classic) {
            // Si trouvé
            if (index !== NOT_FOUND) {
                // Update tout correctement
                this.roomsManager.lobbies.get(lobbyId).players.find((player) => player.accountId === socket.data.accountId).count++;
                const difference = this.games.get(lobbyId).differences.splice(index, 1);
                const remainingDifferences: Coordinate[][] = this.games.get(lobbyId).differences;
                // Vérifier s'il reste des differences
                if (this.games.get(lobbyId).differences.length <= 0) {
                    this.server.to(lobbyId).emit(GameEvents.EndGame);
                    this.server.to(lobbyId).emit(ChannelEvents.GameMessage, {
                        raw: 'MATCH NUL',
                        tag: MessageTag.Common,
                    } as Chat);
                }
                // Vérifier si un seuil est atteint pour un joueur
                const { isGameFinished, potentialWinner } = this.thresholdCheck(lobbyId);
                if (isGameFinished && potentialWinner) {
                    this.server.to(lobbyId).emit(GameEvents.EndGame);
                    this.server.to(lobbyId).emit(ChannelEvents.GameMessage, {
                        raw: `${this.accountManager.connectedUsers.get(potentialWinner.accountId).credentials.username} a gagné !`,
                        tag: MessageTag.Common,
                    } as Chat);
                }
                this.server.to(lobbyId).emit(GameEvents.Found, {
                    lobby: this.roomsManager.lobbies.get(lobbyId),
                    difference,
                });
                this.roomsManager.lobbies.get(lobbyId).isCheatEnabled ? this.server.to(lobbyId).emit(GameEvents.Cheat, remainingDifferences) : null;
                this.server.to(lobbyId).emit(ChannelEvents.GameMessage, { raw: commonMessage, tag: MessageTag.Common } as Chat);
                return;
            }
            // Si pas trouvé
            this.server.to(lobbyId).emit(ChannelEvents.GameMessage, { raw: commonMessage, tag: MessageTag.Common } as Chat);
            socket.emit(GameEvents.NotFound, coordClic);
        } else if (this.roomsManager.lobbies.get(lobbyId).mode === GameModes.Limited) {
            // Limited Mode
            this.logger.error('Not implemented yet, sorry... 😭');
        }
    }

    @SubscribeMessage(GameEvents.AbandonGame)
    abandonGame(@ConnectedSocket() socket: Socket, @MessageBody() lobbyId: string) {
        socket.data.state = GameState.Abandoned;
        socket.leave(lobbyId);
        if (this.roomsManager.lobbies.get(lobbyId).players.length <= 1) {
            this.server.to(lobbyId).emit(GameEvents.EndGame, 'Abandon');
            clearInterval(this.timers.get(lobbyId));
        }
        this.logger.log(`Game abandoned in lobby ${lobbyId}`);
    }

    @SubscribeMessage(GameEvents.NextGame)
    nextGame(@ConnectedSocket() socket: Socket, @MessageBody() lobbyId: string) {}

    @SubscribeMessage(ChannelEvents.SendGameMessage)
    handleGameMessage(@ConnectedSocket() socket: Socket, @MessageBody('lobbyId') lobbyId: string, @MessageBody('message') message: string) {
        const chat: Chat = this.messageManager.createMessage(
            this.accountManager.connectedUsers.get(socket.data.accountId).credentials.username,
            message,
        );

        socket.emit(ChannelEvents.GameMessage, { ...chat, tag: MessageTag.Sent });
        socket.broadcast.to(lobbyId).emit(ChannelEvents.GameMessage, { ...chat, tag: MessageTag.Received });
    }

    handleConnection(@ConnectedSocket() socket: Socket) {
        socket.data.accountId = socket.handshake.query.id as string;

        socket.on('disconnecting', () => {
            switch (socket.data.state) {
                case GameState.InGame:
                    const lobbyId: string = Array.from(socket.rooms)[1] as string;
                    if (this.roomsManager.lobbies.get(lobbyId).players.length <= 1) {
                        this.server.to(lobbyId).emit(GameEvents.EndGame, 'Abandon');
                        clearInterval(this.timers.get(lobbyId));
                    }
                    break;
                case GameState.Abandoned:
                    break;
                case GameState.Left:
                    break;
                default:
                    break;
            }
            this.logger.log(`LOBBY OUT de ${socket.data.accountId}`);
        });
        this.logger.log(`GAME ON de ${socket.data.accountId}`);
    }

    private thresholdCheck(lobbyId: string) {
        const leftDifferences = this.games.get(lobbyId).differences.length;
        let potentialWinner = null;
        let isGameFinished = false;

        const highestCurrentScore = Math.max(...this.roomsManager.lobbies.get(lobbyId).players.map((p) => p.count));

        for (const player of this.roomsManager.lobbies.get(lobbyId).players) {
            const maxPossibleScoreForOtherPlayers: number[] = this.roomsManager.lobbies
                .get(lobbyId)
                .players.filter((p) => p.accountId !== player.accountId)
                .map((p) => p.count + leftDifferences);

            const canAnyOtherPlayerCatchUp: boolean = maxPossibleScoreForOtherPlayers.some((score) => score >= player.count);

            if (!canAnyOtherPlayerCatchUp && player.count === highestCurrentScore) {
                potentialWinner = player;
                isGameFinished = true;
                break;
            }
        }
        return { isGameFinished, potentialWinner };
    }
}
