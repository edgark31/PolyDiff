/* eslint-disable max-len */
import { Component, Inject, OnDestroy, OnInit } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { COUNTDOWN_TIME, WAITING_TIME } from '@app/constants/constants';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
import { LobbyEvents } from '@common/enums';
import { Subscription, interval, takeWhile } from 'rxjs';

@Component({
    selector: 'app-joined-player-dialog',
    templateUrl: './joined-player-dialog.component.html',
    styleUrls: ['./joined-player-dialog.component.scss'],
})
export class JoinedPlayerDialogComponent implements OnInit, OnDestroy {
    countdown: number;
    refusedMessage: string;
    private countdownSubscription: Subscription;

    // Services are needed for the dialog and dialog needs to talk to the parent component
    // eslint-disable-next-line max-params
    constructor(
        @Inject(MAT_DIALOG_DATA) private data: { lobbyId: string; username: string },
        private readonly roomManagerService: RoomManagerService,
        private dialogRef: MatDialogRef<JoinedPlayerDialogComponent>,
        // private readonly router: Router,
        private readonly clientSocketService: ClientSocketService,
    ) {}

    ngOnInit(): void {
        this.handleRefusedPlayer();
        // this.handleAcceptedPlayer();
        // this.handleGameCardDelete();
        // this.handleCreateUndoCreation();
    }

    cancelJoining() {
        this.roomManagerService.cancelRequestToJoinRoom(this.data.lobbyId, this.data.username);
    }

    ngOnDestroy(): void {
        this.countdownSubscription?.unsubscribe();
    }

    private handleRefusedPlayer() {
        this.clientSocketService.on('lobby', LobbyEvents.NotifyGuest, (isPlayerAccepted: boolean) => {
            if (!isPlayerAccepted) {
                this.countDownBeforeClosing('Vous avez été refusé');
            }
        });
    }

    private countDownBeforeClosing(message: string) {
        this.countdown = COUNTDOWN_TIME;
        const countdown$ = interval(WAITING_TIME).pipe(takeWhile(() => this.countdown > 0));
        const countdownObserver = {
            next: () => {
                this.countdown--;
                this.refusedMessage = `${message}. Vous serez redirigé dans ${this.countdown} secondes`;
            },
            complete: () => {
                this.dialogRef.close();
            },
        };
        this.countdownSubscription = countdown$.subscribe(countdownObserver);
    }
}
