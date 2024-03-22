import { Component, EventEmitter, Input, Output } from '@angular/core';
import { Router } from '@angular/router';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
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
    @Output() private addGame: EventEmitter<string>;

    constructor(public router: Router, public welcome: WelcomeService) {
        // this.messages = [];
        this.add = new EventEmitter<string>();
        this.addLobby = new EventEmitter<string>();
        this.addGame = new EventEmitter<string>();
    }

    goPageChatGame(): void {
        this.welcome.onChatGame = !this.welcome.onChatGame;
    }

    goPageChatLobby(): void {
        this.welcome.onChatLobby = !this.welcome.onChatLobby;
    }
    onAdd(inputField: { value: string }): void {
        switch (this.router.url) {
            case '/chat': {
                if (inputField.value) {
                    this.add.emit(inputField.value.trim());
                    inputField.value = '';
                }

                break;
            }
            case '/waiting-room': {
                if (!this.welcome.onChatLobby) {
                    if (inputField.value) {
                        this.addLobby.emit(inputField.value.trim());
                        inputField.value = '';
                    }
                } else {
                    if (inputField.value) {
                        this.add.emit(inputField.value.trim());
                        inputField.value = '';
                    }
                }
                break;
            }
            case '/game': {
                if (!this.welcome.onChatGame) {
                    if (inputField.value) {
                        this.addGame.emit(inputField.value.trim());
                        inputField.value = '';
                    }
                } else {
                    if (inputField.value) {
                        this.add.emit(inputField.value.trim());
                        inputField.value = '';
                    }
                }

                break;
            }
            // No default
        }
    }

    onClose(): void {
        if (this.router.url === '/chat') {
            this.router.navigate(['/home']);
        }
    }
}
