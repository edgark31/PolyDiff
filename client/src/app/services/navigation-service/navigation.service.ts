import { Injectable } from '@angular/core';
import { NavigationEnd, Router } from '@angular/router';
import { filter } from 'rxjs/operators';

@Injectable({
    providedIn: 'root',
})
export class NavigationService {
    private history: string[] = [];

    constructor(private router: Router) {
        this.router.events.pipe(filter((event) => event instanceof NavigationEnd)).subscribe(({ urlAfterRedirects }: NavigationEnd) => {
            this.history.push(urlAfterRedirects);
        });
    }

    getPreviousUrl(): string {
        // Returns the URL before the last one if available, otherwise returns an empty string
        return this.history.length > 1 ? this.history[this.history.length - 2] : '';
    }
}
