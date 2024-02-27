import { Component } from '@angular/core';
import { MatDialogRef } from '@angular/material/dialog';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import Ajv from 'ajv';
import addFormats from 'ajv-formats';
import { WelcomeService } from './../../services/welcome-service/welcome.service';

const ajv = new Ajv();
addFormats(ajv);
@Component({
    selector: 'app-import-Dialog',
    templateUrl: './import-Dialog.component.html',
    styleUrls: ['./import-Dialog.component.scss'],
})
export class ImportDialogComponent {
    imageData: string;
    constructor(
        public welcomeService: WelcomeService,
        private dialogRef: MatDialogRef<ImportDialogComponent>,
        private clientSocket: ClientSocketService,
    ) {}

    // async function getImageInput (input:any) {
    //     if (input && input.files && input.files[0]) {
    //       const image = await new Promise((resolve) => {
    //         const reader = new FileReader();
    //         reader.onload = (e) => resolve(reader.result);
    //         reader.readAsDataURL(input.files[0]);
    //       });
    //       return image;
    //     }
    //   }

    async onFileSelected(event: Event): Promise<void> {
        const inputElement = event.target as HTMLInputElement;
        const selectedFile = inputElement.files?.[0];
        if (selectedFile) {
            const fileReader = new FileReader();
            fileReader.onload = () => {
                const imageBase64 = fileReader.result as string;

                // Valider l'image ici
                // if (!this.validateImage(selectedFile.name, selectedFile.size)) {
                //     this.errorMessage = 'Image invalide';
                //     this.isSuccessful = false;
                //     return;
                // }

                // Traitement de l'image ici
                // Par exemple, l'afficher dans une balise <img>
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
    chooseImage(image: string): void {
        this.welcomeService.selectAvatar = 'assets/' + image;
        this.dialogRef.close();
    }
}
