import { WelcomeService } from '@app/services/welcome-service/welcome.service';
/* eslint-disable @typescript-eslint/no-magic-numbers */
import { HttpErrorResponse } from '@angular/common/http';
import { AfterViewInit, Component } from '@angular/core';
import { FormControl, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { CommunicationService } from '@app/services/communication-service/communication.service';
import { GameManagerService } from '@app/services/game-manager-service/game-manager.service';
import { Account, Credentials } from '@common/game-interfaces';

@Component({
    selector: 'app-login-page',
    templateUrl: './login-page.component.html',
    styleUrls: ['./login-page.component.scss'],
})
export class LoginPageComponent implements AfterViewInit {
    loginForm = new FormGroup({
        username: new FormControl('', [Validators.required, Validators.minLength(3), Validators.maxLength(15)]),
        password: new FormControl('', [Validators.required, Validators.minLength(3), Validators.maxLength(15)]),
    });
    creds: Credentials;
    feedback: string;

    constructor(
        private readonly gameManager: GameManagerService,
        private readonly clientSocket: ClientSocketService,
        private readonly communication: CommunicationService,
        private readonly router: Router,
        private readonly welcomeservice: WelcomeService,
    ) {
        this.feedback = '';
    }

    ngAfterViewInit(): void {
        // this.clientSocket.disconnect();
    }

    onSubmit() {
        if (this.loginForm.value.username && this.loginForm.value.password) {
            this.creds = {
                username: this.loginForm.value.username,
                password: this.loginForm.value.password,
            };
            this.communication.login(this.creds).subscribe({
                next: (account: Account) => {
                    this.clientSocket.connect(account.credentials.username, 'auth');
                    console.log(account.credentials.username);
                    this.welcomeservice.account = account;
                    // this.gameManager.manageSocket();
                    this.gameManager.username = account.credentials.username;
                    this.welcomeservice.account.profile.avatar = `http://localhost:3000/${this.gameManager.username}.png`;
                    this.router.navigate(['/home']);
                },
                error: (error: HttpErrorResponse) => {
                    this.feedback = error.error || 'An unexpected error occurred. Please try again.';
                },
            });
        }
    }
}
