import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material/dialog';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { Lobby } from '@common/game-interfaces';

@Component({
    selector: 'app-waiting-game-dialog',
    templateUrl: './waiting-game-dialog.component.html',
    styleUrls: ['./waiting-game-dialog.component.scss'],
})
export class WaitingGameDialogComponent {
    countdown: number;
    refusedMessage: string;
    wait: string;
    constructor(public welcome: WelcomeService, @Inject(MAT_DIALOG_DATA) public data: { lobby: Lobby }) {
        if (this.welcome.account.profile.language === 'en') this.wait = 'La partie va commencer sous peu...';
        else this.wait = 'The game will start shortly....';
    }

    getLangage(): string {
        console.log('yo');
        if (this.welcome.account.profile.language === 'en') return 'La partie va commencer sous peu...';
        else return 'The game will start shortly....';
    }
}
