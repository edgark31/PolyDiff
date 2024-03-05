import { Injectable } from '@angular/core';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';

@Injectable({
    providedIn: 'root',
})
export class AdminGuard {
    constructor( private welcomeService: WelcomeService) {}

    canActivateFunc(): boolean {
        return this.welcomeService.getLoginState();
    }
}
