import { Injectable } from '@angular/core';
import { Router } from '@angular/router';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';

@Injectable({
    providedIn: 'root',
})
export class AdminGuard {
    constructor(private welcomeService: WelcomeService, public router: Router) {}

    canActivate(): boolean {
        if (this.welcomeService.getLoginState()) {
            return true;
        } else {
            this.router.navigate(['/home']);
            return false;
        }
    }
}
