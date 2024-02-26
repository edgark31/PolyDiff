import { Injectable } from '@nestjs/common';
import fs from 'fs';

@Injectable()
export class ImageManagerService {
    private assetsFolder: string;

    constructor() {
        this.assetsFolder = '../../assets';
    }

    convert(imageName: string): string {
        const image = fs.readFileSync(`${this.assetsFolder}/${imageName}`);
        const base64Image = image.toString('base64');
        return base64Image;
    }

    save(imageName: string, base64: string): void {
        const image = Buffer.from(base64, 'base64');
        fs.writeFileSync(`${this.assetsFolder}/${imageName}`, image);
    }

    deleteImage() {
        // fs.rmSync(`${this.assetsFolder}/${this.imageNameTest}`);
        return 'Hello World!';
    }
}
