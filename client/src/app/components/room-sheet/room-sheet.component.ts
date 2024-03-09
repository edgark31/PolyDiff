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
    mode: string = 'Mode';
    numberOfDifferences: number = 5; // Replace with actual logic to get the number
    players: string[] = ['Player1', 'Player2', 'player2', 'player4']; // Replace with actual logic to get player names
    maxPlayers: number = 4;

    constructor(public router: Router) {}

    joinRoom() {
        // Logic to join the room
    }

    isRoomFull(): boolean {
        return this.players.length >= this.maxPlayers;
    }
}
