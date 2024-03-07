import { AfterViewInit, Component, OnDestroy } from '@angular/core';
import { GlobalChatService } from '@app/services/global-chat-service/global-chat.service';
import { Chat } from '@common/game-interfaces';

@Component({
    selector: 'app-chat-page',
    templateUrl: './chat-page.component.html',
    styleUrls: ['./chat-page.component.scss'],
})
export class ChatPageComponent implements AfterViewInit, OnDestroy {
    messages: Chat[] = [];

    constructor(private readonly globalChatService: GlobalChatService) {}

    ngAfterViewInit(): void {
        this.globalChatService.manage();
        this.globalChatService.updateLog();
        this.globalChatService.message$.subscribe((message: Chat) => {
            this.receiveMessage(message);
        });
    }

    sendMessage(message: string): void {
        this.globalChatService.sendMessage(message);
    }

    receiveMessage(chat: Chat): void {
        this.messages.push(chat);
    }

    ngOnDestroy(): void {
        this.globalChatService.off();
    }
}
