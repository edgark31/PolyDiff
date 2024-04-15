/* eslint-disable max-params */
/* eslint-disable @typescript-eslint/no-empty-function */
/* eslint-disable @typescript-eslint/no-magic-numbers */
import { HttpErrorResponse } from '@angular/common/http';
import { Component } from '@angular/core';
import { FormControl, FormGroup, Validators } from '@angular/forms';
import { MatDialog, MatDialogConfig } from '@angular/material/dialog';
import { Router } from '@angular/router';
// eslint-disable-next-line import/no-unresolved
import { ImportDialogComponent } from '@app/components/import-dialog-box/import-dialog-box.component';
import { NameGenerationDialogComponent } from '@app/components/name-generation-dialog/name-generation-dialog.component';
import { CommunicationService } from '@app/services/communication-service/communication.service';
import { NameGenerationService } from '@app/services/name-generation-service/name-generation-service.service';
import { ValidationService } from '@app/services/validation-service/validation.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
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
    feedback: string;
    password: string;
    confirmedPassword: string;
    email: string;
    username: string;
    isRequestPending: boolean = false;

    constructor(
        private readonly communication: CommunicationService,
        private readonly router: Router,
        private readonly dialog: MatDialog,
        private readonly nameGeneration: NameGenerationService,
        public validation: ValidationService,
        public welcomeService: WelcomeService,
    ) {
        this.feedback = '';
    }

    onSubmit() {
        if (
            this.registrationForm.value.username &&
            this.registrationForm.value.email &&
            this.validation.isEmailValid(this.email) &&
            this.registrationForm.value.password
        ) {
            this.feedback = '';
            this.creds = {
                username: this.registrationForm.value.username,
                email: this.registrationForm.value.email,
                password: this.registrationForm.value.password,
            };
            this.communication.createUser(this.creds, this.welcomeService.chooseImage ? this.welcomeService.selectLocal : '1').subscribe({
                next: () => {
                    if (this.welcomeService.chooseImage) {
                        this.router.navigate(['/login']);
                        console.log('NEXT');
                    }
                },
                error: (error: HttpErrorResponse) => {
                    this.feedback = error.error || 'An unexpected error occurred. Please try again.';
                },
            });

            if (!this.welcomeService.chooseImage && this.feedback === '')
                setTimeout(() => {
                    this.welcomeService.onUpdateAvatar(this.creds.username);
                    console.log('timeout');
                    this.router.navigate(['/login']);
                }, 1000);
        }
    }

    openNameGenerationDialog() {
        this.dialog
            .open(NameGenerationDialogComponent, new MatDialogConfig())
            .afterClosed()
            .subscribe((username: string) => {
                this.registrationForm.controls.username.setValue(username);
                this.registrationForm.value.username = this.nameGeneration.generatedName;
            });
    }

    openAvatarDialog(choose: boolean) {
        this.dialog
            .open(ImportDialogComponent, new MatDialogConfig())
            .afterClosed()
            .subscribe(() => {});
        this.welcomeService.chooseImage = choose;
    }
}
