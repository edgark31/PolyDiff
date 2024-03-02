import { Injectable } from '@nestjs/common';
import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class ImageManagerService {
    private assetsFolder: string;

    constructor() {
        this.assetsFolder = path.join(__dirname, '../../..', 'assets');
    }

    convert(imageName: string): string {
        const image = fs.readFileSync(`${this.assetsFolder}/${imageName}`);
        const base64Image = image.toString('base64');
        return base64Image;
    }

    save(imageName: string, base64: string): void {
        const image = Buffer.from(base64, 'base64');
        fs.writeFileSync(`${this.assetsFolder}/${imageName}.png`, image);
    }

    deleteImage(imageName: string) {
        fs.unlinkSync(`${this.assetsFolder}/${imageName}.png`);
        return 'Hello World!';
    }
}
