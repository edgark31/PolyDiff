import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material/dialog';
import { Lobby } from '@common/game-interfaces';
import { TranslateService } from '@ngx-translate/core';

@Component({
    selector: 'app-waiting-game-dialog',
    templateUrl: './waiting-game-dialog.component.html',
    styleUrls: ['./waiting-game-dialog.component.scss'],
})
export class WaitingGameDialogComponent {
    countdown: number;
    refusedMessage: string;
    constructor(@Inject(MAT_DIALOG_DATA) public data: { lobby: Lobby }, public translate: TranslateService) {}
}
