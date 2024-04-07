import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { TranslateService } from '@ngx-translate/core';

@Component({
    selector: 'app-no-game-available-dialog',
    templateUrl: './no-game-available-dialog.component.html',
    styleUrls: ['./no-game-available-dialog.component.scss'],
})
export class NoGameAvailableDialogComponent {
    constructor(public router: Router, public translate: TranslateService) {}

    goToHome() {
        this.router.navigate(['/']);
    }

    goToCreate() {
        this.router.navigate(['/create']);
    }
}
