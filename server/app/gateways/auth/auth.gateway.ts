import { AccountEvents } from '@common/enums';
import { Logger } from '@nestjs/common';
import {
    ConnectedSocket,
    OnGatewayConnection,
    OnGatewayDisconnect,
    OnGatewayInit,
    SubscribeMessage,
    WebSocketGateway,
    WebSocketServer,
} from '@nestjs/websockets';
import { instrument } from '@socket.io/admin-ui';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({
    cors: {
        origin: (origin, callback) => {
            if (origin === undefined || origin === 'https://admin.socket.io') {
                callback(null, true);
            } else {
                callback(null, '*');
            }
        },
        credentials: true,
    },
})
export class AuthGateway implements OnGatewayConnection, OnGatewayDisconnect, OnGatewayInit {
    @WebSocketServer() private server: Server;

    constructor(private readonly logger: Logger) {
        //
    }

    @SubscribeMessage(AccountEvents.Update)
    update(@ConnectedSocket() socket: Socket): string {
        return 'Hello world!';
    }

    afterInit() {
        instrument(this.server, {
            auth: false,
            mode: 'development',
        });
    }

    handleConnection(@ConnectedSocket() socket: Socket) {
        this.logger.log(`Auth par l'utilisateur avec id : ${socket.id}`);
    }

    handleDisconnect(@ConnectedSocket() socket: Socket) {
        this.logger.log(`Déconnexion par l'utilisateur avec id : ${socket.id}`);
    }
}
