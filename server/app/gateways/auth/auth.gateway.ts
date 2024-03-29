/* eslint-disable max-params */
import { AccountManagerService } from '@app/services/account-manager/account-manager.service';
import { FriendManagerService } from '@app/services/friend-manager/friend-manager.service';
import { MessageManagerService } from '@app/services/message-manager/message-manager.service';
import { AccountEvents, ChannelEvents, FriendEvents, MessageTag, UserEvents } from '@common/enums';
import { Chat, ChatLog } from '@common/game-interfaces';
import { Logger } from '@nestjs/common';
import {
    ConnectedSocket,
    MessageBody,
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
    @WebSocketServer() server: Server;
    globalChatLog: ChatLog;

    constructor(
        private readonly logger: Logger,
        private readonly accountManager: AccountManagerService,
        private readonly messageManager: MessageManagerService,
        private readonly friendManager: FriendManagerService,
    ) {
        this.globalChatLog = { chat: [], channelName: 'global' };
    }

    @SubscribeMessage(AccountEvents.RefreshAccount)
    handleRefreshAccount(@ConnectedSocket() socket: Socket) {
        socket.emit(AccountEvents.RefreshAccount, this.accountManager.users.get(socket.data.accountId));
    }

    // ---------------------- LES GETTERS de users à chaque RECHERCHE  --------------------------------
    @SubscribeMessage(UserEvents.UpdateUsers)
    updateUsers() {
        this.server.emit(UserEvents.UpdateUsers, this.friendManager.queryUsers()); // User[]
    }

    // ---------------------- LES GETTERS de friends INITIAUX --------------------------------
    @SubscribeMessage(FriendEvents.UpdateFriends)
    updateFriends(@ConnectedSocket() socket: Socket) {
        socket.emit(FriendEvents.UpdateFriends, this.accountManager.users.get(socket.data.accountId).profile.friends);
    }

    @SubscribeMessage(FriendEvents.UpdateSentFriends)
    updateSentFriends(@ConnectedSocket() socket: Socket) {
        socket.emit(FriendEvents.UpdateSentFriends, this.accountManager.users.get(socket.data.accountId).profile.friendRequests);
    }

    @SubscribeMessage(FriendEvents.UpdatePendingFriends)
    updatePendingFriends(@ConnectedSocket() socket: Socket) {
        socket.emit(FriendEvents.UpdatePendingFriends, this.accountManager.users.get(socket.data.accountId).profile.friendRequests);
    }

    // ---------------------- LES SCÉNARIOS --------------------------------
    @SubscribeMessage(FriendEvents.SendRequest)
    async sendRequest(@ConnectedSocket() socket: Socket, @MessageBody('potentialFriendId') potentialFriendId: string) {
        await this.friendManager.sendFriendRequest(socket.data.accountId, potentialFriendId);
        this.server.fetchSockets().then((sockets) => {
            const potentialFriendSocket = sockets.find((s) => s.data.accountId === potentialFriendId);
            if (potentialFriendSocket) {
                potentialFriendSocket.emit(
                    FriendEvents.UpdatePendingFriends,
                    this.friendManager.calculatePendingFriends(potentialFriendSocket.data.accountId),
                );
            }
        });
        socket.emit(FriendEvents.UpdateSentFriends, this.friendManager.calculateSentFriends(socket.data.accountId));
    }

    @SubscribeMessage(FriendEvents.CancelRequest)
    async cancelRequest(@ConnectedSocket() socket: Socket, @MessageBody('potentialFriendId') potentialFriendId: string) {
        await this.friendManager.cancelRequest(socket.data.accountId, potentialFriendId);
        this.server.fetchSockets().then((sockets) => {
            const potentialFriendSocket = sockets.find((s) => s.data.accountId === potentialFriendId);
            if (potentialFriendSocket) {
                potentialFriendSocket.emit(
                    FriendEvents.UpdatePendingFriends,
                    this.friendManager.calculatePendingFriends(potentialFriendSocket.data.accountId),
                );
            }
        });
        socket.emit(FriendEvents.UpdateSentFriends, this.friendManager.calculateSentFriends(socket.data.accountId));
    }

    @SubscribeMessage(FriendEvents.OptRequest)
    async optRequest(@ConnectedSocket() socket: Socket, @MessageBody('senderFriendId') senderFriendId: string, @MessageBody('isOpt') isOpt: boolean) {
        await this.friendManager.optFriendRequest(socket.data.accountId, senderFriendId, isOpt);
        this.server.fetchSockets().then((sockets) => {
            const senderFriendSocket = sockets.find((s) => s.data.accountId === senderFriendId);
            if (senderFriendSocket) {
                senderFriendSocket.emit(FriendEvents.UpdateSentFriends, this.friendManager.calculateSentFriends(senderFriendSocket.data.accountId));
            }
        });
        socket.emit(FriendEvents.UpdatePendingFriends, this.friendManager.calculatePendingFriends(socket.data.accountId));
    }

    @SubscribeMessage(FriendEvents.OptFavorite)
    async optFavorite(@ConnectedSocket() socket: Socket, @MessageBody('friendId') friendId: string, @MessageBody('isFavorite') isFavorite: boolean) {
        await this.friendManager.optFavorite(socket.data.accountId, friendId, isFavorite);
        socket.emit(FriendEvents.UpdateFriends, this.accountManager.users.get(socket.data.accountId).profile.friends);
    }

    @SubscribeMessage(ChannelEvents.SendGlobalMessage)
    handleGlobalMessage(@ConnectedSocket() socket: Socket, @MessageBody() message: string) {
        const chat: Chat = this.messageManager.createMessage(
            this.accountManager.connectedUsers.get(socket.data.accountId).credentials.username,
            message,
            socket.data.accountId,
        );
        this.globalChatLog.chat.push(chat);

        socket.emit(ChannelEvents.GlobalMessage, { ...chat, tag: MessageTag.Sent });
        socket.broadcast.emit(ChannelEvents.GlobalMessage, { ...chat, tag: MessageTag.Received });
    }

    @SubscribeMessage(ChannelEvents.UpdateLog)
    handleUpdateLog(@ConnectedSocket() socket: Socket) {
        socket.emit(ChannelEvents.UpdateLog, this.globalChatLog);
    }

    afterInit() {
        instrument(this.server, {
            auth: false,
            mode: 'development',
        });
    }

    handleConnection(@ConnectedSocket() socket: Socket) {
        socket.data.accountId = socket.handshake.query.id as string;
        this.accountManager.logConnection(socket.data.accountId, true);
        this.logger.log(`AUTH de ${socket.data.accountId}`);
    }

    handleDisconnect(@ConnectedSocket() socket: Socket) {
        this.logger.log(`DEATH de ${socket.data.accountId}`);
        this.accountManager.logConnection(socket.data.accountId, false);
        this.accountManager.disconnection(socket.data.accountId);
    }
}
