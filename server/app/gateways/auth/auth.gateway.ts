import { AccountManagerService } from '@app/services/account-manager/account-manager.service';
import { MessageManagerService } from '@app/services/message-manager/message-manager.service';
import { AccountEvents, ChannelEvents, MessageTag } from '@common/enums';
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
    @WebSocketServer() private server: Server;
    globalChatLog: ChatLog;

    constructor(
        private readonly logger: Logger,
        private readonly accountManager: AccountManagerService,
        private readonly messageManager: MessageManagerService,
    ) {
        this.globalChatLog = { chat: [], channelName: 'global' };
    }

    @SubscribeMessage(AccountEvents.UserUpdate)
    retrivesUsers() {
        this.server.emit(AccountEvents.UserUpdate, Array.from(this.accountManager.users.values()));
    }

    @SubscribeMessage(AccountEvents.UserCreate)
    handleAccountCreate() {
        this.server.emit(AccountEvents.UserUpdate, Array.from(this.accountManager.users.values()));
    }

    @SubscribeMessage(AccountEvents.UserDelete)
    handleAccountDelete() {
        this.server.emit(AccountEvents.UserUpdate, Array.from(this.accountManager.users.values()));
    }

    @SubscribeMessage(ChannelEvents.SendGlobalMessage)
    handleGlobalMessage(@ConnectedSocket() socket: Socket, @MessageBody() message: string) {
        const chat: Chat = this.messageManager.createMessage(
            this.accountManager.connectedUsers.get(socket.data.accountId).credentials.username,
            message,
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
        this.accountManager.logConnexion(socket.data.accountId, true);
        this.logger.log(`AUTH de ${socket.data.accountId}`);
    }

    handleDisconnect(@ConnectedSocket() socket: Socket) {
        this.logger.log(`DEAUTH de ${socket.data.accountId}`);
        this.accountManager.logConnexion(socket.data.accountId, false);
        this.accountManager.deconnexion(socket.data.accountId);
    }
}
