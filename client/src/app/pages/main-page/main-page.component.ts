import { AfterViewInit, Component, OnDestroy } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { GameManagerService } from '@app/services/game-manager-service/game-manager.service';
import { ChatMessageGlobal } from '@common/game-interfaces';
import { Subject } from 'rxjs';
import { ModalAdminComponent } from './../../components/modal-admin/modal-admin.component';
@Component({
    selector: 'app-main-page',
    templateUrl: './main-page.component.html',
    styleUrls: ['./main-page.component.scss'],
})
export class MainPageComponent implements AfterViewInit, OnDestroy {
    messages: ChatMessageGlobal[];

    private onDestroy$: Subject<void>;

    constructor(
        // cprivate readonly clientSocket: ClientSocketService,
        private readonly gameManager: GameManagerService,
        private readonly router: Router,
        private dialog: MatDialog,
    ) {
        this.messages = [];
        this.onDestroy$ = new Subject();
    }

    manageGames(): void {
        this.dialog.open(ModalAdminComponent);
    }

    ngOnDestroy(): void {
        this.onDestroy$.next();
        this.onDestroy$.complete();
        // if (this.clientSocket.isSocketAlive() !== undefined) {
        //     this.clientSocket.disconnect();
        // }
    }

    personnalizationpage() {
        this.router.navigate(['/personalization']);
    }

    ngAfterViewInit(): void {
        // if (this.clientSocket.isSocketAlive() === undefined) {
        //     this.router.navigate(['/login']);
        // }
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
