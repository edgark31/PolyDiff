import { Injectable } from '@angular/core';
import { Router } from '@angular/router';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';

@Injectable({
    providedIn: 'root',
})
export class AdminGuard {
    constructor(private welcomeService: WelcomeService, public router: Router) {}

    canActivate(): boolean {
        console.log('hgfhghjgchfj');
        if (this.welcomeService.getLoginState()) {
            console.log('hgfhghjgchfj');
            return true;
        } else {
            console.log('sssssssssssssssssssssssss');
            this.router.navigate(['/']);
            return false;
        }
    }
}
