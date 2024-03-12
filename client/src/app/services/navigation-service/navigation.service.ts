import { Injectable } from '@angular/core';
import { Router } from '@angular/router';

@Injectable({
    providedIn: 'root',
})
export class NavigationService {
    private previousUrl: string;

    constructor(private router: Router) {
        this.previousUrl = this.router.url;
    }

    getPreviousUrl(): string {
        return this.previousUrl;
    }
}
