import { CommunicationService } from '@app/services/communication-service/communication.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
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

    constructor(private readonly communication: CommunicationService, private readonly welcomeService: WelcomeService) {}

    onSubmit() {
        if (this.recoverPasswordForm.value.email) {
            this.communication.sendMail(this.recoverPasswordForm.value.email).subscribe({
                // eslint-disable-next-line @typescript-eslint/no-empty-function
                next: () => {
                    this.welcomeService.setlinkValid(true);
                },
                error: (error: HttpErrorResponse) => {
                    this.feedback = error.error || 'An unexpected error occurred. Please try again.';
                },
            });
        }
        console.log(this.welcomeService.isLinkValid + 'scxsdqldjskj');
    }
}
