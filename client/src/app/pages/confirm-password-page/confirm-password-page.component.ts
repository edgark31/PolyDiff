import { CommunicationService } from '@app/services/communication-service/communication.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
/* eslint-disable @typescript-eslint/no-magic-numbers */
import { HttpErrorResponse } from '@angular/common/http';
import { Component, OnInit } from '@angular/core';
import { FormControl, FormGroup, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';

@Component({
    selector: 'app-confirm-password-page',
    templateUrl: './confirm-password-page.component.html',
    styleUrls: ['./confirm-password-page.component.scss'],
})
export class ConfirmPasswordPageComponent implements OnInit {
    feedback: string;
    name: string;
    recoverPasswordForm = new FormGroup({
        confirmPassword: new FormControl('', [Validators.required, Validators.minLength(3), Validators.maxLength(15)]),
        password: new FormControl('', [Validators.required, Validators.minLength(3), Validators.maxLength(15)]),
    });

    constructor(
        private readonly communication: CommunicationService,
        private route: ActivatedRoute,
        private router: Router,
        public welcomeService: WelcomeService,
    ) {}

    ngOnInit() {
        this.name = this.route.snapshot.queryParams['token'];
    }
    onSubmit() {
        if (this.recoverPasswordForm.value.password === this.recoverPasswordForm.value.confirmPassword && this.recoverPasswordForm.value.password) {
            this.communication.modifyPassword(this.name, this.recoverPasswordForm.value.password).subscribe({
                next: () => {
                    this.router.navigate(['/login']);
                },
                error: (error: HttpErrorResponse) => {
                    this.feedback = error.error || 'An unexpected error occurred. Please try again.';
                },
            });
        }
    }
}
