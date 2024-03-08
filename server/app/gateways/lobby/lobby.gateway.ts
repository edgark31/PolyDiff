import { LobbyEvents } from '@common/enums';
import { Lobby } from '@common/game-interfaces';
import { Logger } from '@nestjs/common';
import { ConnectedSocket, OnGatewayConnection, SubscribeMessage, WebSocketGateway, WebSocketServer } from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({
    namespace: '/lobby',
})
export class LobbyGateway implements OnGatewayConnection {
    @WebSocketServer() private server: Server;
    private readonly lobbies = new Map<string, Lobby>();

    constructor(private readonly logger: Logger) {
        //
    }

    @SubscribeMessage(LobbyEvents.Create)
    create(@ConnectedSocket() socket: Socket): string {
        this.logger.log(`${socket.id} crée un lobby`);
        return 'Hello world!';
    }

    @SubscribeMessage(LobbyEvents.UpdateLobbys)
    update() {
        this.server.emit(LobbyEvents.UpdateLobbys, this.lobbies);
    }

    handleConnection(@ConnectedSocket() socket: Socket) {
        const userName = socket.handshake.query.name as string;
        socket.data.username = userName;
        socket.on('disconnecting', () => {
            this.logger.log(`LOBBY OUT de ${userName} : ${Array.from(socket.rooms)[0]}`);
        });
        this.logger.log(`LOBBY IN de ${userName}`);
    }
}
