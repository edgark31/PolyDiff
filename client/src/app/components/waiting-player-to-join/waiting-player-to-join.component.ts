/* eslint-disable max-len */
import { Component, Inject, OnDestroy, OnInit } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material/dialog';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
import { GameCardActions, Lobby } from '@common/game-interfaces';
import { Subscription } from 'rxjs';

@Component({
    selector: 'app-waiting-player-to-join',
    templateUrl: './waiting-player-to-join.component.html',
    styleUrls: ['./waiting-player-to-join.component.scss'],
})
export class WaitingPlayerToJoinComponent implements OnInit, OnDestroy {
    playerName: string;
    refusedMessage: string;
    countdown: number;
    actions: typeof GameCardActions;
    private playerNamesSubscription?: Subscription;
    private countdownSubscription: Subscription;
    private deletedGameIdSubscription: Subscription;

    // Services are needed for the dialog and dialog needs to talk to the parent component
    // eslint-disable-next-line max-params
    constructor(
        @Inject(MAT_DIALOG_DATA) private data: { lobby: Lobby; username: string },
        private readonly roomManagerService: RoomManagerService, // private dialogRef: MatDialogRef<WaitingPlayerToJoinComponent>, // private readonly router: Router,
    ) {
        this.playerName = this.data.username;
        this.actions = GameCardActions;
    }

    ngOnInit(): void {
        if (!this.data.lobby.lobbyId) return;
        // this.roomManagerService.getJoinedPlayerNames(this.data.gameId);
        // this.loadPlayerNamesList();
    }

    refusePlayer() {
        this.roomManagerService.optPlayer(this.data.lobby.lobbyId as string, this.data.username, false);
    }

    acceptPlayer() {
        this.roomManagerService.optPlayer(this.data.lobby.lobbyId as string, this.data.username, true);
    }

    ngOnDestroy(): void {
        this.playerNamesSubscription?.unsubscribe();
        this.countdownSubscription?.unsubscribe();
        this.deletedGameIdSubscription?.unsubscribe();
    }

    // private loadPlayerNamesList(): void {
    //     this.playerNamesSubscription = this.roomManagerService.joinedPlayerNamesByGameId$
    //         .pipe(filter((playerNamesList) => !!playerNamesList))
    //         .subscribe((playerNamesList) => {
    //             this.playerNames = playerNamesList;
    //         });
    // }

    // private countDownBeforeClosing() {
    //     this.countdown = COUNTDOWN_TIME;
    //     const countdown$ = interval(WAITING_TIME).pipe(takeWhile(() => this.countdown > 0));
    //     const countdownObserver = {
    //         next: () => {
    //             this.countdown--;
    //             this.refusedMessage = `La fiche de jeu a été supprimée . Vous serez redirigé dans ${this.countdown} secondes`;
    //         },
    //         complete: () => {
    //             this.dialogRef.close();
    //         },
    //     };
    //     this.countdownSubscription = countdown$.subscribe(countdownObserver);
    // }
}
