/* eslint-disable @typescript-eslint/no-magic-numbers */
import { Injectable } from '@angular/core';
import { IMG_HEIGHT, IMG_TYPE_BMP, IMG_TYPE_JPEG, IMG_TYPE_JPG, IMG_TYPE_PNG, IMG_WIDTH, VALID_SIZE } from '@app/constants/image';

@Injectable({
    providedIn: 'root',
})
export class ValidationService {
    emailFormat: string = '';
    passwordStrength: string = '';

    async isImageValid(file: File): Promise<boolean> {
        return (
            (file.type === IMG_TYPE_BMP && (await this.isImageSizeValid(file)) && file.size === VALID_SIZE) ||
            (file.type === IMG_TYPE_PNG && (await this.isImageSizeValid(file)) && file.size === VALID_SIZE) ||
            (file.type === IMG_TYPE_JPG && (await this.isImageSizeValid(file)) && file.size === VALID_SIZE) ||
            (file.type === IMG_TYPE_JPEG && (await this.isImageSizeValid(file)) && file.size === VALID_SIZE)
        );
    }

    isEmailValid(email: string): boolean {
        const emailRegex = new RegExp('^[\\w-]+(\\.[\\w-]+)*@([\\w-]+\\.)+[a-zA-Z]{2,7}$');
        if (emailRegex.test(email) && email) {
            this.emailFormat = 'Oui';
            return true;
        } else {
            this.emailFormat = 'Non';
            return false;
        }
    }

    updatePasswordStrength(password: string): void {
        let strength = '';
        if (new RegExp('[a-zA-Z0-9]').test(password) && password.length < 10) {
            strength = 'Faible';
        } else if (password.length >= 10 || new RegExp('[$,!,&]').test(password)) {
            if (password.length > 10 && new RegExp('[$,!,&]').test(password)) {
                strength = 'Élevé';
            } else {
                strength = 'Moyen';
            }
        } else {
            strength = 'Faible';
        }
        this.passwordStrength = strength;
    }

    private async isImageSizeValid(file: File): Promise<boolean> {
        const image = await createImageBitmap(file);
        return image.width === IMG_WIDTH && image.height === IMG_HEIGHT;
    }
}
