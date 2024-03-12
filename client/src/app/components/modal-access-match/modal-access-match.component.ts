import { Component, EventEmitter, Output } from '@angular/core';
import { MatDialogRef } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';

@Component({
    selector: 'app-modal-access-match',
    templateUrl: './modal-access-match.component.html',
    styleUrls: ['./modal-access-match.component.scss'],
})
export class ModalAccessMatchComponent {
    @Output() loginEvent = new EventEmitter<string>();

    codeAccess: string;
    isPasswordWrong: boolean = false;
    isAccessPassInvalid: boolean = true;

    constructor(
        // private welcomeService: WelcomeService,
        private router: Router,
        public dialogRef: MatDialogRef<ModalAccessMatchComponent>,
        public clientSocketService: ClientSocketService,
    ) {}

    // async onSubmitAccess() {
    //     this.welcomeService.validateAccess(this.codeAccess).then((isValid) => {
    //         if (isValid) {
    //             this.isAccessPassInvalid = false;
    //             this.router.navigate(['/Joining-room']);
    //             this.dialogRef.close();
    //         }
    //     });
    // }

    onSubmitAccess() {
        this.isAccessPassInvalid = false;
        this.dialogRef.close();
        this.router.navigate(['/waiting-room']);
    }

    onCancel(): void {
        this.dialogRef.close();
    }
}
