import { AfterViewInit, Component } from '@angular/core';
import { Chat } from '@common/game-interfaces';

@Component({
    selector: 'app-chat-page',
    templateUrl: './chat-page.component.html',
    styleUrls: ['./chat-page.component.scss'],
})
export class ChatPageComponent implements AfterViewInit {
    messages: Chat[] = [];

    constructor() {}

    ngAfterViewInit(): void {}

    sendMessage(message: string): void {
        this.messages.push();
    }

    receiveMessage(message: Chat): void {
        this.messages.push(message);
    }
}
