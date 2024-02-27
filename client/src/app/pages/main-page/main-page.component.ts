import { AfterViewInit, Component, OnDestroy } from '@angular/core';
import { Router } from '@angular/router';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { GameManagerService } from '@app/services/game-manager-service/game-manager.service';
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

    constructor(
        private readonly clientSocket: ClientSocketService,
        private readonly gameManager: GameManagerService,
        private readonly router: Router,
    ) {
        this.messages = [];
        this.onDestroy$ = new Subject();
    }

    ngOnDestroy(): void {
        this.onDestroy$.next();
        this.onDestroy$.complete();
        if (this.clientSocket.isSocketAlive() !== undefined) {
            this.clientSocket.disconnect();
        }
    }

    personnalizationpage() {
        this.router.navigate(['/personalization']);
    }

    ngAfterViewInit(): void {
        if (this.clientSocket.isSocketAlive() === undefined) {
            this.router.navigate(['/login']);
        }
        this.handleMessages();
    }

    addRightSideMessage(text: string) {
        this.gameManager.sendGlobalMessage(text);
    }

    private handleMessages(): void {
        this.gameManager.globalMessage$.subscribe((chatMessageGlobal: ChatMessageGlobal) => {
            this.messages.push(chatMessageGlobal);
        });
    }
}
