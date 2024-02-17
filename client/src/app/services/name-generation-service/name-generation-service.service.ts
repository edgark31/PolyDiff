/* eslint-disable @typescript-eslint/no-magic-numbers */
import { Injectable } from '@angular/core';
import { animals, colors, dishes, numbers } from '@common/random-name-lists';

@Injectable({
    providedIn: 'root',
})
export class NameGenerationService {
    generatedName: string = '';

    generateName(languageIndex: number, hasAnimalName: boolean, hasNumber: boolean): void {
        const nameComponents: string[] = [];

        // Select a random color
        const colorList = colors.get(languageIndex);
        if (colorList) {
            const color = colorList[Math.floor(Math.random() * colorList.length)];
            nameComponents.push(color);
        }

        // Select a random dish
        const dishList = dishes.get(languageIndex);
        if (dishList) {
            const dish = dishList[Math.floor(Math.random() * dishList.length)];
            nameComponents.push(dish);
        }

        // Optionally add an animal name
        if (hasAnimalName) {
            const animalList = animals.get(languageIndex);
            if (animalList) {
                const animal = animalList[Math.floor(Math.random() * animalList.length)];
                nameComponents.push(animal);
            }
        }

        // Optionally add a number
        if (hasNumber) {
            const number = numbers[Math.floor(Math.random() * numbers.length)].toString();
            nameComponents.push(number);
        }

        // Capitalize the first letter of each component and shuffle
        for (let i = 0; i < nameComponents.length; i++) {
            nameComponents[i] = nameComponents[i].charAt(0).toUpperCase() + nameComponents[i].slice(1);
        }

        // Shuffle the components to randomize the order
        nameComponents.sort(() => Math.random() - 0.5);

        // Join components into a single string
        this.generatedName = nameComponents.join('');
    }
}
