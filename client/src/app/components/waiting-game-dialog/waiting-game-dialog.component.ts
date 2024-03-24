import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material/dialog';
import { Lobby } from '@common/game-interfaces';

@Component({
    selector: 'app-waiting-game-dialog',
    templateUrl: './waiting-game-dialog.component.html',
    styleUrls: ['./waiting-game-dialog.component.scss'],
})
export class WaitingGameDialogComponent {
    countdown: number;
    refusedMessage: string;
    constructor(@Inject(MAT_DIALOG_DATA) public data: { lobby: Lobby }) {}
}
