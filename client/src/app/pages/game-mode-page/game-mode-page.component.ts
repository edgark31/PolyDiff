import { Component, OnDestroy } from '@angular/core';
import { NavigationService } from '@app/services/navigation-service/navigation.service';

@Component({
    selector: 'app-game-mode-page',
    templateUrl: './game-mode-page.component.html',
    styleUrls: ['./game-mode-page.component.scss'],
})
export class GameModePageComponent implements OnDestroy {
    constructor(private readonly navigationService: NavigationService) {}

    ngOnDestroy(): void {
        this.navigationService.setPreviousUrl('/practice');
    }
}
