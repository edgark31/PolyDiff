/* eslint-disable @typescript-eslint/no-magic-numbers */
import { Component, Input } from '@angular/core';
import { Router } from '@angular/router';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
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

    constructor(public router: Router, private readonly roomManagerService: RoomManagerService) {
        this.playerNames = ['Player 1', 'Player 2', 'Player 3', 'Player 4'];
        this.gameMode = this.roomManagerService.gameMode;
    }

    isRoomFull(): boolean {
        return this.playerNames.length >= 4;
    }
}
