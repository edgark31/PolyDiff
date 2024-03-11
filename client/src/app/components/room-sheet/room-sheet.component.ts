/* eslint-disable @angular-eslint/no-empty-lifecycle-method */
/* eslint-disable @typescript-eslint/no-magic-numbers */
import { Component, Input } from '@angular/core';
import { Router } from '@angular/router';
import { GameModes } from '@common/enums';
import { Lobby } from '@common/game-interfaces';

@Component({
    selector: 'app-room-sheet',
    templateUrl: './room-sheet.component.html',
    styleUrls: ['./room-sheet.component.scss'],
})
export class RoomSheetComponent {
    @Input() lobby: Lobby;
    numberOfDifferences: number;
    gameModes: typeof GameModes = GameModes;

    constructor(
        public router: Router, // private readonly dialog: MatDialog
    ) {
        this.numberOfDifferences = 0;
    }

    manageGames(lobby: Lobby): void {
        this.router.navigate(['/waiting-room']);
        // // //     console.log(lobby.lobbyId);
        // // //     if (lobby.lobbyId) {
        // // //         this.dialog.open(ModalAccessMatchComponent, {
        // // //             data: { match: lobby },
        // // //         });
        // // //     }
        // // //     else
    }
}
