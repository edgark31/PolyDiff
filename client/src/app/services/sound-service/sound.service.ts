import { Injectable } from '@angular/core';
import { Sound } from '@common/game-interfaces';

@Injectable({
    providedIn: 'root',
})
export class SoundService {
    correctSoundEffect: Sound;
    incorrectSoundEffect: Sound;

    playErrorSound(): void {
        new Audio(this.incorrectSoundEffect.path).play();
    }

    playCorrectSound(): void {
        new Audio(this.correctSoundEffect.path).play();
    }

    playCorrectSoundDifference(song: Sound): void {
        new Audio(song.path).play();
    }

    playIncorrectSound(sound: Sound): void {
        new Audio(sound.path).play();
    }

    stopCorrectSound(sound: Sound): void {
        new Audio(sound.path).pause();
        new Audio(sound.path).currentTime = 0;
    }

    stopIncorrectSound(sound: Sound): void {
        new Audio(sound.path).pause();
        new Audio(sound.path).currentTime = 0;
    }
}
