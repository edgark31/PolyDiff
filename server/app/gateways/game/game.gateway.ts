/* eslint-disable no-case-declarations */
/* eslint-disable @typescript-eslint/no-unused-expressions */
/* eslint-disable no-unused-expressions */
/* eslint-disable no-underscore-dangle */
/* eslint-disable max-params */
import { AccountManagerService } from '@app/services/account-manager/account-manager.service';
import { GameService } from '@app/services/game/game.service';
import { ImageManagerService } from '@app/services/image-manager/image-manager.service';
import { MessageManagerService } from '@app/services/message-manager/message-manager.service';
import { RoomsManagerService } from '@app/services/rooms-manager/rooms-manager.service';
import { NOT_FOUND } from '@common/constants';
import { ChannelEvents, GameEvents, GameModes, GameState, MessageTag } from '@common/enums';
import { Chat, ChatLog, Coordinate, Game } from '@common/game-interfaces';
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
        private readonly imageManager: ImageManagerService,
    ) {}

    // ------------------ CLASSIC MODE && LIMITED MODE ------------------
    @SubscribeMessage(GameEvents.StartGame)
    async startGame(@ConnectedSocket() socket: Socket, @MessageBody() lobbyId: string) {
        socket.join(lobbyId);
        // Pour démarrer tout le monde en même temps
        if (Array.from(await this.server.in(lobbyId).fetchSockets()).length === this.roomsManager.lobbies.get(lobbyId).players.length) {
            this.roomsManager.lobbies.get(lobbyId).chatLog = { chat: [], channelName: 'game' } as ChatLog;
            if (this.roomsManager.lobbies.get(lobbyId).mode === GameModes.Classic) {
                await this.gameService.getGameById(this.roomsManager.lobbies.get(lobbyId).gameId).then((game) => {
                    // Mettre une copie de game(db) vers game(game) et l'identifier par le lobbyId
                    const clonedGame: Game = structuredClone({
                        lobbyId,
                        name: game.name,
                        original: game.originalImage,
                        modified: game.modifiedImage,
                        gameId: game._id.toString(),
                        differences: JSON.parse(game.differences) as Coordinate[][],
                        nDifferences: JSON.parse(game.differences).length,
                    });
                    this.games.set(lobbyId, clonedGame);
                });
                this.server.to(lobbyId).emit(GameEvents.StartGame, this.games.get(lobbyId));
                this.logger.log(`Game started in lobby -> ${lobbyId}`);
            } else if (this.roomsManager.lobbies.get(lobbyId).mode === GameModes.Limited) {
                await this.nextGame(lobbyId, []);
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
                    this.logDraw(lobbyId);
                    clearInterval(timerId);
                    return;
                }
                this.roomsManager.lobbies.get(lobbyId).time -= 1;
                this.roomsManager.lobbies.get(lobbyId).timePlayed += 1;
                this.server.to(lobbyId).emit(GameEvents.TimerUpdate, this.roomsManager.lobbies.get(lobbyId).time);
            }, DELAY_BEFORE_EMITTING_TIME);
            this.timers.set(lobbyId, timerId);
        }
    }

    @SubscribeMessage(GameEvents.Clic)
    async clic(@ConnectedSocket() socket: Socket, @MessageBody('lobbyId') lobbyId: string, @MessageBody('coordClic') coordClic: Coordinate) {
        const index: number = this.games
            .get(lobbyId)
            .differences.findIndex((difference) => difference.some((coord: Coordinate) => coord.x === coordClic.x && coord.y === coordClic.y));
        const commonMessage =
            index !== NOT_FOUND
                ? `${this.accountManager.connectedUsers.get(socket.data.accountId).credentials.username}, 'a trouvé une différence !`
                : `${this.accountManager.connectedUsers.get(socket.data.accountId).credentials.username}, 's'est trompé !`;
        // ------------------ CLASSIC MODE ------------------
        if (this.roomsManager.lobbies.get(lobbyId).mode === GameModes.Classic) {
            // Si trouvé
            if (index !== NOT_FOUND) {
                // Update tout correctement
                this.roomsManager.lobbies.get(lobbyId).players.find((player) => player.accountId === socket.data.accountId).count++;
                const difference = this.games.get(lobbyId).differences[index];
                this.games.get(lobbyId).differences.splice(index, 1);
                const remainingDifferences: Coordinate[][] = this.games.get(lobbyId).differences;
                this.server.to(lobbyId).emit(GameEvents.Found, {
                    lobby: this.roomsManager.lobbies.get(lobbyId),
                    difference,
                });
                this.roomsManager.lobbies.get(lobbyId).isCheatEnabled ? this.server.to(lobbyId).emit(GameEvents.Cheat, remainingDifferences) : null;
                this.server.to(lobbyId).emit(ChannelEvents.GameMessage, { raw: commonMessage, tag: MessageTag.Common } as Chat);
                // Vérifier si un seuil est atteint pour un joueur
                const { isGameFinished, potentialWinner } = this.thresholdCheck(lobbyId);
                if (isGameFinished && potentialWinner) {
                    this.server.to(lobbyId).emit(GameEvents.EndGame);
                    this.logOneWinner(lobbyId, potentialWinner.accountId);
                    this.server.to(lobbyId).emit(ChannelEvents.GameMessage, {
                        raw: `${this.accountManager.connectedUsers.get(potentialWinner.accountId).credentials.username} a gagné !`,
                        tag: MessageTag.Common,
                    } as Chat);
                    clearInterval(this.timers.get(lobbyId));
                    return;
                }
                // Vérifier s'il reste des differences
                if (this.games.get(lobbyId).differences.length <= 0) {
                    this.server.to(lobbyId).emit(GameEvents.EndGame);
                    this.logDraw(lobbyId);
                    this.server.to(lobbyId).emit(ChannelEvents.GameMessage, {
                        raw: 'MATCH NUL',
                        tag: MessageTag.Common,
                    } as Chat);
                    clearInterval(this.timers.get(lobbyId));
                }
                return;
            }
            // Si pas trouvé
            this.server.to(lobbyId).emit(ChannelEvents.GameMessage, { raw: commonMessage, tag: MessageTag.Common } as Chat);
            socket.emit(GameEvents.NotFound, coordClic);
            // ------------------ LIMITED MODE ------------------
        } else if (this.roomsManager.lobbies.get(lobbyId).mode === GameModes.Limited) {
            // Si trouvé
            if (index !== NOT_FOUND) {
                // Update tout correctement
                this.roomsManager.lobbies.get(lobbyId).players.find((player) => player.accountId === socket.data.accountId).count++;
                // Update le time
                this.roomsManager.lobbies.get(lobbyId).time + this.roomsManager.lobbies.get(lobbyId).bonusTime >=
                this.roomsManager.lobbies.get(lobbyId).timeLimit
                    ? (this.roomsManager.lobbies.get(lobbyId).time = this.roomsManager.lobbies.get(lobbyId).timeLimit)
                    : (this.roomsManager.lobbies.get(lobbyId).time += this.roomsManager.lobbies.get(lobbyId).bonusTime);
                const difference = this.games.get(lobbyId).differences[index];
                this.server.to(lobbyId).emit(GameEvents.Found, {
                    lobby: this.roomsManager.lobbies.get(lobbyId),
                    difference,
                });
                this.server.to(lobbyId).emit(ChannelEvents.GameMessage, { raw: commonMessage, tag: MessageTag.Common } as Chat);
                // Load la next game
                const game = await this.nextGame(lobbyId, this.games.get(lobbyId).playedGameIds);
                if (!game) {
                    const { winningPlayers, message } = this.limitedEndCheck(lobbyId);
                    this.logger.log(`Game ${lobbyId} ended with ${winningPlayers.length} winners`);
                    this.server.to(lobbyId).emit(GameEvents.EndGame);
                    winningPlayers.length === 1 ? this.logOneWinner(lobbyId, winningPlayers[0].accountId) : this.logDraw(lobbyId);
                    this.server.to(lobbyId).emit(ChannelEvents.GameMessage, {
                        raw: message,
                        tag: MessageTag.Common,
                    } as Chat);
                    clearInterval(this.timers.get(lobbyId));
                    return;
                }
                this.roomsManager.lobbies.get(lobbyId).isCheatEnabled
                    ? this.server.to(lobbyId).emit(GameEvents.Cheat, this.games.get(lobbyId).differences)
                    : null;
                return;
            }
            // Si pas trouvé
            this.server.to(lobbyId).emit(ChannelEvents.GameMessage, { raw: commonMessage, tag: MessageTag.Common } as Chat);
            socket.emit(GameEvents.NotFound, coordClic);
        }
    }

    @SubscribeMessage(GameEvents.AbandonGame)
    abandonGame(@ConnectedSocket() socket: Socket, @MessageBody() lobbyId: string) {
        socket.data.state = GameState.Abandoned;
        this.roomsManager.lobbies.get(lobbyId).players = this.roomsManager.lobbies
            .get(lobbyId)
            .players.filter((player) => player.accountId !== socket.data.accountId);
        socket.leave(lobbyId);
        this.logger.log(`${socket.data.accountId} abandoned game ${lobbyId}`);
        if (this.roomsManager.lobbies.get(lobbyId).players.length <= 1) {
            this.server.to(lobbyId).emit(GameEvents.EndGame, 'Abandon');
            clearInterval(this.timers.get(lobbyId));
            this.logger.log(`Game ${lobbyId} ended because of not enough players`);
        }
    }

    @SubscribeMessage(ChannelEvents.SendGameMessage)
    handleGameMessage(@ConnectedSocket() socket: Socket, @MessageBody('lobbyId') lobbyId: string, @MessageBody('message') message: string) {
        const chat: Chat = this.messageManager.createMessage(
            this.accountManager.connectedUsers.get(socket.data.accountId).credentials.username,
            message,
        );

        this.roomsManager.lobbies.get(lobbyId).chatLog.chat.push(chat);

        socket.emit(ChannelEvents.GameMessage, { ...chat, tag: MessageTag.Sent, accountId: socket.data.accountId });
        socket.broadcast.to(lobbyId).emit(ChannelEvents.GameMessage, { ...chat, tag: MessageTag.Received, accountId: socket.data.accountId });
    }

    handleConnection(@ConnectedSocket() socket: Socket) {
        socket.data.accountId = socket.handshake.query.id as string;
        socket.data.state = GameState.InGame;

        socket.on('disconnecting', () => {
            switch (socket.data.state) {
                case GameState.InGame:
                    const lobbyId: string = Array.from(socket.rooms)[1] as string;
                    this.roomsManager.lobbies.get(lobbyId).players = this.roomsManager.lobbies
                        .get(lobbyId)
                        .players.filter((player) => player.accountId !== socket.data.accountId);
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
            this.logger.log(`GAME OUT de ${socket.data.accountId}`);
        });
        this.logger.log(`GAME ON de ${socket.data.accountId}`);
    }

    // ------------------ CLASSIC MODE ------------------
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
    // ------------------ LIMITED MODE ------------------
    private limitedEndCheck(lobbyId: string) {
        const players = this.roomsManager.lobbies.get(lobbyId).players;
        const highestScore = Math.max(...players.map((player) => player.count));
        const winningPlayers = players.filter((player) => player.count === highestScore);
        let message: string;

        if (winningPlayers.length === 1) {
            message = `${winningPlayers[0].name} a gagné avec ${highestScore} points !`;
        } else {
            const names = winningPlayers.map((player) => player.name).join(', ');
            message = `Match nul entre ${names} avec ${highestScore} points chacun !`;
        }

        return { winningPlayers, message };
    }

    private async nextGame(lobbyId: string, gamesPlayed: string[]) {
        // Picking one game randomly
        const game = await this.gameService.getRandomGame(gamesPlayed);
        if (!game) return false;
        const clonedGame: Game = structuredClone({
            lobbyId,
            name: game.name,
            original: game.originalImage,
            modified: game.modifiedImage,
            gameId: game._id,
            differences: JSON.parse(game.differences) as Coordinate[][],
            playedGameIds: [...gamesPlayed, game._id.toString()],
        });
        // Randomly picking one difference to keep
        const keepIndex: number = Math.floor(Math.random() * clonedGame.differences.length);
        const gameCopy = structuredClone(clonedGame);
        clonedGame.modified = await this.imageManager.modifyImage(gameCopy, keepIndex);
        clonedGame.differences = clonedGame.differences.filter((_, index) => index === keepIndex);
        this.games.set(lobbyId, clonedGame);
        return game;
    }

    // ------------------ CALCULATE SESSION LOG ------------------

    // "winner" veut dire que tout le monde lose sauf le winner
    private logOneWinner(lobbyId: string, accountId: string) {
        const winner = this.roomsManager.lobbies.get(lobbyId).players.find((player) => player.accountId === accountId);
        this.accountManager.logSession(winner.accountId, true, this.roomsManager.lobbies.get(lobbyId).timePlayed, winner.count);
        const losers = this.roomsManager.lobbies.get(lobbyId).players.filter((player) => player.accountId !== accountId);
        losers.forEach((player) => {
            this.accountManager.logSession(player.accountId, false, this.roomsManager.lobbies.get(lobbyId).timePlayed, player.count);
        });
    }

    // "draw" veut dire que tout le monde lose
    private logDraw(lobbyId: string) {
        this.roomsManager.lobbies.get(lobbyId).players.forEach((player) => {
            this.accountManager.logSession(player.accountId, false, this.roomsManager.lobbies.get(lobbyId).timePlayed, player.count);
        });
    }
}
