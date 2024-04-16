import { Component, Input } from '@angular/core';
import { GameManagerService } from '@app/services/game-manager-service/game-manager.service';
import { ClientSideGame, GameConfigConst } from '@common/game-interfaces';
import { TranslateService } from '@ngx-translate/core';
@Component({
    selector: 'app-game-infos',
    templateUrl: './game-infos.component.html',
    styleUrls: ['./game-infos.component.scss'],
})
export class GameInfosComponent {
    @Input() game: ClientSideGame;
    @Input() isReplayAvailable: boolean;

    constructor(private readonly gameManager: GameManagerService, public translate: TranslateService) {}

    get gameConstants(): GameConfigConst {
        return this.gameManager.gameConstants;
    }
}
