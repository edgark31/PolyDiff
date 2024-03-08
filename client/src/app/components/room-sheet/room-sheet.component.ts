import { Component } from '@angular/core';
import { Router } from '@angular/router';

@Component({
    selector: 'app-room-sheet',
    templateUrl: './room-sheet.component.html',
    styleUrls: ['./room-sheet.component.scss'],
})
export class RoomSheetComponent {
    mode: string = 'Mode';
    numberOfDifferences: number = 5; // Replace with actual logic to get the number
    players: string[] = ['Player1', 'Player2']; // Replace with actual logic to get player names
    maxPlayers: number = 4;

    constructor(public router: Router) {}

    joinRoom() {
        // Logic to join the room
    }

    isRoomFull(): boolean {
        return this.players.length >= this.maxPlayers;
    }
}
