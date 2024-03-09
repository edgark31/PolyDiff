/* eslint-disable @typescript-eslint/no-magic-numbers */
import { Component, Input } from '@angular/core';
import { Router } from '@angular/router';
import { Game } from '@common/game-interfaces';

@Component({
    selector: 'app-room-sheet',
    templateUrl: './room-sheet.component.html',
    styleUrls: ['./room-sheet.component.scss'],
})
export class RoomSheetComponent {
    @Input() game: Game;
    gameMode: string = 'Mode';
    numberOfDifferences: number;
    connectedPlayers: number;
    playerNames: string[] = [];

    constructor(public router: Router) {}

    isRoomFull(): boolean {
        return this.playerNames.length >= 4;
    }
}
