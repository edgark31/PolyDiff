import { AfterViewInit, Component, OnDestroy } from '@angular/core';
import { GameManagerService } from '@app/services/game-manager-service/game-manager.service';
import { MessageTag } from '@common/enums';
import { ChatMessageGlobal } from '@common/game-interfaces';
import { Subject } from 'rxjs';
@Component({
    selector: 'app-main-page',
    templateUrl: './main-page.component.html',
    styleUrls: ['./main-page.component.scss'],
})
export class MainPageComponent implements AfterViewInit, OnDestroy {
    messages: ChatMessageGlobal[];

    private onDestroy$: Subject<void>;

    constructor(private readonly gameManager: GameManagerService) {
        this.messages = [];
        this.gameManager.manageSocket();
        this.onDestroy$ = new Subject();
    }

    ngOnDestroy(): void {
        this.onDestroy$.next();
        this.onDestroy$.complete();
        this.gameManager.removeAllListeners();
    }

    ngAfterViewInit(): void {
        this.handleMessages();
    }

    addRightSideMessage(text: string) {
        this.messages.push({ tag: MessageTag.Sent, message: text, userName: 'You', timestamp: new Date().toLocaleTimeString() });
        this.gameManager.sendGlobalMessage(text);
    }

    private handleMessages(): void {
        this.gameManager.globalMessage$.subscribe((chatMessageGlobal: ChatMessageGlobal) => {
            this.messages.push(chatMessageGlobal);
        });
    }
}
