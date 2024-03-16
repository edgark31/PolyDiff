import { Component, EventEmitter, Inject, Output } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
import { Lobby } from '@common/game-interfaces';

@Component({
    selector: 'app-modal-access-match',
    templateUrl: './modal-access-match.component.html',
    styleUrls: ['./modal-access-match.component.scss'],
})
export class ModalAccessMatchComponent {
    @Output() loginEvent = new EventEmitter<string>();

    codeAccess: string;
    isPasswordWrong: boolean = false;
    isAccessPassInvalid: boolean = true;

    constructor(
        // private welcomeService: WelcomeService,
        private router: Router,
        public dialogRef: MatDialogRef<ModalAccessMatchComponent>,
        public clientSocketService: ClientSocketService,
        public roomManager: RoomManagerService,
        @Inject(MAT_DIALOG_DATA) public data: Lobby,
    ) {}

    onSubmitAccess() {
        if (this.codeAccess === this.data.password) {
            this.isAccessPassInvalid = false;
            console.log(this.data.lobbyId);
            this.roomManager.joinRoomAcces(this.data.lobbyId ? this.data.lobbyId : '', this.codeAccess);
            this.router.navigate(['/waiting-room']);
            this.dialogRef.close();
        }
    }

    onCancel(): void {
        this.dialogRef.close();
    }
}
