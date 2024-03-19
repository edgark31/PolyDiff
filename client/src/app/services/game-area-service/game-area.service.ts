import { HostListener, Injectable } from '@angular/core';
import {
    CHEAT_MODE_WAIT_TIME,
    FLASH_WAIT_TIME,
    GREEN_FLASH_TIME,
    LEFT_BUTTON,
    RED_FLASH_TIME,
    WAITING_TIME,
    X_CENTERING_DISTANCE,
    YELLOW_FLASH_TIME,
} from '@app/constants/constants';
import { IMG_HEIGHT, IMG_WIDTH } from '@app/constants/image';
import { GREEN_PIXEL, N_PIXEL_ATTRIBUTE, RED_PIXEL, YELLOW_PIXEL } from '@app/constants/pixels';
import { SPEED_X1 } from '@app/constants/replay';
import { ReplayActions } from '@app/enum/replay-actions';
import { CaptureService } from '@app/services/capture-service/capture.service';
import { Coordinate } from '@common/coordinate';

@Injectable({
    providedIn: 'root',
})
export class GameAreaService {
    mousePosition: Coordinate;
    private originalPixelDataPlayerOnes: ImageData;
    private modifiedPixelDataPlayerOnes: ImageData;
    private originalPixelDataPlayerTwo: ImageData;
    private modifiedPixelDataPlayerTwo: ImageData;
    // private originalPixelDataPlayerThree: ImageData;
    // private modifiedPixelDataPlayerThree: ImageData;
    // private originalPixelDataPlayerFour: ImageData;
    // private modifiedPixelDataPlayerFour: ImageData;
    private originalContextPlayerOne: CanvasRenderingContext2D;
    private modifiedContextPlayerOne: CanvasRenderingContext2D;
    private originalContextPlayerTwo: CanvasRenderingContext2D;
    private modifiedContextPlayerTwo: CanvasRenderingContext2D;
    private originalContextPlayerThree: CanvasRenderingContext2D;
    private modifiedContextPlayerThree: CanvasRenderingContext2D;
    private originalContextPlayerFour: CanvasRenderingContext2D;
    private modifiedContextPlayerFour: CanvasRenderingContext2D;
    private isClickDisabled: boolean;
    private isCheatMode: boolean;
    private cheatModeInterval: number;

    constructor(private readonly captureService: CaptureService) {
        this.mousePosition = { x: 0, y: 0 };
        this.isClickDisabled = false;
        this.isCheatMode = false;
    }

    @HostListener('keydown', ['$event'])
    setAllData(): void {
        this.originalPixelDataPlayerOnes = this.originalContextPlayerOne.getImageData(0, 0, IMG_WIDTH, IMG_HEIGHT);
        this.modifiedPixelDataPlayerOnes = this.modifiedContextPlayerOne.getImageData(0, 0, IMG_WIDTH, IMG_HEIGHT);
        this.originalPixelDataPlayerTwo = this.originalContextPlayerTwo.getImageData(0, 0, IMG_WIDTH, IMG_HEIGHT);
        this.modifiedPixelDataPlayerTwo = this.modifiedContextPlayerTwo.getImageData(0, 0, IMG_WIDTH, IMG_HEIGHT);
        // this.originalPixelDataPlayerThree = this.originalContextPlayerThree.getImageData(0, 0, IMG_WIDTH, IMG_HEIGHT);
        // this.modifiedPixelDataPlayerThree = this.modifiedContextPlayerThree.getImageData(0, 0, IMG_WIDTH, IMG_HEIGHT);
        // this.originalPixelDataPlayerFour = this.originalContextPlayerFour.getImageData(0, 0, IMG_WIDTH, IMG_HEIGHT);
        // this.modifiedPixelDataPlayerFour = this.modifiedContextPlayerFour.getImageData(0, 0, IMG_WIDTH, IMG_HEIGHT);
    }

    detectLeftClick(event: MouseEvent): boolean {
        return event.button === LEFT_BUTTON && !this.isClickDisabled ? (this.saveCoord(event), true) : false;
    }

    showError(isMainCanvas: boolean, errorCoordinate: Coordinate, flashingSpeed: number = SPEED_X1): void {
        const frontContext: CanvasRenderingContext2D = isMainCanvas ? this.originalContextPlayerTwo : this.modifiedContextPlayerTwo;
        frontContext.fillStyle = 'red';
        this.isClickDisabled = true;
        frontContext.font = 'bold 30px Arial, Helvetica, sans-serif';
        frontContext.fillText('ERREUR', errorCoordinate.x - X_CENTERING_DISTANCE, errorCoordinate.y);
        setTimeout(() => {
            frontContext.clearRect(0, 0, IMG_WIDTH, IMG_HEIGHT);
            this.isClickDisabled = false;
        }, WAITING_TIME / flashingSpeed);
        this.captureService.saveReplayEvent(ReplayActions.ClickError, { isMainCanvas, pos: errorCoordinate });
    }

    replaceDifference(differenceCoord: Coordinate[], flashingSpeed: number = SPEED_X1, isPaused: boolean = false): void {
        const imageDataIndex = this.convert2DCoordToPixelIndex(differenceCoord);
        for (const index of imageDataIndex) {
            for (let i = 0; i < N_PIXEL_ATTRIBUTE; i++) {
                this.modifiedPixelDataPlayerOnes.data[index + i] = this.originalPixelDataPlayerOnes.data[index + i];
            }
        }
        this.modifiedContextPlayerOne.putImageData(this.modifiedPixelDataPlayerOnes, 0, 0);
        this.resetCheatMode();
        this.captureService.saveReplayEvent(ReplayActions.ClickFound, differenceCoord);
        this.flashPixels(differenceCoord, flashingSpeed, isPaused);
    }

    flashPixels(differenceCoord: Coordinate[], flashingSpeed: number = SPEED_X1, isPaused: boolean = false): void {
        const imageDataIndexes = this.convert2DCoordToPixelIndex(differenceCoord);
        const firstInterval = setInterval(() => {
            const secondInterval = setInterval(() => {
                this.setPixelData(imageDataIndexes, this.modifiedPixelDataPlayerTwo, this.originalPixelDataPlayerTwo);
                this.putImageDataToContexts();
            }, GREEN_FLASH_TIME / flashingSpeed);

            const color = [YELLOW_PIXEL.red, YELLOW_PIXEL.green, YELLOW_PIXEL.blue, YELLOW_PIXEL.alpha];
            for (const index of imageDataIndexes) {
                this.modifiedPixelDataPlayerTwo.data.set(color, index);
                this.originalPixelDataPlayerTwo.data.set(color, index);
            }
            this.putImageDataToContexts();

            setTimeout(() => {
                clearInterval(secondInterval);
                this.clearFlashing(isPaused);
            }, FLASH_WAIT_TIME / flashingSpeed);
        }, YELLOW_FLASH_TIME / flashingSpeed);

        setTimeout(() => {
            clearInterval(firstInterval);
            this.clearFlashing(isPaused);
        }, FLASH_WAIT_TIME / flashingSpeed);
    }

    toggleCheatMode(startDifferences: Coordinate[], flashingSpeed: number = SPEED_X1): void {
        const imageDataIndexes: number[] = this.convert2DCoordToPixelIndex(startDifferences);
        if (!this.isCheatMode) {
            this.cheatModeInterval = window.setInterval(() => {
                const color = [RED_PIXEL.red, RED_PIXEL.green, RED_PIXEL.blue, RED_PIXEL.alpha];
                for (const index of imageDataIndexes) {
                    this.modifiedPixelDataPlayerTwo.data.set(color, index);
                    this.originalPixelDataPlayerTwo.data.set(color, index);
                }
                this.putImageDataToContexts();

                setTimeout(() => {
                    this.clearFlashing();
                }, RED_FLASH_TIME / flashingSpeed);
            }, CHEAT_MODE_WAIT_TIME / flashingSpeed);
            this.captureService.saveReplayEvent(ReplayActions.ActivateCheat, startDifferences);
        } else {
            this.captureService.saveReplayEvent(ReplayActions.DeactivateCheat, startDifferences);
            clearInterval(this.cheatModeInterval);
            this.clearFlashing();
        }
        this.isCheatMode = !this.isCheatMode;
    }

    getoriginalContextPlayerOne(): CanvasRenderingContext2D {
        return this.originalContextPlayerOne;
    }

    setoriginalContextPlayerOne(context: CanvasRenderingContext2D): void {
        this.originalContextPlayerOne = context;
    }

    getoriginalContextPlayerThree(): CanvasRenderingContext2D {
        return this.originalContextPlayerThree;
    }

    setoriginalContextPlayerThree(context: CanvasRenderingContext2D): void {
        this.originalContextPlayerThree = context;
    }

    getoriginalContextPlayerFour(): CanvasRenderingContext2D {
        return this.originalContextPlayerFour;
    }

    setoriginalContextPlayerFour(context: CanvasRenderingContext2D): void {
        this.originalContextPlayerFour = context;
    }
    setOriginalContextPlayerTwo(context: CanvasRenderingContext2D): void {
        this.originalContextPlayerTwo = context;
    }
    getoriginalContextPlayerTwo(): CanvasRenderingContext2D {
        return this.originalContextPlayerTwo;
    }

    getmodifiedContextPlayerOne(): CanvasRenderingContext2D {
        return this.modifiedContextPlayerOne;
    }

    setmodifiedContextPlayerOne(context: CanvasRenderingContext2D): void {
        this.modifiedContextPlayerOne = context;
    }

    getmodifiedContextPlayerThree(): CanvasRenderingContext2D {
        return this.modifiedContextPlayerThree;
    }

    setmodifiedContextPlayerThree(context: CanvasRenderingContext2D): void {
        this.modifiedContextPlayerThree = context;
    }
    getmodifiedContextPlayerFour(): CanvasRenderingContext2D {
        return this.modifiedContextPlayerFour;
    }

    setmodifiedContextPlayerFour(context: CanvasRenderingContext2D): void {
        this.modifiedContextPlayerFour = context;
    }
    setModifiedContextPlayerTwo(context: CanvasRenderingContext2D): void {
        this.modifiedContextPlayerTwo = context;
    }

    getmodifiedContextPlayerTwo(): CanvasRenderingContext2D {
        return this.modifiedContextPlayerTwo;
    }
    getMousePosition(): Coordinate {
        return this.mousePosition;
    }

    resetCheatMode(): void {
        this.isCheatMode = false;
        clearInterval(this.cheatModeInterval);
    }

    private clearFlashing(isPaused: boolean = false): void {
        if (!isPaused) {
            this.modifiedContextPlayerTwo?.clearRect(0, 0, IMG_WIDTH, IMG_HEIGHT);
            this.originalContextPlayerTwo?.clearRect(0, 0, IMG_WIDTH, IMG_HEIGHT);
            this.originalPixelDataPlayerTwo = this.originalContextPlayerTwo?.getImageData(0, 0, IMG_WIDTH, IMG_HEIGHT);
            this.modifiedPixelDataPlayerTwo = this.modifiedContextPlayerTwo?.getImageData(0, 0, IMG_WIDTH, IMG_HEIGHT);
            this.isClickDisabled = false;
        }
    }

    private putImageDataToContexts(): void {
        this.modifiedContextPlayerTwo?.putImageData(this.modifiedPixelDataPlayerTwo, 0, 0);
        this.originalContextPlayerTwo?.putImageData(this.originalPixelDataPlayerTwo, 0, 0);
    }

    private setPixelData(imageDataIndexes: number[], modifiedPixelDataPlayerTwo: ImageData, originalPixelDataPlayerTwo: ImageData): void {
        for (const index of imageDataIndexes) {
            modifiedPixelDataPlayerTwo.data[index] = GREEN_PIXEL.red;
            modifiedPixelDataPlayerTwo.data[index + 1] = GREEN_PIXEL.green;
            modifiedPixelDataPlayerTwo.data[index + 2] = GREEN_PIXEL.blue;
            modifiedPixelDataPlayerTwo.data[index + 3] = GREEN_PIXEL.alpha;

            originalPixelDataPlayerTwo.data[index] = GREEN_PIXEL.red;
            originalPixelDataPlayerTwo.data[index + 1] = GREEN_PIXEL.green;
            originalPixelDataPlayerTwo.data[index + 2] = GREEN_PIXEL.blue;
            originalPixelDataPlayerTwo.data[index + 3] = GREEN_PIXEL.alpha;
        }
    }

    private saveCoord(event: MouseEvent): void {
        this.mousePosition = { x: event.offsetX, y: event.offsetY };
    }

    private convert2DCoordToPixelIndex(differenceCoord: Coordinate[]): number[] {
        const imageDataIndex: number[] = [];
        for (const coord of differenceCoord) {
            const flatIndex = (coord.x + IMG_WIDTH * coord.y) * N_PIXEL_ATTRIBUTE;
            imageDataIndex.push(flatIndex);
        }
        return imageDataIndex;
    }
}
