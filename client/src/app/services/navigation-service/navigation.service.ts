import { Injectable } from '@angular/core';

@Injectable({
    providedIn: 'root',
})
export class NavigationService {
    private previousUrl: string;

    setPreviousUrl(url: string): void {
        this.previousUrl = url;
    }

    getPreviousUrl(): string {
        return this.previousUrl;
    }
}
