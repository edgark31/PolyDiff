import { AccountManagerService } from '@app/services/account-manager/account-manager.service';
import { MessageManagerService } from '@app/services/message-manager/message-manager.service';
import { ChannelEvents, LobbyEvents, LobbyState, MessageTag } from '@common/enums';
import { Chat, Lobby, Player } from '@common/game-interfaces';
import { Logger } from '@nestjs/common';
import { ConnectedSocket, MessageBody, OnGatewayConnection, SubscribeMessage, WebSocketGateway, WebSocketServer } from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({
    namespace: '/lobby',
})
export class LobbyGateway implements OnGatewayConnection {
    @WebSocketServer() private server: Server;
    private readonly lobbies = new Map<string, Lobby>(); // lobbies = salle d'attentes

    constructor(
        private readonly logger: Logger,
        private readonly accountManager: AccountManagerService,
        private readonly messageManager: MessageManagerService,
    ) {
        this.lobbies = new Map<string, Lobby>();
    }

    // l'hôte crée le lobby
    @SubscribeMessage(LobbyEvents.Create)
    create(@ConnectedSocket() socket: Socket, @MessageBody() lobby: Lobby) {
        console.log(socket.data.id);
        socket.data.state = LobbyState.Waiting;
        lobby.lobbyId = socket.data.id;
        socket.join(lobby.lobbyId);
        const player: Player = {
            socketId: socket.data.id,
            name: this.accountManager.connectedUsers.get(socket.data.id).credentials.username,
        };
        lobby.players.push(player);
        this.lobbies.set(lobby.lobbyId, lobby);
        socket.emit(LobbyEvents.Create, this.lobbies.get(lobby.lobbyId));
        this.server.emit(LobbyEvents.UpdateLobbys, this.lobbies);
        this.logger.log(`${this.accountManager.connectedUsers.get(socket.data.id).credentials.username} crée le lobby ${lobby.lobbyId}`);
    }

    // un joueur rejoint le lobby
    @SubscribeMessage(LobbyEvents.Join)
    join(@ConnectedSocket() socket: Socket, @MessageBody() lobbyId: string) {
        socket.data.state = LobbyState.Waiting;
        socket.join(lobbyId);
        const player: Player = {
            socketId: socket.data.id,
            name: this.accountManager.connectedUsers.get(socket.data.id).credentials.username,
        };
        this.lobbies.get(lobbyId).players.push(player);
        this.server.emit(LobbyEvents.UpdateLobbys, this.lobbies);
        this.logger.log(`${this.accountManager.connectedUsers.get(socket.data.id).credentials.username} rejoint le lobby ${lobbyId}`);
    }

    // un joueur quitte le lobby intentionnellement
    @SubscribeMessage(LobbyEvents.Leave)
    leave(@ConnectedSocket() socket: Socket, @MessageBody() lobbyId: string) {
        socket.data.state = LobbyState.Idle;
        socket.leave(lobbyId);
        this.lobbies.get(lobbyId).players = this.lobbies.get(lobbyId).players.filter((player) => player !== socket.data.id);
        this.server.emit(LobbyEvents.UpdateLobbys, this.lobbies);
        this.logger.log(`${this.accountManager.connectedUsers.get(socket.data.id).credentials.username} quitte le lobby ${lobbyId}`);
    }

    // l'hôte démmare le lobby et connecte le socket game - transfert vers game gateway
    @SubscribeMessage(LobbyEvents.Start)
    start(@ConnectedSocket() socket: Socket, @MessageBody() lobbyId: string) {
        socket.data.state = LobbyState.InGame;
        this.lobbies.get(lobbyId).isAvailable = false;
        this.server.emit(LobbyEvents.UpdateLobbys, this.lobbies);
        socket.to(lobbyId).emit(LobbyEvents.Start, lobbyId);
        this.logger.log(`${this.accountManager.connectedUsers.get(socket.data.id).credentials.username} démarre le lobby ${lobbyId}`);
    }

    @SubscribeMessage(ChannelEvents.SendLobbyMessage)
    handleMessage(@ConnectedSocket() socket: Socket, @MessageBody('lobbyId') lobbyId: string, @MessageBody('message') message: string) {
        const chat: Chat = this.messageManager.createMessage(socket.data.id, message);
        this.lobbies.get(lobbyId).chatLog.chat.push(chat);

        socket.emit(ChannelEvents.LobbyMessage, { ...chat, tag: MessageTag.Sent });
        socket.broadcast.to(lobbyId).emit(ChannelEvents.LobbyMessage, { ...chat, tag: MessageTag.Received });

        this.server.emit(LobbyEvents.UpdateLobbys, this.lobbies);
        socket.to(lobbyId).emit(LobbyEvents.Start, lobbyId);
        this.logger.log(`${this.accountManager.connectedUsers.get(socket.data.id).credentials.username} envoie un message`);
    }

    @SubscribeMessage(LobbyEvents.UpdateLobbys)
    update(@ConnectedSocket() socket: Socket) {
        socket.emit(LobbyEvents.UpdateLobbys, this.lobbies);
    }

    handleConnection(@ConnectedSocket() socket: Socket) {
        socket.data.id = socket.handshake.query.id as string;
        socket.data.state = LobbyState.Idle;
        socket.emit(LobbyEvents.UpdateLobbys, this.lobbies);

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
