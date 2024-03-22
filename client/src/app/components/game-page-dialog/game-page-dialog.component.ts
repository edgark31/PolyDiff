import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { GameManagerService } from '@app/services/game-manager-service/game-manager.service';
import { ReplayService } from '@app/services/replay-service/replay.service';
import { GamePageEvent } from '@common/enums';
@Component({
    selector: 'app-game-page-dialog',
    templateUrl: './game-page-dialog.component.html',
    styleUrls: ['./game-page-dialog.component.scss'],
})
export class GamePageDialogComponent {
    isReplayPaused: boolean;
    constructor(
        @Inject(MAT_DIALOG_DATA) public data: { action: GamePageEvent; message: string; isReplayMode: boolean },
        private readonly gameManager: GameManagerService,
        private readonly replayService: ReplayService,
        private router: Router,
        private clientSocket: ClientSocketService,
    ) {
        this.isReplayPaused = false;
    }

    abandonGame(): void {
        this.gameManager.abandonGame();
        this.clientSocket.disconnect('game');
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
