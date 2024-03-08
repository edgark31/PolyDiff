import { Component, OnDestroy } from '@angular/core';
import { Router } from '@angular/router';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';

@Component({
    selector: 'app-admin-page',
    templateUrl: './admin-page.component.html',
    styleUrls: ['./admin-page.component.scss'],
})
export class AdminPageComponent implements OnDestroy {
    constructor(private welcomeService: WelcomeService, private router: Router) {}

    goBackToMainPage(): void {
        this.welcomeService.setLoginState(false);
        this.router.navigate(['/home']);
    }

    ngOnDestroy() {
        this.welcomeService.setLoginState(false);
    }
}
