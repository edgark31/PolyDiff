import { AccountManagerService } from '@app/services/account-manager/account-manager.service';
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

    constructor(private readonly logger: Logger, private readonly accountManager: AccountManagerService) {}

    @SubscribeMessage(LobbyEvents.Create)
    async create(@ConnectedSocket() socket: Socket, lobby: Lobby) {
        lobby.lobbyId = socket.data.id;
        socket.join(lobby.lobbyId);
        this.lobbies.set(lobby.lobbyId, lobby);
        this.update();
        this.logger.log(`${this.accountManager.connectedUsers.get(socket.data.id)} crée un lobby`);
    }

    @SubscribeMessage(LobbyEvents.Join)
    join(@ConnectedSocket() socket: Socket, lobbyId: string) {
        socket.join(lobbyId);
        this.logger.log(`${this.accountManager.connectedUsers.get(socket.data.id)} rejoint le lobby ${lobbyId}`);
    }

    @SubscribeMessage(LobbyEvents.UpdateLobbys)
    update() {
        this.server.emit(LobbyEvents.UpdateLobbys, this.lobbies);
    }

    handleConnection(@ConnectedSocket() socket: Socket) {
        const userId = socket.handshake.query.id as string;
        socket.data.id = userId;
        socket.on('disconnecting', () => {
            this.logger.log(`LOBBY OUT de ${userId} : ${Array.from(socket.rooms)[0]}`);
        });
        this.logger.log(`LOBBY IN de ${userId}`);
    }
}
