/* eslint-disable @typescript-eslint/no-magic-numbers */
import { Component } from '@angular/core';
import { FormControl, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { CommunicationService } from '@app/services/communication-service/communication.service';
import { Credentials } from '@common/game-interfaces';

@Component({
    selector: 'app-registration-page',
    templateUrl: './registration-page.component.html',
    styleUrls: ['./registration-page.component.scss'],
})
export class RegistrationPageComponent {
    registrationForm = new FormGroup({
        username: new FormControl('', [Validators.required, Validators.minLength(3), Validators.maxLength(15)]),
        email: new FormControl('', [Validators.required, Validators.email]),
        password: new FormControl('', [Validators.required, Validators.minLength(3), Validators.maxLength(15)]),
    });
    creds: Credentials;

    constructor(private readonly communication: CommunicationService, private readonly router: Router) {}

    onSubmit() {
        if (this.registrationForm.value.username && this.registrationForm.value.email && this.registrationForm.value.password) {
            this.creds = {
                username: this.registrationForm.value.username,
                email: this.registrationForm.value.email,
                password: this.registrationForm.value.password,
            };
            this.communication.createUser(this.creds).subscribe(() => {
                this.router.navigate(['/login']);
            });
        }
    }
}
