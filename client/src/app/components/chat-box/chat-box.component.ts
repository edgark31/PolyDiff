import { Component, EventEmitter, Input, Output } from '@angular/core';
import { ChatMessageGlobal } from '@common/game-interfaces';

@Component({
    selector: 'app-chat-box',
    templateUrl: './chat-box.component.html',
    styleUrls: ['./chat-box.component.scss'],
})
export class ChatBoxComponent {
    @Input() messages: ChatMessageGlobal[];
    @Input() gameMode: string;
    @Input() isReplaying: boolean;
    @Output() private add: EventEmitter<string>;

    constructor() {
        this.messages = [];
        this.add = new EventEmitter<string>();
    }

    onAdd(inputField: { value: string }): void {
        if (inputField.value) {
            this.add.emit(inputField.value.trim());
            inputField.value = '';
        }
    }
}
