/* eslint-disable no-underscore-dangle */
/* eslint-disable max-params */
import { AccountManagerService } from '@app/services/account-manager/account-manager.service';
import { ClassicModeService } from '@app/services/classic-mode/classic-mode.service';
import { GameService } from '@app/services/game/game.service';
import { LimitedModeService } from '@app/services/limited-mode/limited-mode.service';
import { MessageManagerService } from '@app/services/message-manager/message-manager.service';
import { RoomsManagerService } from '@app/services/rooms-manager/rooms-manager.service';
import { NOT_FOUND } from '@common/constants';
import { ChannelEvents, GameEvents, GameModes, GameState, MessageTag } from '@common/enums';
import { Chat, Coordinate, Game } from '@common/game-interfaces';
import { Injectable, Logger } from '@nestjs/common';
import {
    ConnectedSocket,
    MessageBody,
    OnGatewayConnection,
    OnGatewayInit,
    SubscribeMessage,
    WebSocketGateway,
    WebSocketServer,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { DELAY_BEFORE_EMITTING_TIME } from './game.gateway.constants';

@WebSocketGateway({
    namespace: '/game',
})
@Injectable()
export class GameGateway implements OnGatewayConnection, OnGatewayInit {
    @WebSocketServer() private server: Server;
    private readonly games = new Map<string, Game>();

    constructor(
        private readonly logger: Logger,
        private readonly accountManager: AccountManagerService,
        private readonly gameService: GameService,
        private readonly roomsManager: RoomsManagerService,
        private readonly classicMode: ClassicModeService,
        private readonly limitedMode: LimitedModeService,
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
                    // Mettre une copie de game(db) vers game(lobby) et l'identifier par le lobbyId
                    this.roomsManager.lobbies.get(lobbyId).game = {
                        lobbyId,
                        name: game.name,
                        original: game.originalImage,
                        modified: game.modifiedImage,
                        gameId: game._id,
                        differences: JSON.parse(game.differences) as Coordinate[][],
                    };
                });
                this.server.to(lobbyId).emit(GameEvents.StartGame, this.roomsManager.lobbies.get(lobbyId));
                this.logger.log(`Game started in lobby ${lobbyId}`);
            } else if (this.roomsManager.lobbies.get(lobbyId).mode === GameModes.Limited) {
                // Start Limited Mode
                this.logger.error('Not implemented yet, sorry... 😭');
            }
            // Set timer indivually for each lobby
            this.roomsManager.lobbies.get(lobbyId).timerId = setInterval(() => {
                if (this.roomsManager.lobbies.get(lobbyId).time <= 0) {
                    this.server.to(lobbyId).emit(GameEvents.EndGame, 'Temps écoulé !');
                    clearInterval(this.roomsManager.lobbies.get(lobbyId).timerId);
                    return;
                }
                this.roomsManager.lobbies.get(lobbyId).time -= 1;
                this.server.to(lobbyId).emit(GameEvents.TimerUpdate, this.roomsManager.lobbies.get(lobbyId).time);
            }, 1000);
        }
    }

    // -------------------------- CLASSIC MODE --------------------------
    @SubscribeMessage(GameEvents.Clic)
    clic(@ConnectedSocket() socket: Socket, @MessageBody('lobbyId') lobbyId: string, @MessageBody('coordClic') coordClic: Coordinate) {
        // Si le cheat est enabled
        this.logger.error('Clic found in lobby' + lobbyId);
        const index: number = this.roomsManager.lobbies
            .get(lobbyId)
            .game.differences.findIndex((difference) => difference.some((coord: Coordinate) => coord.x === coordClic.x && coord.y === coordClic.y));

        const commonMessage =
            index !== NOT_FOUND
                ? `${this.accountManager.connectedUsers.get(socket.data.accountId).credentials.username}, 'a trouvé une différence !`
                : `${this.accountManager.connectedUsers.get(socket.data.accountId).credentials.username}, 's'est trompé !`;

        // Si trouvé
        if (index !== NOT_FOUND) {
            this.roomsManager.lobbies.get(lobbyId).players.find((player) => player.accountId === socket.data.accountId).count++;
            const endVerification = this.roomsManager.lobbies.get(lobbyId).players.every((player) => player.count === 3);
            if (this.roomsManager.lobbies.get(lobbyId).players.find((player) => player.accountId === socket.data.accountId).count) {

            }
            this.server
                .to(lobbyId)
                .emit(GameEvents.Found, {
                    lobby: this.roomsManager.lobbies.get(lobbyId),
                    differences: this.roomsManager.lobbies.get(lobbyId).game.differences,
                });
            this.roomsManager.lobbies.get(lobbyId).isCheatEnabled ? this.server.to(lobbyId).emit(GameEvents.Cheat) : null;
            this.server.to(lobbyId).emit(ChannelEvents.GameMessage, { raw: commonMessage, tag: MessageTag.Common } as Chat);
            return;
        }
        // Si pas trouvé
        this.server.to(lobbyId).emit(ChannelEvents.GameMessage, { raw: commonMessage, tag: MessageTag.Common } as Chat);
        this.server.to(lobbyId).emit(GameEvents.NotFound, coordClic);
    }

    // -------------------------- LIMITED MODE --------------------------
    @SubscribeMessage(GameEvents.StartGame)
    nextGame(@ConnectedSocket() socket: Socket, @MessageBody() lobbyId: string) {}

    afterInit() {
        setInterval(() => {
            // this.roomsManager.updateTimers(this.server);
        }, DELAY_BEFORE_EMITTING_TIME);
    }

    handleConnection(@ConnectedSocket() socket: Socket) {
        socket.data.accountId = socket.handshake.query.id as string;

        socket.on('disconnecting', () => {
            switch (socket.data.state) {
                case GameState.InGame:
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
}
