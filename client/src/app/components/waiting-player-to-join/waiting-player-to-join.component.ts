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
    constructor(@Inject(MAT_DIALOG_DATA) private data: { lobby: Lobby; username: string }, private readonly roomManagerService: RoomManagerService) {
        this.playerName = this.data.username;
        this.actions = GameCardActions;
    }

    ngOnInit(): void {
        if (!this.data.lobby.lobbyId) return;
        // this.roomManagerService.getJoinedPlayerNames(this.data.gameId);
        // this.loadPlayerNamesList();
    }

    // ngDoCheck(): void {
    //     console.log(this.roomManagerService.dialogRefs.size);
    //     if (this.data.lobby.players.length === 4 && this.roomManagerService.dialogRefs.size !== 0) {
    //         console.log('aaaaaaaaaaaaaaaa');
    //         this.roomManagerService.optPlayer(this.data.lobby.lobbyId as string, this.data.username, false);
    //     }
    // }

    refusePlayer() {
        this.roomManagerService.optPlayer(this.data.lobby.lobbyId as string, this.data.username, false);
        this.roomManagerService.dialogRefs.delete(this.data.username);
    }

    acceptPlayer() {
        this.roomManagerService.optPlayer(this.data.lobby.lobbyId as string, this.data.username, true);
        this.roomManagerService.dialogRefs.delete(this.data.username);
    }

    ngOnDestroy(): void {
        this.playerNamesSubscription?.unsubscribe();
        this.countdownSubscription?.unsubscribe();
        this.deletedGameIdSubscription?.unsubscribe();
    }
}
