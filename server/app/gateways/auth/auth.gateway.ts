import { AccountManagerService } from '@app/services/account-manager/account-manager.service';
import { MessageManagerService } from '@app/services/message-manager/message-manager.service';
import { ChannelEvents } from '@common/enums';
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
        this.globalChatLog = { chat: [], channelName: 'Global' };
    }

    @SubscribeMessage(ChannelEvents.SendGlobalMessage)
    handleGlobalMessage(@ConnectedSocket() socket: Socket, @MessageBody() message: string) {
        const chat: Chat = this.messageManager.createMessage(socket.data.username, message);
        this.globalChatLog.chat.push(chat);
        this.server.emit(ChannelEvents.GlobalMessage, chat);
    }

    afterInit() {
        instrument(this.server, {
            auth: false,
            mode: 'development',
        });
    }

    handleConnection(@ConnectedSocket() socket: Socket) {
        const userName = socket.handshake.query.name as string;
        socket.data.username = userName;

        socket.emit(ChannelEvents.UpdateLog, this.globalChatLog);
        this.logger.log(`AUTH de ${userName}`);
    }

    handleDisconnect(@ConnectedSocket() socket: Socket) {
        this.logger.log(`DEAUTH de ${socket.data.username}`);
        this.accountManager.deconnexion(socket.data.username);
    }
}
