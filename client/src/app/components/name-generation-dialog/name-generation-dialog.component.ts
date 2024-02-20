import { Component } from '@angular/core';
import { MatDialogRef } from '@angular/material/dialog';
import { RegistrationPageComponent } from '@app/pages/registration-page/registration-page.component';
import { NameGenerationService } from '@app/services/name-generation-service/name-generation-service.service';

@Component({
    selector: 'app-config-dialog',
    templateUrl: './name-generation-dialog.component.html',
    styleUrls: ['./name-generation-dialog.component.scss'],
})
export class NameGenerationDialogComponent {
    language: string;
    languages: string[] = ['français', 'anglais'];
    containsAnimal: boolean;
    containsNumber: boolean;

    constructor(private readonly nameGeneration: NameGenerationService, private readonly dialogRef: MatDialogRef<RegistrationPageComponent>) {
        this.language = 'français';
        this.containsAnimal = false;
        this.containsNumber = false;
    }

    onSubmit(): void {
        const languageIndex = this.language === 'francais' ? 0 : 1;
        this.nameGeneration.generateName(languageIndex, this.containsAnimal, this.containsNumber);
        this.dialogRef.close(this.nameGeneration.generatedName);
    }
}
