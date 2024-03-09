import { LobbyEvents } from '@common/enums';
import { Logger } from '@nestjs/common';
import { ConnectedSocket, OnGatewayConnection, OnGatewayDisconnect, SubscribeMessage, WebSocketGateway, WebSocketServer } from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({
    namespace: '/lobby',
})
export class LobbyGateway implements OnGatewayConnection, OnGatewayDisconnect {
    @WebSocketServer() private server: Server;

    constructor(private readonly logger: Logger) {
        //
    }

    @SubscribeMessage(LobbyEvents.Create)
    createLobby(@ConnectedSocket() socket: Socket) {
        this.logger.log(`${socket.id} crée un lobby`);
    }

    @SubscribeMessage(LobbyEvents.Join)
    handleConnection(@ConnectedSocket() socket: Socket) {
        socket.emit(LobbyEvents.Join);
        const userName = socket.handshake.query.name as string;
        socket.data.username = userName;
        this.logger.log(`LOBBY IN de ${userName}`);
    }

    @SubscribeMessage(LobbyEvents.Leave)
    handleDisconnect(@ConnectedSocket() socket: Socket) {
        socket.emit(LobbyEvents.Leave);
        this.logger.log(`LOBBY OUT de ${socket.data.username}`);
    }
}
