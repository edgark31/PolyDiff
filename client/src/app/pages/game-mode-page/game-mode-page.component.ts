import { Component, OnDestroy, OnInit } from '@angular/core';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { NavigationService } from '@app/services/navigation-service/navigation.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';

@Component({
    selector: 'app-game-mode-page',
    templateUrl: './game-mode-page.component.html',
    styleUrls: ['./game-mode-page.component.scss'],
})
export class GameModePageComponent implements OnInit, OnDestroy {
    constructor(
        private readonly navigationService: NavigationService,
        private readonly clientSocketService: ClientSocketService,
        private readonly welcomeService: WelcomeService,
    ) {}

    ngOnInit(): void {
        this.clientSocketService.connect(this.welcomeService.account.id as string, 'lobby');
    }

    ngOnDestroy(): void {
        this.navigationService.setPreviousUrl('/practice');
    }
}
