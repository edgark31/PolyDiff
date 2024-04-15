import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material/dialog';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { Lobby } from '@common/game-interfaces';
import { TranslateService } from '@ngx-translate/core';

@Component({
    selector: 'app-waiting-game',
    templateUrl: './waiting-game.component.html',
    styleUrls: ['./waiting-game.component.scss'],
})
export class WaitingGameComponent {
    wait: string;
    constructor(public welcome: WelcomeService, @Inject(MAT_DIALOG_DATA) public data: { lobby: Lobby }, public translate: TranslateService) {}
}
