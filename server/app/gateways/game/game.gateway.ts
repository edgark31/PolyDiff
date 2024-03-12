/* eslint-disable no-underscore-dangle */
/* eslint-disable max-params */
import { AccountManagerService } from '@app/services/account-manager/account-manager.service';
import { ClassicModeService } from '@app/services/classic-mode/classic-mode.service';
import { GameService } from '@app/services/game/game.service';
import { LimitedModeService } from '@app/services/limited-mode/limited-mode.service';
import { RoomsManagerService } from '@app/services/rooms-manager/rooms-manager.service';
import { GameEvents, GameModes, GameState } from '@common/enums';
import { Coordinate, Game } from '@common/game-interfaces';
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
    ) {}

    // -------------------------- CLASSIC MODE && LIMITED MODE --------------------------
    @SubscribeMessage(GameEvents.Start)
    async startGame(@ConnectedSocket() socket: Socket, @MessageBody() lobbyId: string) {
        // this.roomsManager.startGame(socket, lobbyId);
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
                this.server.to(lobbyId).emit(GameEvents.Start, this.roomsManager.lobbies.get(lobbyId));
                this.logger.log(`Game started in lobby ${lobbyId}`);
            } else if (this.roomsManager.lobbies.get(lobbyId).mode === GameModes.Limited) {
                // Start Limited Mode
                this.logger.log('Not implemented yet, sorry... Please dont hurt me 😭');
            }
        }
    }

    // -------------------------- LIMITED MODE --------------------------
    @SubscribeMessage(GameEvents.Start)
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
