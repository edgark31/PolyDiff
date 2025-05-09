/* eslint-disable @typescript-eslint/no-magic-numbers */
import { Injectable } from '@angular/core';
import { animals, colors, dishes, numbers } from '@common/random-name-lists';
import { Observable } from 'rxjs';

@Injectable({
    providedIn: 'root',
})
export class NameGenerationService {
    generatedNameObservable: Observable<string>;
    generatedName: string = '';

    generateName(languageIndex: number, hasAnimalName: boolean, hasNumber: boolean): void {
        const nameComponents: string[] = [];
        const colorList = colors.get(languageIndex);
        if (colorList) {
            const color = colorList[Math.floor(Math.random() * colorList.length)];
            nameComponents.push(color);
        }
        const dishList = dishes.get(languageIndex);
        if (dishList) {
            const dish = dishList[Math.floor(Math.random() * dishList.length)];
            nameComponents.push(dish);
        }
        if (hasAnimalName) {
            const animalList = animals.get(languageIndex);
            if (animalList) {
                const animal = animalList[Math.floor(Math.random() * animalList.length)];
                nameComponents.push(animal);
            }
        }
        if (hasNumber) {
            const number = numbers[Math.floor(Math.random() * numbers.length)].toString();
            nameComponents.push(number);
        }
        for (let i = 0; i < nameComponents.length; i++) {
            nameComponents[i] = nameComponents[i].charAt(0).toUpperCase() + nameComponents[i].slice(1);
        }
        while (nameComponents.length >= 20) {
            nameComponents.sort(() => Math.random());
        }
        this.generatedName = nameComponents.join('');
    }
}
