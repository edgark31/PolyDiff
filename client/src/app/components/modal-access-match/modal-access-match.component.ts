import { Component, EventEmitter, Inject, OnInit, Output } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialog, MatDialogRef } from '@angular/material/dialog';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
import { LobbyEvents } from '@common/enums';
import { Lobby } from '@common/game-interfaces';
import { JoinedPlayerDialogComponent } from '@app/components/joined-player-dialog/joined-player-dialog.component';
import { Router } from '@angular/router';

@Component({
    selector: 'app-modal-access-match',
    templateUrl: './modal-access-match.component.html',
    styleUrls: ['./modal-access-match.component.scss'],
})
export class ModalAccessMatchComponent implements OnInit {
    @Output() loginEvent = new EventEmitter<string>();
    accept: boolean;
    codeAccess: string;
    isPasswordWrong: boolean = false;
    isAccessPassInvalid: boolean = true;

    // eslint-disable-next-line max-params
    constructor(
        // private welcomeService: WelcomeService,
        private router: Router,
        public dialog: MatDialog,
        public dialogRef: MatDialogRef<ModalAccessMatchComponent>,
        public clientSocketService: ClientSocketService,
        public roomManager: RoomManagerService,
        @Inject(MAT_DIALOG_DATA) public data: Lobby,
    ) {}

    ngOnInit(): void {
        this.clientSocketService.on('lobby', LobbyEvents.RequestAccess, () => {
            this.dialog.open(JoinedPlayerDialogComponent, {
                data: { lobbyId: this.data.lobbyId as string },
                disableClose: true,
                panelClass: 'dialog',
            });
        });
        this.clientSocketService.on('lobby', LobbyEvents.NotifyGuest, (isPlayerAccepted: boolean) => {
            if (isPlayerAccepted) {
                this.isAccessPassInvalid = false;
                this.roomManager.joinRoomAcces(this.data.lobbyId ? this.data.lobbyId : '', this.codeAccess);
                this.router.navigate(['/waiting-room']);
                this.dialog.closeAll();
            } else {
                // vous avez ete refuse
            }
        });
    }

    onSubmitAccess() {
        if (this.codeAccess === this.data.password) {
            this.roomManager.sendRequestToJoinRoom(this.data.lobbyId as string, this.data.password as string);
            this.dialogRef.close();
        }
    }

    onCancel(): void {
        this.dialogRef.close();
    }
}
