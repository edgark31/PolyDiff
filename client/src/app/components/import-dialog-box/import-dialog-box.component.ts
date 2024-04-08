import { Component } from '@angular/core';
import { MatDialogRef } from '@angular/material/dialog';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { TranslateService } from '@ngx-translate/core';

@Component({
    selector: 'app-import-dialog-box',
    templateUrl: './import-dialog-box.component.html',
    styleUrls: ['./import-dialog-box.component.scss'],
})
export class ImportDialogComponent {
    imageData: string;
    choice: string;
    constructor(
        public welcomeService: WelcomeService,
        private dialogRef: MatDialogRef<ImportDialogComponent>,
        private clientSocket: ClientSocketService,
        public translate: TranslateService,
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
            this.clientSocket.send('auth', 'send-img', fileReader.result);
        }
    }

    onCancel(): void {
        this.dialogRef.close();
    }

    onImport(): void {
        if (this.welcomeService.chooseImage) this.choice = `http://localhost:3000/avatar/default${this.welcomeService.selectLocal}.png`;
        else this.choice = this.imageData;
        this.welcomeService.selectAvatarRegister = this.choice;
        this.dialogRef.close();
        this.verifyAccount();
    }

    verifyAccount(): void {
        if (!this.welcomeService.account) this.welcomeService.selectAvatarRegister = this.choice;
        else this.welcomeService.selectAvatar = this.choice;
    }
    chooseImage(id: string): void {
        this.welcomeService.selectLocal = id;
    }

    setUpColor(id: string): string {
        return this.welcomeService.selectLocal === id ? 'red' : 'white';
    }
}
