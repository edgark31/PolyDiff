/* eslint-disable max-params */
import { AfterViewInit, Component, OnDestroy } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { GameManagerService } from '@app/services/game-manager-service/game-manager.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { AccountEvents } from '@common/enums';
import { ChatMessageGlobal, RankedPlayer } from '@common/game-interfaces';
import { TranslateService } from '@ngx-translate/core';
import { Subject } from 'rxjs';
import { ModalAdminComponent } from './../../components/modal-admin/modal-admin.component';
@Component({
    selector: 'app-main-page',
    templateUrl: './main-page.component.html',
    styleUrls: ['./main-page.component.scss'],
})
export class MainPageComponent implements AfterViewInit, OnDestroy {
    messages: ChatMessageGlobal[];
    rankedPlayers: RankedPlayer[];
    timeStamp: number;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    intervalId: any;
    private onDestroy$: Subject<void>;

    constructor(
        private readonly clientSocket: ClientSocketService,
        private readonly gameManager: GameManagerService,
        private readonly router: Router,
        private dialog: MatDialog,
        public translate: TranslateService,
        public welcomeService: WelcomeService,
    ) {
        this.messages = [];
        this.rankedPlayers = [];
        this.onDestroy$ = new Subject();
    }

    manageGames(): void {
        const dialogRef = this.dialog.open(ModalAdminComponent);
        dialogRef.afterOpened().subscribe(() => {
            document.querySelector('html')?.classList.remove('cdk-global-scrollblock');
        });
    }

    ngOnDestroy(): void {
        this.onDestroy$.next();
        this.onDestroy$.complete();
        clearInterval(this.intervalId);
    }

    personnalizationpage() {
        this.router.navigate(['/personalization']);
    }

    ngAfterViewInit(): void {
        // if (this.clientSocket.isSocketAlive() === undefined) {
        //     this.router.navigate(['/login']);
        // }
        this.handleMessages();
        if (this.clientSocket.isSocketAlive('auth') === undefined) return;
        this.clientSocket.authSocket.off(AccountEvents.GlobalRanking);
        this.clientSocket.on('auth', AccountEvents.GlobalRanking, (rankedPlayers: RankedPlayer[]) => {
            this.rankedPlayers = rankedPlayers.slice(0, 3 + 2);
            this.timeStamp = new Date().getTime();
        });
        this.intervalId = setInterval(() => {
            this.clientSocket.send('auth', AccountEvents.GlobalRanking);
        }, 10000);
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
