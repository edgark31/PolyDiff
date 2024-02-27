/* eslint-disable no-restricted-imports */
import { Component } from '@angular/core';
import { MatDialogRef } from '@angular/material/dialog';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { WelcomeService } from '../../services/welcome-service/welcome.service';

@Component({
    selector: 'app-import-dialog',
    templateUrl: './import-dialog.component.html',
    styleUrls: ['./import-dialog.component.scss'],
})
export class ImportDialogComponent {
    imageData: string;
    constructor(
        public welcomeService: WelcomeService,
        private dialogRef: MatDialogRef<ImportDialogComponent>,
        private clientSocket: ClientSocketService,
    ) {}

    async onFileSelected(event: Event): Promise<void> {
        const inputElement = event.target as HTMLInputElement;
        const selectedFile = inputElement.files?.[0];
        if (selectedFile) {
            const fileReader = new FileReader();
            fileReader.onload = () => {
                const imageBase64 = fileReader.result as string;

                this.imageData = imageBase64;
            };
            fileReader.readAsDataURL(selectedFile);
            this.clientSocket.send('send-img', fileReader.result);
        }
    }

    onCancel(): void {
        this.dialogRef.close();
    }

    onImport(): void {
        this.welcomeService.selectAvatar = this.imageData;
        this.dialogRef.close();
    }
    chooseImage(id: string): void {
        this.welcomeService.selectAvatar = id;
        this.dialogRef.close();
    }
}
