import { Injectable } from '@angular/core';
import { CanActivate, Router } from '@angular/router';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';

@Injectable({
    providedIn: 'root',
})
export class AdminGuard implements CanActivate {
    constructor(private welcomeService: WelcomeService, public router: Router) {}

    async canActivate(): Promise<boolean> {
        if (this.welcomeService.getLoginState()) {
            return true;
        } else {
            this.router.navigate(['/home']);
            return false;
        }
    }
}
