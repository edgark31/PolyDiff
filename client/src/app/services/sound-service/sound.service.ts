import { Injectable } from '@angular/core';
@Injectable({
    providedIn: 'root',
})
export class SoundService {

    correctSoundId: string;
    incorrectSoundId: string;

    onErrorSoundPath: string;
    onCorrectSoundPath: string;


    constructor() {
        this.onErrorSoundPath = "asset/sound/error$this.incorrectSoundId.mp3";
        this.onCorrectSoundPath = "asset/sound/correct$this.correctSoundId.mp3";
    }

    playErrorSound(): void {
        new Audio(this.onErrorSoundPath).play();
    }

    playCorrectSound(): void {
        new Audio(this.onCorrectSoundPath).play();
    }


    stopCorrectSound(): void {
        new Audio(this.onCorrectSoundPath).pause();
        new Audio(this.onErrorSoundPath).currentTime = 0;
    }

    stopIncorrectSound(): void {
        new Audio(this.onErrorSoundPath).pause();
        new Audio(this.onErrorSoundPath).currentTime = 0;
    }

    play(sourcePath : string) {
        new Audio(sourcePath);
    }

    stop(sourcePath : string) {
        new Audio(sourcePath);
        new Audio(sourcePath).currentTime = 0;
    }
}
