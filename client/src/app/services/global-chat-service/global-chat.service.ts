import { Injectable } from '@angular/core';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { ChannelEvents, FriendEvents, MessageTag } from '@common/enums';
import { Chat, ChatLog } from '@common/game-interfaces';
import { Subject } from 'rxjs';

@Injectable({
    providedIn: 'root',
})
export class GlobalChatService {
    private message: Subject<Chat>;

    constructor(private readonly clientSocketService: ClientSocketService, private readonly welcomeService: WelcomeService) {
        this.message = new Subject<Chat>();
    }

    get message$() {
        return this.message.asObservable();
    }

    updateLog(): void {
        this.clientSocketService.send('auth', ChannelEvents.UpdateLog);
    }

    sendMessage(message: string): void {
        this.clientSocketService.send('auth', ChannelEvents.SendGlobalMessage, message);
    }

    manage(): void {
        this.message = new Subject<Chat>();

        this.clientSocketService.on('auth', FriendEvents.ShareScore, (chat: Chat) => {
            chat.tag = MessageTag.Received;
            this.message.next(chat);
        });

        this.clientSocketService.on('auth', ChannelEvents.GlobalMessage, (chat: Chat) => {
            this.message.next(chat);
        });

        this.clientSocketService.on('auth', ChannelEvents.UpdateLog, (chatLog: ChatLog) => {
            // if (chatLog.channelName === 'global') {
            chatLog.chat.forEach((chat) => {
                this.message.next({
                    ...chat,
                    tag: chat.name === this.welcomeService.account.credentials.username ? MessageTag.Sent : MessageTag.Received,
                });
            });
        });
    }

    off(): void {
        this.clientSocketService.authSocket.off(ChannelEvents.GlobalMessage);
        this.clientSocketService.authSocket.off(ChannelEvents.UpdateLog);
        this.clientSocketService.authSocket.off(FriendEvents.ShareScore);
        this.message.unsubscribe();
    }
}
