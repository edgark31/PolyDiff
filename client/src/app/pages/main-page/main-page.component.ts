import { AfterViewInit, Component, OnDestroy } from '@angular/core';
import { GameManagerService } from '@app/services/game-manager-service/game-manager.service';
import { MessageTag } from '@common/enums';
import { ChatMessage } from '@common/game-interfaces';
import { Subject, takeUntil } from 'rxjs';
@Component({
    selector: 'app-main-page',
    templateUrl: './main-page.component.html',
    styleUrls: ['./main-page.component.scss'],
})
export class MainPageComponent implements AfterViewInit, OnDestroy {
    messages: ChatMessage[];

    private onDestroy$: Subject<void>;

    constructor(private readonly gameManager: GameManagerService) {
        this.messages = [];
        this.gameManager.manageSocket();
        this.onDestroy$ = new Subject();
    }

    ngOnDestroy(): void {
        this.onDestroy$.next();
        this.onDestroy$.complete();
    }

    ngAfterViewInit(): void {
        this.handleMessages();
    }

    addRightSideMessage(text: string) {
        this.messages.push({ tag: MessageTag.Sent, message: text });
        this.gameManager.sendMessage(text);
    }

    private handleMessages(): void {
        this.gameManager.message$.pipe(takeUntil(this.onDestroy$)).subscribe((message: ChatMessage) => {
            this.messages.push(message);
        });
    }
}
