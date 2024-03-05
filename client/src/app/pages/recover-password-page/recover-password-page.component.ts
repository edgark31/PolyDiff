/* eslint-disable @typescript-eslint/no-magic-numbers */
import { Component } from '@angular/core';
import { FormControl, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { GameManagerService } from '@app/services/game-manager-service/game-manager.service';
import { ConnectionEvents } from '@common/enums';

@Component({
    selector: 'app-recover-password-page',
    templateUrl: './recover-password-page.component.html',
    styleUrls: ['./recover-password-page.component.scss'],
})
export class RecoverPasswordPageComponent {
    recoverPasswordForm = new FormGroup({
        username: new FormControl('', [Validators.required, Validators.minLength(3), Validators.maxLength(15)]),
        password: new FormControl('', [Validators.required, Validators.minLength(3), Validators.maxLength(15)]),
    });

    constructor(
        private readonly gameManager: GameManagerService,
        private readonly clientSocket: ClientSocketService,
        private readonly router: Router,
    ) {}

    onSubmit() {
        if (this.recoverPasswordForm.value.username && this.recoverPasswordForm.value.password) {
            this.clientSocket.connect(this.recoverPasswordForm.value.username, 'auth');
            this.clientSocket.on('auth', ConnectionEvents.UserConnectionRequest, (isConnected: boolean) => {
                if (isConnected) {
                    this.router.navigate(['/home']);
                }
            });
            this.gameManager.manageSocket();
            this.gameManager.username = this.recoverPasswordForm.value.username;
        }
    }
}
