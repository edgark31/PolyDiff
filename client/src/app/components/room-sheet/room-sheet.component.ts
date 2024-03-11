/* eslint-disable @angular-eslint/no-empty-lifecycle-method */
/* eslint-disable @typescript-eslint/no-magic-numbers */
<<<<<<< HEAD
import { Component, Input } from '@angular/core';
import { Router } from '@angular/router';
import { Lobby } from '@common/game-interfaces';
=======
import { Component, Input } from '@angular/core';
import { Router } from '@angular/router';
import { Lobby } from '@common/game-interfaces';
>>>>>>> da6e2ae70b41808961a15d73e3d16e8c17e11682

@Component({
    selector: 'app-room-sheet',
    templateUrl: './room-sheet.component.html',
    styleUrls: ['./room-sheet.component.scss'],
})
export class RoomSheetComponent {
    @Input() lobby: Lobby;
    numberOfDifferences: number;

    constructor(public router: Router) {
        this.numberOfDifferences = 0;
    }
}
