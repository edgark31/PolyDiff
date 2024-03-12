import { Component, EventEmitter, Input, Output } from '@angular/core';
import { Router } from '@angular/router';
import { Chat } from '@common/game-interfaces';

@Component({
    selector: 'app-chat-box',
    templateUrl: './chat-box.component.html',
    styleUrls: ['./chat-box.component.scss'],
})
export class ChatBoxComponent {
    @Input() messages: Chat[];
    @Input() gameMode: string;
    @Input() isReplaying: boolean;
    @Output() private add: EventEmitter<string>;
    @Output() private addLobby: EventEmitter<string>;

    constructor(private readonly router: Router) {
        this.messages = [];
        this.add = new EventEmitter<string>();
        this.addLobby = new EventEmitter<string>();
    }

    onAdd(inputField: { value: string }): void {
        if (this.router.url === '/chat') {
            if (inputField.value) {
                this.add.emit(inputField.value.trim());
                inputField.value = '';
            }
        } else if (this.router.url === '/waiting-room') {
            if (inputField.value) {
                this.addLobby.emit(inputField.value.trim());
                inputField.value = '';
            }
        }
    }

    onClose(): void {
        if (this.router.url === '/chat') {
            this.router.navigate(['/home']);
        }
    }
}
