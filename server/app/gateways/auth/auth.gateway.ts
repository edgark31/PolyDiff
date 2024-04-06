/* eslint-disable @typescript-eslint/no-explicit-any */
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
    async updateUsers(@ConnectedSocket() socket: Socket) {
        socket.emit(UserEvents.UpdateUsers, await this.friendManager.queryUsers()); // User[]
    }

    // ---------------------- LES GETTERS de friends INITIAUX --------------------------------
    @SubscribeMessage(FriendEvents.UpdateFriends)
    updateFriends(@ConnectedSocket() socket: Socket) {
        this.updateIsOnline(socket);
    }

    @SubscribeMessage(FriendEvents.UpdateSentFriends)
    updateSentFriends(@ConnectedSocket() socket: Socket) {
        socket.emit(FriendEvents.UpdateSentFriends, this.friendManager.calculateSentFriends(socket.data.accountId));
    }

    @SubscribeMessage(FriendEvents.UpdatePendingFriends)
    updatePendingFriends(@ConnectedSocket() socket: Socket) {
        socket.emit(FriendEvents.UpdatePendingFriends, this.friendManager.calculatePendingFriends(socket.data.accountId));
    }

    @SubscribeMessage(FriendEvents.UpdateFoFs)
    updateFoFs(@ConnectedSocket() socket: Socket, @MessageBody('friendId') friendId: string) {
        socket.emit(FriendEvents.UpdateFoFs, this.accountManager.users.get(friendId).profile.friends);
    }

    @SubscribeMessage(FriendEvents.UpdateCommonFriends)
    updateCommonFriends(@ConnectedSocket() socket: Socket, @MessageBody('friendId') friendId: string) {
        const ownAccount = this.accountManager.users.get(socket.data.accountId);
        const friendAccount = this.accountManager.users.get(friendId);
        socket.emit(FriendEvents.UpdateCommonFriends, this.friendManager.calculateCommonFriends(ownAccount, friendAccount));
    }

    // ---------------------- LES SCÉNARIOS --------------------------------
    @SubscribeMessage(FriendEvents.SendRequest)
    async sendRequest(@ConnectedSocket() socket: Socket, @MessageBody('potentialFriendId') potentialFriendId: string) {
        if (this.accountManager.users.get(socket.data.accountId).profile.friends.find((f) => f.accountId === potentialFriendId)) return;
        if (this.accountManager.users.get(potentialFriendId).profile.friendRequests.find((f) => f === socket.data.accountId)) return;
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
        if (this.accountManager.users.get(socket.data.accountId).profile.friends.find((f) => f.accountId === senderFriendId)) return;
        if (this.accountManager.users.get(senderFriendId).profile.friends.find((f) => f.accountId === socket.data.accountId)) return;
        await this.friendManager.optFriendRequest(socket.data.accountId, senderFriendId, isOpt);
        this.server.fetchSockets().then((sockets) => {
            const senderFriendSocket = sockets.find((s) => s.data.accountId === senderFriendId);
            if (senderFriendSocket) {
                senderFriendSocket.emit(FriendEvents.UpdateSentFriends, this.friendManager.calculateSentFriends(senderFriendSocket.data.accountId));
            }
            sockets.map((s) => {
                this.updateFriends(s as any);
            });
        });
        socket.emit(FriendEvents.UpdatePendingFriends, this.friendManager.calculatePendingFriends(socket.data.accountId));
        this.server.emit(UserEvents.UpdateUsers, await this.friendManager.queryUsers());
    }

    @SubscribeMessage(FriendEvents.OptFavorite)
    async optFavorite(@ConnectedSocket() socket: Socket, @MessageBody('friendId') friendId: string, @MessageBody('isFavorite') isFavorite: boolean) {
        await this.friendManager.optFavorite(socket.data.accountId, friendId, isFavorite);
        this.updateFriends(socket);
    }

    @SubscribeMessage(FriendEvents.DeleteFriend)
    async deleteFriend(@ConnectedSocket() socket: Socket, @MessageBody('friendId') friendId: string) {
        await this.friendManager.deleteFriend(socket.data.accountId, friendId);
        this.server.fetchSockets().then((sockets) => {
            const friendSocket = sockets.find((s) => s.data.accountId === friendId);
            if (friendSocket) {
                this.updateFriends(friendSocket as any);
            }
        });
        this.updateFriends(socket);
        this.server.emit(UserEvents.UpdateUsers, await this.friendManager.queryUsers());
    }

    @SubscribeMessage('HardResetFriend')
    async hardResetFriend() {
        await this.friendManager.deleteAllFriends();
        this.server.emit(UserEvents.UpdateUsers, await this.friendManager.queryUsers());
    }

    // ---------------------- SHARE SCORE --------------------------------

    @SubscribeMessage(FriendEvents.ShareScore)
    shareScore(@ConnectedSocket() socket: Socket, @MessageBody('friendId') friendId: string, @MessageBody('score') score: number) {
        this.server.fetchSockets().then((sockets) => {
            const friendSocket = sockets.find((s) => s.data.accountId === friendId);
            if (friendSocket) {
                friendSocket.emit(
                    FriendEvents.ShareScore,
                    this.messageManager.createScoreMessage(socket.data.accountId, friendSocket.data.username, score),
                );
            }
        });
    }

    // ---------------------- GLOBAL RANKING --------------------------------
    @SubscribeMessage(AccountEvents.GlobalRanking)
    async globalRanking(@ConnectedSocket() socket: Socket) {
        socket.emit(AccountEvents.GlobalRanking, await this.accountManager.globalRanking());
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
        this.server.fetchSockets().then((sockets) => {
            sockets.forEach((s) => {
                this.updateIsOnline(s as any);
            });
        });
    }

    updateIsOnline(socket: Socket) {
        const friends = this.accountManager.users.get(socket.data.accountId).profile.friends;
        this.accountManager.connectedUsers.forEach((value, key) => {
            if (friends.find((f) => f.accountId === key)) {
                friends.find((f) => f.accountId === key).isOnline = true;
            }
        });
        socket.emit(FriendEvents.UpdateFriends, friends);
    }
}
