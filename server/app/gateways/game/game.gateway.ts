import { AccountManagerService } from '@app/services/account-manager/account-manager.service';
import { RoomsManagerService } from '@app/services/rooms-manager/rooms-manager.service';
import { Lobby } from '@common/game-interfaces';
import { Injectable, Logger } from '@nestjs/common';
import { ConnectedSocket, OnGatewayConnection, OnGatewayInit, WebSocketGateway, WebSocketServer } from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { DELAY_BEFORE_EMITTING_TIME } from './game.gateway.constants';

@WebSocketGateway({
    namespace: '/game',
})
@Injectable()
export class GameGateway implements OnGatewayConnection, OnGatewayInit {
    @WebSocketServer() private server: Server;
    private readonly lobbies = new Map<string, Lobby>();

    // gateway needs to be injected all the services that it needs to use
    // eslint-disable-next-line max-params -- services are needed for the gateway
    constructor(
        private readonly logger: Logger,
        private readonly roomsManagerService: RoomsManagerService,
        private readonly accountManager: AccountManagerService,
    ) {}

    afterInit() {
        setInterval(() => {
            this.roomsManagerService.updateTimers(this.server);
        }, DELAY_BEFORE_EMITTING_TIME);
    }

    handleConnection(@ConnectedSocket() socket: Socket) {
        const userId = socket.handshake.query.id as string;
        socket.data.id = userId;
        

        socket.on('disconnecting', () => {
            this.logger.log(`LOBBY OUT de ${userId}`);
        });
        this.logger.log(`GAME ON de ${userId}`);
    }
}
