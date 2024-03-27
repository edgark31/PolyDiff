/* eslint-disable no-unused-expressions */
/* eslint-disable @typescript-eslint/no-unused-expressions */
/* eslint-disable max-params */
import { Game } from '@common/game-interfaces';
import { Injectable } from '@nestjs/common';
import * as fs from 'fs';
// eslint-disable-next-line import/no-unresolved
import Jimp from 'jimp';
import * as path from 'path';

@Injectable()
export class ImageManagerService {
    private assetsFolder: string;

    constructor() {
        this.assetsFolder = path.join(__dirname, '../../..', 'assets');
    }

    convert(imageName: string): string {
        const image = fs.readFileSync(`${this.assetsFolder}/avatar/${imageName}`);
        const base64Image = image.toString('base64');
        return base64Image;
    }

    save(imageName: string, base64: string): void {
        const image = Buffer.from(base64, 'base64');
        fs.writeFileSync(`${this.assetsFolder}/avatar/${imageName}.png`, image);
    }

    deleteImage(imageName: string) {
        fs.unlinkSync(`${this.assetsFolder}/${imageName}.png`);
        return 'Hello World!';
    }

    async limitedImage(game: Game, keepIndex: number): Promise<string> {
        const originalImage = await Jimp.read(Buffer.from(game.original.replace(/^data:image\/\w+;base64,/, ''), 'base64'));
        const modifiedImage = await Jimp.read(Buffer.from(game.modified.replace(/^data:image\/\w+;base64,/, ''), 'base64'));

        game.differences.splice(keepIndex, 1);

        game.differences.flat().forEach((coord) => {
            const { x, y } = coord;
            const originalPixelColor = originalImage.getPixelColor(x, y);
            modifiedImage.setPixelColor(originalPixelColor, x, y);
        });

        const newBuffer = await modifiedImage.getBufferAsync(Jimp.MIME_PNG);
        return newBuffer.toString('base64');
    }

    async observerImage(game: Game): Promise<string> {
        const originalImage = await Jimp.read(Buffer.from(game.original.replace(/^data:image\/\w+;base64,/, ''), 'base64'));
        const modifiedImage = await Jimp.read(Buffer.from(game.modified.replace(/^data:image\/\w+;base64,/, ''), 'base64'));

        const differencesSet = new Set(game.differences.flat().map(({ x, y }) => `${x},${y}`));

        originalImage.scan(0, 0, originalImage.bitmap.width, originalImage.bitmap.height, (x, y) => {
            if (!differencesSet.has(`${x},${y}`)) {
                const originalPixelColor = originalImage.getPixelColor(x, y);
                modifiedImage.setPixelColor(originalPixelColor, x, y);
            }
        });

        const newBuffer = await modifiedImage.getBufferAsync(Jimp.MIME_PNG);
        return newBuffer.toString('base64');
    }
}
