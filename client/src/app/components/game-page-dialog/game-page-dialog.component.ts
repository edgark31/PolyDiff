import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { GameManagerService } from '@app/services/game-manager-service/game-manager.service';
import { ReplayService } from '@app/services/replay-service/replay.service';
import { GamePageEvent } from '@common/enums';
import { Lobby } from '@common/game-interfaces';
@Component({
    selector: 'app-game-page-dialog',
    templateUrl: './game-page-dialog.component.html',
    styleUrls: ['./game-page-dialog.component.scss'],
})
export class GamePageDialogComponent {
    isReplayPaused: boolean;
    constructor(
        @Inject(MAT_DIALOG_DATA) public data: { action: GamePageEvent; message: string; lobby: Lobby; isReplayMode: boolean },
        private readonly gameManager: GameManagerService,
        private readonly replayService: ReplayService,
        private router: Router,
    ) {
        this.isReplayPaused = false;
    }

    abandonGame(): void {
        this.gameManager.abandonGame(this.data.lobby.lobbyId as string);
        this.router.navigate(['/game-mode']);
    }

    leaveGame(): void {
        this.replayService.resetReplay();
    }

    replay() {
        this.replayService.startReplay();
        this.replayService.restartTimer();
    }
}
