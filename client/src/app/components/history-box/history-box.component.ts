import { Component, OnDestroy, OnInit } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { DeleteResetConfirmationDialogComponent } from '@app/components/delete-reset-confirmation-dialog/delete-reset-confirmation-dialog.component';
import { Actions } from '@app/enum/delete-reset-actions';
import { CommunicationService } from '@app/services/communication-service/communication.service';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
import { GameHistory } from '@common/game-interfaces';
import { TranslateService } from '@ngx-translate/core';
import { Subscription } from 'rxjs';

@Component({
    selector: 'app-history-box',
    templateUrl: './history-box.component.html',
    styleUrls: ['./history-box.component.scss'],
})
export class HistoryBoxComponent implements OnInit, OnDestroy {
    gameHistory: GameHistory[];
    private isGameHistoryReloadNeededSubscription: Subscription;
    // eslint-disable-next-line max-params
    constructor(
        private readonly roomManagerService: RoomManagerService,
        private readonly communicationService: CommunicationService,
        private readonly dialog: MatDialog,
        public translate: TranslateService,
    ) {
        this.gameHistory = [];
    }

    ngOnInit(): void {
        this.loadHistory();
        this.handleHistoryUpdate();
    }

    openConfirmationDialog(): void {
        this.dialog.open(DeleteResetConfirmationDialogComponent, {
            data: { actions: Actions.DeleteHistory },
            disableClose: true,
            panelClass: 'dialog',
        });
    }

    ngOnDestroy(): void {
        this.isGameHistoryReloadNeededSubscription.unsubscribe();
    }

    private loadHistory(): void {
        this.communicationService.loadGameHistory().subscribe((history: GameHistory[]) => {
            this.gameHistory = history;
        });
    }

    private handleHistoryUpdate(): void {
        this.isGameHistoryReloadNeededSubscription = this.roomManagerService.isGameHistoryReloadNeeded$.subscribe(
            (isGameHistoryReloadNeeded: boolean) => {
                if (isGameHistoryReloadNeeded) this.loadHistory();
            },
        );
    }
}
