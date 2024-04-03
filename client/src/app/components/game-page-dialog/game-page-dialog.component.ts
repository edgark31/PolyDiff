import { Component, Inject, OnInit } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialog } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { GameManagerService } from '@app/services/game-manager-service/game-manager.service';
import { ReplayService } from '@app/services/replay-service/replay.service';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
import { GamePageEvent } from '@common/enums';
import { Lobby } from '@common/game-interfaces';
import { TranslateService } from '@ngx-translate/core';
import { ShareModalComponent } from '../share-modal/share-modal.component';
@Component({
    selector: 'app-game-page-dialog',
    templateUrl: './game-page-dialog.component.html',
    styleUrls: ['./game-page-dialog.component.scss'],
})
export class GamePageDialogComponent implements OnInit {
    isReplayPaused: boolean;
    // eslint-disable-next-line max-params
    constructor(
        @Inject(MAT_DIALOG_DATA) public data: { action: GamePageEvent; message: string; lobby: Lobby; isReplayMode: boolean },
        private readonly gameManager: GameManagerService,
        private readonly replayService: ReplayService,
        public translate: TranslateService,
        public roomManager: RoomManagerService,
        public router: Router,
        public clientSocket: ClientSocketService,
        public dialog: MatDialog,
    ) {
        this.isReplayPaused = false;

        this.roomManager.isOrganizer = false;
        this.roomManager.isObserver = false;
    }

    ngOnInit(): void {}
    abandonGame(): void {
        this.gameManager.abandonGame(this.data.lobby.lobbyId as string);
        this.router.navigate(['/game-mode']);
    }

    openShareScoreFriend(showShareFriend: boolean): void {
        console.log('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
        this.dialog.open(ShareModalComponent, {
            data: { showShareFriend, players: this.data.lobby.players },
        });
    }

    leaveGame(): void {
        this.replayService.resetReplay();
    }

    replay() {
        this.replayService.startReplay();
        this.replayService.restartTimer();
    }
}
