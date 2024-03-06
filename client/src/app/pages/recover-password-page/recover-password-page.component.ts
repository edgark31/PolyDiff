import { CommunicationService } from '@app/services/communication-service/communication.service';
/* eslint-disable @typescript-eslint/no-magic-numbers */
import { HttpErrorResponse } from '@angular/common/http';
import { Component } from '@angular/core';
import { FormControl, FormGroup, Validators } from '@angular/forms';

@Component({
    selector: 'app-recover-password-page',
    templateUrl: './recover-password-page.component.html',
    styleUrls: ['./recover-password-page.component.scss'],
})
export class RecoverPasswordPageComponent {
    feedback: string;
    recoverPasswordForm = new FormGroup({
        username: new FormControl('', [Validators.required, Validators.minLength(3), Validators.maxLength(15)]),
        password: new FormControl('', [Validators.required, Validators.minLength(3), Validators.maxLength(15)]),
        email: new FormControl('', []),
    });

    constructor(private readonly communication: CommunicationService) {}

    onSubmit() {
        // if (this.recoverPasswordForm.value.username && this.recoverPasswordForm.value.password) {
        //     this.clientSocket.connect(this.recoverPasswordForm.value.username, 'auth');
        //     this.clientSocket.on(ConnectionEvents.UserConnectionRequest, (isConnected: boolean) => {
        //         if (isConnected) {
        //             this.router.navigate(['/home']);
        //         }
        //     });
        //     this.gameManager.manageSocket();
        //     this.gameManager.username = this.recoverPasswordForm.value.username;
        // }
        if (this.recoverPasswordForm.value.email) {
            this.communication.sendMail(this.recoverPasswordForm.value.email).subscribe({
                // eslint-disable-next-line @typescript-eslint/no-empty-function
                next: () => {},
                error: (error: HttpErrorResponse) => {
                    this.feedback = error.error || 'An unexpected error occurred. Please try again.';
                },
            });
        }
    }
}
