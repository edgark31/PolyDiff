import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { GameManagerService } from '@app/services/game-manager-service/game-manager.service';
import { ReplayService } from '@app/services/replay-service/replay.service';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
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
        public roomManager: RoomManagerService,
    ) {
        this.isReplayPaused = false;

        this.roomManager.isOrganizer = false;
    }

    abandonGame(): void {
        this.gameManager.abandonGame(this.data.lobby.lobbyId as string);
        console.log('On y va');

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
