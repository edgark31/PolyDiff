/* eslint-disable @typescript-eslint/no-magic-numbers */
import { Component } from '@angular/core';
import { FormControl, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { UserDetails } from '@app/interfaces/user';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { CommunicationService } from '@app/services/communication-service/communication.service';
import { GameManagerService } from '@app/services/game-manager-service/game-manager.service';

@Component({
    selector: 'app-registration-page',
    templateUrl: './registration-page.component.html',
    styleUrls: ['./registration-page.component.scss'],
})
export class RegistrationPageComponent {
    loginForm = new FormGroup({
        username: new FormControl('', [Validators.required, Validators.minLength(3), Validators.maxLength(15)]),
        email: new FormControl('', [Validators.required, Validators.email]),
        password: new FormControl('', [Validators.required, Validators.minLength(3), Validators.maxLength(15)]),
    });
    userDetails: UserDetails;

    constructor(
        private readonly gameManager: GameManagerService,
        private readonly clientSocket: ClientSocketService,
        private readonly communication: CommunicationService,
        private readonly router: Router,
    ) {}

    onSubmit() {
        if (this.loginForm.value.username && this.loginForm.value.email && this.loginForm.value.password) {
            this.userDetails = {
                username: this.loginForm.value.username,
                email: this.loginForm.value.email,
                password: this.loginForm.value.password,
            };
            this.communication.createUser(this.userDetails).subscribe(() => {
                this.router.navigate(['/login']);
                this.clientSocket.connect();
                this.gameManager.manageSocket();
                this.gameManager.username = this.loginForm.value.username;
            });
        }
    }
}
