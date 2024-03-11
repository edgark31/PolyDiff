import { Component, OnDestroy, OnInit } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { ModalAccessMatchComponent } from '@app/components/modal-access-match/modal-access-match.component';
// import { PlayerNameDialogBoxComponent } from '@app/components/player-name-dialog-box/player-name-dialog-box.component';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { GameManagerService } from '@app/services/game-manager-service/game-manager.service';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { GameModes } from '@common/enums';
import { Subscription } from 'rxjs';

@Component({
    selector: 'app-limited-time-page',
    templateUrl: './limited-time-page.component.html',
    styleUrls: ['./limited-time-page.component.scss'],
})
export class LimitedTimePageComponent implements OnDestroy, OnInit {
    gameModes: typeof GameModes;
    nPlayersConnected: number;
    private hasNoGameAvailableSubscription: Subscription;
    private roomIdSubscription: Subscription;
    private isLimitedCoopRoomAvailableSubscription: Subscription;
    constructor(
        public router: Router,
        private readonly roomManagerService: RoomManagerService,
        private readonly dialog: MatDialog,
        private readonly clientSocket: ClientSocketService,
        private readonly gameManager: GameManagerService,
        private readonly welcome: WelcomeService,
    ) {
        this.gameModes = GameModes;
        this.nPlayersConnected = 0;
    }

    ngOnInit(): void {
        this.clientSocket.connect(this.gameManager.username, 'lobby');
        this.roomManagerService.handleRoomEvents();
        this.welcome.isLimited = false;
        // this.openDialog();
    }

    manageGames(): void {
        this.dialog.open(ModalAccessMatchComponent);
    }

    ngOnDestroy(): void {
        this.clientSocket.disconnect('lobby');
        this.roomIdSubscription?.unsubscribe();
        this.isLimitedCoopRoomAvailableSubscription?.unsubscribe();
        this.hasNoGameAvailableSubscription?.unsubscribe();
        this.roomManagerService.removeAllListeners();
    }

    // private openDialog() {
    //     this.dialog
    //         .open(PlayerNameDialogBoxComponent, { disableClose: true, panelClass: 'dialog' })
    //         .afterClosed()
    //         .subscribe((playerName) => {
    //             if (playerName) {
    //                 this.playerName = playerName;
    //             } else {
    //                 this.router.navigate(['/']);
    //             }
    //         });
    // }
}
