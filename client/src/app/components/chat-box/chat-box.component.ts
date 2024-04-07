import { Component, EventEmitter, Input, Output } from '@angular/core';
import { Router } from '@angular/router';
import { NavigationService } from '@app/services/navigation-service/navigation.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { Chat } from '@common/game-interfaces';
import { TranslateService } from '@ngx-translate/core';

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

    constructor(
        public router: Router,
        public welcome: WelcomeService,
        public navigationService: NavigationService,
        public translate: TranslateService,
    ) {
        // this.messages = [];
        this.add = new EventEmitter<string>();
        this.addLobby = new EventEmitter<string>();
        this.addGame = new EventEmitter<string>();
    }

    getMode(): string {
        return this.navigationService.getPreviousUrl();
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
