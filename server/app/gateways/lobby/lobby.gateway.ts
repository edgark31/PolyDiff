/* eslint-disable max-params */
import { AccountManagerService } from '@app/services/account-manager/account-manager.service';
import { MessageManagerService } from '@app/services/message-manager/message-manager.service';
import { RoomsManagerService } from '@app/services/rooms-manager/rooms-manager.service';
import { ChannelEvents, LobbyEvents, LobbyState, MessageTag } from '@common/enums';
import { Chat, ChatLog, Lobby, Player } from '@common/game-interfaces';
import { Logger } from '@nestjs/common';
import { ConnectedSocket, MessageBody, OnGatewayConnection, SubscribeMessage, WebSocketGateway, WebSocketServer } from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({
    namespace: '/lobby',
})
export class LobbyGateway implements OnGatewayConnection {
    @WebSocketServer() private server: Server;

    constructor(
        private readonly logger: Logger,
        private readonly accountManager: AccountManagerService,
        private readonly messageManager: MessageManagerService,
        private readonly roomsManager: RoomsManagerService,
    ) {
        this.roomsManager.lobbies = new Map<string, Lobby>();
    }

    // l'hôte crée le lobby
    @SubscribeMessage(LobbyEvents.Create)
    create(@ConnectedSocket() socket: Socket, @MessageBody() lobby: Lobby) {
        socket.data.state = LobbyState.Waiting;
        lobby.lobbyId = socket.data.accountId;
        socket.join(lobby.lobbyId);
        const player: Player = {
            accountId: socket.data.accountId,
            name: this.accountManager.connectedUsers.get(socket.data.accountId).credentials.username,
            count: 0,
        };
        lobby.players.push(player);
        lobby.chatLog = { chat: [], channelName: 'lobby' } as ChatLog;
        this.roomsManager.lobbies.set(lobby.lobbyId, lobby);
        socket.emit(LobbyEvents.Create, this.roomsManager.lobbies.get(lobby.lobbyId));
        const lobbies = Array.from(this.roomsManager.lobbies.values());
        this.server.emit(LobbyEvents.UpdateLobbys, lobbies);
        this.logger.log(`${this.accountManager.connectedUsers.get(socket.data.accountId).credentials.username} crée le lobby ${lobby.lobbyId}`);
    }

    // un joueur rejoint le lobby
    @SubscribeMessage(LobbyEvents.Join)
    join(@ConnectedSocket() socket: Socket, @MessageBody() data: { lobbyId: string; password?: string }) {
        const { lobbyId, password } = data;
        if (this.roomsManager.lobbies.get(lobbyId).password && this.roomsManager.lobbies.get(lobbyId).password !== password) return;

        socket.data.state = LobbyState.Waiting;
        socket.join(lobbyId);
        const player: Player = {
            accountId: socket.data.accountId,
            name: this.accountManager.connectedUsers.get(socket.data.accountId).credentials.username,
            count: 0,
        };
        this.roomsManager.lobbies.get(lobbyId).players.push(player);
        this.server.to(lobbyId).emit(LobbyEvents.Join, this.roomsManager.lobbies.get(lobbyId));
        this.server.emit(LobbyEvents.UpdateLobbys, Array.from(this.roomsManager.lobbies.values()));
        this.logger.log(`${this.accountManager.connectedUsers.get(socket.data.accountId).credentials.username} rejoint le lobby ${lobbyId}`);
    }

    // un joueur quitte le lobby intentionnellement
    @SubscribeMessage(LobbyEvents.Leave)
    async leave(@ConnectedSocket() socket: Socket, @MessageBody() lobbyId: string) {
        socket.data.state = LobbyState.Idle;
        // Si t'es le host
        if (socket.data.accountId === this.roomsManager.lobbies.get(lobbyId).players[0].accountId) {
            const sockets = await this.server.in(lobbyId).fetchSockets();
            for (const clientSocket of sockets) {
                clientSocket.leave(lobbyId);
                clientSocket.emit(LobbyEvents.Leave);
            }
            this.roomsManager.lobbies.delete(lobbyId);
            this.server.emit(LobbyEvents.UpdateLobbys, Array.from(this.roomsManager.lobbies.values()));
            this.logger.log(`${this.accountManager.connectedUsers.get(socket.data.accountId).credentials.username} supprime le lobby ${lobbyId}`);
            return;
        }
        // Si t'es un guest
        socket.leave(lobbyId);
        this.roomsManager.lobbies.get(lobbyId).players = this.roomsManager.lobbies
            .get(lobbyId)
            .players.filter((player) => player.accountId !== socket.data.accountId);
        socket.emit(LobbyEvents.Leave);
        this.server.emit(LobbyEvents.UpdateLobbys, Array.from(this.roomsManager.lobbies.values()));
        this.logger.log(`${this.accountManager.connectedUsers.get(socket.data.accountId).credentials.username} quitte le lobby ${lobbyId}`);
    }

    // l'hôte démmare le lobby et connecte le socket game - transfert vers game gateway
    @SubscribeMessage(LobbyEvents.Start)
    start(@ConnectedSocket() socket: Socket, @MessageBody() lobbyId: string) {
        socket.data.state = LobbyState.InGame;
        this.roomsManager.lobbies.get(lobbyId).isAvailable = false;

        this.server.emit(LobbyEvents.UpdateLobbys, Array.from(this.roomsManager.lobbies.values()));
        this.server.to(lobbyId).emit(LobbyEvents.Start, lobbyId);
        this.logger.log(`${this.accountManager.connectedUsers.get(socket.data.accountId).credentials.username} démarre le lobby ${lobbyId}`);
    }

    @SubscribeMessage(ChannelEvents.SendLobbyMessage)
    handleMessage(@ConnectedSocket() socket: Socket, @MessageBody('lobbyId') lobbyId: string, @MessageBody('message') message: string) {
        const chat: Chat = this.messageManager.createMessage(
            this.accountManager.connectedUsers.get(socket.data.accountId).credentials.username,
            message,
        );
        this.roomsManager.lobbies.get(lobbyId).chatLog.chat.push(chat);

        socket.emit(ChannelEvents.LobbyMessage, { ...chat, tag: MessageTag.Sent, accountId: socket.data.accountId });
        socket.broadcast.to(lobbyId).emit(ChannelEvents.LobbyMessage, { ...chat, tag: MessageTag.Received, accountId: socket.data.accountId });

        this.server.emit(LobbyEvents.UpdateLobbys, Array.from(this.roomsManager.lobbies.values()));
        this.logger.log(`${this.accountManager.connectedUsers.get(socket.data.accountId).credentials.username} envoie un message`);
    }

    @SubscribeMessage(LobbyEvents.UpdateLobbys)
    update(@ConnectedSocket() socket: Socket) {
        const lobbies = Array.from(this.roomsManager.lobbies.values());
        socket.emit(LobbyEvents.UpdateLobbys, lobbies);
    }

    handleConnection(@ConnectedSocket() socket: Socket) {
        socket.data.accountId = socket.handshake.query.id as string;
        socket.data.state = LobbyState.Idle;
        const lobbies = Array.from(this.roomsManager.lobbies.values());
        this.server.emit(LobbyEvents.UpdateLobbys, lobbies);
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
            const lobbiesFromManager = Array.from(this.roomsManager.lobbies.values());
            this.server.emit(LobbyEvents.UpdateLobbys, lobbiesFromManager);
            this.logger.log(`LOBBY OUT de ${socket.data.accountId}`);
        });
        this.logger.log(`LOBBY IN de ${socket.data.accountId}`);
    }
}
