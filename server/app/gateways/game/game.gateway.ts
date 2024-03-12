import { AccountManagerService } from '@app/services/account-manager/account-manager.service';
import { RoomsManagerService } from '@app/services/rooms-manager/rooms-manager.service';
import { GameEvents, GameState } from '@common/enums';
import { Game } from '@common/game-interfaces';
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

    // gateway needs to be injected all the services that it needs to use
    // eslint-disable-next-line max-params -- services are needed for the gateway
    constructor(
        private readonly logger: Logger,
        private readonly roomsManager: RoomsManagerService,
        private readonly accountManager: AccountManagerService,
    ) {}

    @SubscribeMessage(GameEvents.Start)
    startGame(@ConnectedSocket() socket: Socket, @MessageBody() lobbyId: string) {
        // this.roomsManager.startGame(socket, lobbyId);
    }

    afterInit() {
        setInterval(() => {
            this.roomsManager.updateTimers(this.server);
        }, DELAY_BEFORE_EMITTING_TIME);
    }

    handleConnection(@ConnectedSocket() socket: Socket) {
        socket.data.accountId = socket.handshake.query.id as string;
        socket.data.state = GameState.InGame;

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
