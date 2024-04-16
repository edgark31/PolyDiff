import { Component } from '@angular/core';
import { MatDialogRef } from '@angular/material/dialog';
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
    // eslint-disable-next-line max-params
    constructor(
        public welcomeService: WelcomeService,
        private dialogRef: MatDialogRef<ImportDialogComponent>,

        public translate: TranslateService,
    ) {}

    async onFileSelected(event: Event): Promise<void> {
        const inputElement = event.target as HTMLInputElement;
        const selectedFile = inputElement.files?.[0];
        if (selectedFile) {
            const fileReader = new FileReader();
            fileReader.onload = () => {
                const imageBase64 = fileReader.result as string;
                const imageFormat = imageBase64.split(';')[0].split(':')[1];

                const image = new Image();
                image.onload = () => {
                    const canvas = document.createElement('canvas');
                    const ctx = canvas.getContext('2d');
                    canvas.width = 128;
                    canvas.height = 128;
                    ctx?.drawImage(image, 0, 0, canvas.width, canvas.height);
                    const resizedImageBase64 = canvas.toDataURL(imageFormat);
                    this.imageData = resizedImageBase64;
                };
                image.src = imageBase64;
            };
            fileReader.readAsDataURL(selectedFile);
        }
    }

    onCancel(): void {
        this.dialogRef.close();
    }

    onImport(): void {
        if (this.welcomeService.chooseImage) this.choice = `http://34.95.3.182:3000/avatar/default${this.welcomeService.selectLocal}.png`;
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
