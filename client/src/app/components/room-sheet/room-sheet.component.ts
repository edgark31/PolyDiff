/* eslint-disable @angular-eslint/no-empty-lifecycle-method */
/* eslint-disable @typescript-eslint/no-magic-numbers */
import { Component, Input } from '@angular/core';
import { MatDialog, MatDialogRef } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { ModalAccessMatchComponent } from '@app/components/modal-access-match/modal-access-match.component';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
import { GameModes } from '@common/enums';
import { Lobby } from '@common/game-interfaces';
import { TranslateService } from '@ngx-translate/core';

@Component({
    selector: 'app-room-sheet',
    templateUrl: './room-sheet.component.html',
    styleUrls: ['./room-sheet.component.scss'],
})
export class RoomSheetComponent {
    @Input() lobby: Lobby;
    gameModes: typeof GameModes = GameModes;
    private roomPasswordRef: MatDialogRef<ModalAccessMatchComponent> | null = null;
    // eslint-disable-next-line max-params
    constructor(
        public router: Router, // private readonly dialog: MatDialog
        public roomManager: RoomManagerService,
        private readonly dialog: MatDialog,
        public translate: TranslateService,
    ) {}

    manageGames(lobby: Lobby): void {
        if (this.lobby.isAvailable && this.lobby.players.length < 4) {
            if (!lobby.password) {
                this.roomManager.joinRoom(lobby.lobbyId ? lobby.lobbyId : '');
                this.router.navigate(['/waiting-room']);
            } else {
                if (this.roomPasswordRef) {
                    this.roomPasswordRef.close();
                    this.roomPasswordRef = null;
                }
                this.roomPasswordRef = this.dialog.open(ModalAccessMatchComponent, {
                    data: lobby,
                });
                this.roomPasswordRef.afterClosed().subscribe(() => {
                    this.roomPasswordRef = null;
                });
            }
        } else if (!this.lobby.isAvailable) {
            this.roomManager.joinRoomObserver(lobby.lobbyId ? lobby.lobbyId : '');

            // rentrer en tant qu'observateur
        }
    }

    feedbackLobby(): string {
        if (this.lobby.players.length === 4 && this.lobby.isAvailable) return 'Partie pleine';
        return '';
    }
}
