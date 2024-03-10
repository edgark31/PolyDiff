import { AccountManagerService } from '@app/services/account-manager/account-manager.service';
import { GameService } from '@app/services/game/game.service';
import { LobbyEvents, LobbyState } from '@common/enums';
import { Lobby } from '@common/game-interfaces';
import { Logger } from '@nestjs/common';
import { ConnectedSocket, MessageBody, OnGatewayConnection, SubscribeMessage, WebSocketGateway, WebSocketServer } from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({
    namespace: '/lobby',
})
export class LobbyGateway implements OnGatewayConnection {
    @WebSocketServer() private server: Server;
    private readonly lobbies = new Map<string, Lobby>();

    constructor(private readonly logger: Logger, private readonly accountManager: AccountManagerService, private readonly gameService: GameService) {
        this.lobbies = new Map<string, Lobby>();
    }

    // quelqun crée le lobby et devient host
    @SubscribeMessage(LobbyEvents.Create)
    create(@ConnectedSocket() socket: Socket, @MessageBody() lobby: Lobby) {
        socket.data.state = LobbyState.Waiting;
        lobby.lobbyId = socket.data.id;
        socket.join(lobby.lobbyId);
        this.lobbies.set(lobby.lobbyId, lobby);
        this.server.emit(LobbyEvents.UpdateLobbys, this.lobbies);
        this.logger.log(`${this.accountManager.connectedUsers.get(socket.data.id).credentials.username} crée le lobby ${lobby.lobbyId}`);
    }

    @SubscribeMessage(LobbyEvents.Join)
    join(@ConnectedSocket() socket: Socket, @MessageBody() lobbyId: string) {
        socket.data.state = LobbyState.Waiting;
        socket.join(lobbyId);
        this.lobbies.get(lobbyId).players.push(socket.data.id);
        this.server.emit(LobbyEvents.UpdateLobbys, this.lobbies);
        this.logger.log(`${this.accountManager.connectedUsers.get(socket.data.id).credentials.username} rejoint le lobby ${lobbyId}`);
    }

    @SubscribeMessage(LobbyEvents.Leave)
    leave(@ConnectedSocket() socket: Socket, @MessageBody() lobbyId: string) {
        socket.data.state = LobbyState.Idle;
        socket.leave(lobbyId);
        this.lobbies.get(lobbyId).players = this.lobbies.get(lobbyId).players.filter((player) => player !== socket.data.id);
        this.server.emit(LobbyEvents.UpdateLobbys, this.lobbies);
        this.logger.log(`${this.accountManager.connectedUsers.get(socket.data.id).credentials.username} quitte le lobby ${lobbyId}`);
    }

    @SubscribeMessage(LobbyEvents.Start)
    start(@ConnectedSocket() socket: Socket, @MessageBody() lobbyId: string) {
        socket.data.state = LobbyState.InGame;
        this.server.emit(LobbyEvents.UpdateLobbys, this.lobbies);
        socket.to(lobbyId).emit(LobbyEvents.Start, lobbyId);
        this.logger.log(`${this.accountManager.connectedUsers.get(socket.data.id).credentials.username} démarre le lobby ${lobbyId}`);
    }

    @SubscribeMessage(LobbyEvents.UpdateLobbys)
    update() {
        this.server.emit(LobbyEvents.UpdateLobbys, this.lobbies);
    }

    @SubscribeMessage(LobbyEvents.Join)
    handleConnection(@ConnectedSocket() socket: Socket) {
        socket.data.id = socket.handshake.query.id as string;
        socket.data.state = LobbyState.Idle;
        this.server.emit(LobbyEvents.UpdateLobbys, this.lobbies);

        // HANDLE DISCONNECT-ING ***
        socket.on('disconnecting', () => {
            switch (socket.data.state) {
                case LobbyState.Idle:
                    break;
                case LobbyState.Waiting: // ta deja rejoint une room
                    break;
                case LobbyState.InGame: // t'es dans deux rooms (1 dans lobby, 1 dans game)
                    break;
                default:
                    break;
            }

            this.server.emit(LobbyEvents.UpdateLobbys, this.lobbies);
            this.logger.log(`LOBBY OUT de ${socket.data.id}`);
        });
        this.logger.log(`LOBBY IN de ${socket.data.id}`);
    }
}
