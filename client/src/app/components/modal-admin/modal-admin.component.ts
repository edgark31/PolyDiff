/* eslint-disable max-params */
import { Component, EventEmitter, Inject, Output } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { TranslateService } from '@ngx-translate/core';

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

    constructor(
        // eslint-disable-next-line @typescript-eslint/ban-types
        @Inject(MAT_DIALOG_DATA) public data: {},
        public translate: TranslateService,
        private welcomeService: WelcomeService,
        private router: Router,
        public dialogRef: MatDialogRef<ModalAdminComponent>,
        public clientSocketService: ClientSocketService,
    ) {}

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
