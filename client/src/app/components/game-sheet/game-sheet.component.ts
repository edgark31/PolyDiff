// Id comes from database to allow _id
/* eslint-disable no-underscore-dangle */
import { Component, Input, OnDestroy, OnInit } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { DomSanitizer, SafeResourceUrl } from '@angular/platform-browser';
import { Router } from '@angular/router';
import { DeleteResetConfirmationDialogComponent } from '@app/components/delete-reset-confirmation-dialog/delete-reset-confirmation-dialog.component';
import { Actions } from '@app/enum/delete-reset-actions';
import { NavigationService } from '@app/services/navigation-service/navigation.service';
// import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
import { GameCard } from '@common/game-interfaces';
import { Subscription } from 'rxjs';

@Component({
    selector: 'app-game-sheet',
    templateUrl: './game-sheet.component.html',
    styleUrls: ['./game-sheet.component.scss'],
})
export class GameSheetComponent implements OnDestroy, OnInit {
    @Input() game: GameCard;
    url: SafeResourceUrl;
    actions: typeof Actions;
    private isAvailable: boolean;
    private roomSoloIdSubscription: Subscription;
    private roomAvailabilitySubscription: Subscription;
    private roomOneVsOneIdSubscription: Subscription;

    // Services are needed for the dialog and dialog needs to talk to the parent component
    // eslint-disable-next-line max-params
    constructor(
        private readonly dialog: MatDialog,
        public router: Router,
        // private readonly roomManagerService: RoomManagerService,
        private sanitizer: DomSanitizer,
        private readonly navigationService: NavigationService,
    ) {
        this.actions = Actions;
    }
    ngOnInit(): void {
        this.url = this.sanitizer.bypassSecurityTrustUrl('data:image/png;base64,' + this.game.thumbnail);
    }


    getMode(): string {
        return this.navigationService.getPreviousUrl();
    }

    isAvailableToJoin(): boolean {
        return this.isAvailable;
    }

    openConfirmationDialog(actions: Actions): void {
        this.dialog.open(DeleteResetConfirmationDialogComponent, {
            data: { actions, gameId: this.game._id },
            disableClose: true,
            panelClass: 'dialog',
        });
    }

    setGameId(): void {
        this.navigationService.setGameId(this.game._id);
        this.navigationService.setNDifferences(this.game.nDifference as number);
    }

    ngOnDestroy(): void {
        this.roomSoloIdSubscription?.unsubscribe();
        this.roomAvailabilitySubscription?.unsubscribe();
        this.roomOneVsOneIdSubscription?.unsubscribe();
    }
}
