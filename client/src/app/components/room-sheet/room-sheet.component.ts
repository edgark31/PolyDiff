/* eslint-disable @angular-eslint/no-empty-lifecycle-method */
/* eslint-disable @typescript-eslint/no-magic-numbers */
import { Component, OnDestroy, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { Subscription } from 'rxjs';

@Component({
    selector: 'app-room-sheet',
    templateUrl: './room-sheet.component.html',
    styleUrls: ['./room-sheet.component.scss'],
})
export class RoomSheetComponent implements OnInit, OnDestroy {
    numberOfDifferences: number;
    playerNames: string[] = [];
    private playerNamesSubscription?: Subscription;
    private data: { roomId: string; gameId: string; isLimited: boolean };

    constructor(public router: Router) {
        this.playerNames = [];
        this.data = { roomId: '0', gameId: '', isLimited: true };
    }

    get isLimited(): boolean {
        return this.data.isLimited;
    }

    ngOnInit(): void {
        // this.roomManagerService.getJoinedPlayerNames(this.data.gameId);
    }

    ngOnDestroy(): void {
        this.playerNamesSubscription?.unsubscribe();
    }
}
