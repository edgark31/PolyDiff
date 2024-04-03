import { Component, OnDestroy, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { GlobalChatService } from '@app/services/global-chat-service/global-chat.service';
import { Chat } from '@common/game-interfaces';
import { TranslateService } from '@ngx-translate/core';
import { Subscription } from 'rxjs';

@Component({
    selector: 'app-chat-page',
    templateUrl: './chat-page.component.html',
    styleUrls: ['./chat-page.component.scss'],
})
export class ChatPageComponent implements OnInit, OnDestroy {
    chatSubscription: Subscription;
    messages: Chat[] = [];

    constructor(
        private readonly clientSocketService: ClientSocketService,
        private readonly globalChatService: GlobalChatService,
        private readonly router: Router,
        public translate: TranslateService,
    ) {}

    ngOnInit(): void {
        if (this.clientSocketService.isSocketAlive('auth')) {
            this.globalChatService.manage();
            this.globalChatService.updateLog();
            this.chatSubscription = this.globalChatService.message$.subscribe((message: Chat) => {
                this.receiveMessage(message);
            });
        }
    }

    back(): void {
        this.router.navigate(['/home']);
    }

    sendMessage(message: string): void {
        this.globalChatService.sendMessage(message);
    }

    receiveMessage(chat: Chat): void {
        this.messages.push(chat);
    }

    ngOnDestroy(): void {
        if (this.clientSocketService.isSocketAlive('auth')) {
            this.globalChatService.off();
        }
        this.chatSubscription?.unsubscribe();
    }
}
