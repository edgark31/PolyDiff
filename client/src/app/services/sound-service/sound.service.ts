import { Injectable } from '@angular/core';
import { Song } from '@common/game-interfaces';

@Injectable({
    providedIn: 'root',
})
export class SoundService {
    // correctSoundEffect: HTMLAudioElement;
    // incorrectSoundEffect: HTMLAudioElement;
    correctSoundEffect: Song;
    incorrectSoundEffect: Song;

    // eslint-disable-next-line @typescript-eslint/no-useless-constructor
    constructor() {
        // this.correctSoundEffect = new Audio('assets/sound/WinSoundEffect.mp3');
        // this.incorrectSoundEffect = new Audio('assets/sound/ErrorSoundEffect.mp3');
    }

    playErrorSound(): void {
        new Audio(this.incorrectSoundEffect.link).play();
    }

    playCorrectSound(): void {
        new Audio(this.correctSoundEffect.link).play();
    }

    playCorrectSoundDifference(song: Song): void {
        new Audio(song.link).play();
    }

    playIncorrectSound(song: Song): void {
        new Audio(song.link).play();
    }

    stopCorrectSound(song: Song): void {
        new Audio(song.link).pause();
        new Audio(song.link).currentTime = 0;
    }

    stopIncorrectSound(song: Song): void {
        new Audio(song.link).pause();
        new Audio(song.link).currentTime = 0;
    }
}
