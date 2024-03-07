import { Component, EventEmitter, Output } from '@angular/core';
import { MatDialogRef } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';

@Component({
    selector: 'app-modal-admin',
    templateUrl: './modal-admin.component.html',
    styleUrls: ['./modal-admin.component.scss'],
})
export class ModalAdminComponent {
    @Output() loginEvent = new EventEmitter<string>();

    password: string;
    isPasswordWrong: boolean = false;
    showModal: boolean = false;

    constructor(private welcomeService: WelcomeService, private router: Router, public dialogRef: MatDialogRef<ModalAdminComponent>) {}

    async onSubmit() {
        this.welcomeService.validate(this.password).then((isValid) => {
            if (isValid) {
                this.isPasswordWrong = false;
                this.router.navigate(['/admin']);
                this.dialogRef.close();
            } else {
                this.isPasswordWrong = true;
            }
        });
    }

    onCancel(): void {
        this.dialogRef.close();
    }
}
