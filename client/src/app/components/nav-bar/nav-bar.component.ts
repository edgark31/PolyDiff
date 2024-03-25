import { Component, EventEmitter, Output } from '@angular/core';
import { Router } from '@angular/router';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { GameManagerService } from '@app/services/game-manager-service/game-manager.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { TranslateService } from '@ngx-translate/core';

@Component({
    selector: 'app-nav-bar',
    templateUrl: './nav-bar.component.html',
    styleUrls: ['./nav-bar.component.scss'],
})
export class NavBarComponent {
    @Output() manageGame: EventEmitter<void> = new EventEmitter();
    readonly configRoute: string;
    readonly homeRoute: string;
    readonly chatRoute: string;
    readonly profileRoute: string;
    readonly friendsRoute: string;

    // eslint-disable-next-line max-params
    constructor(
        public welcomeService: WelcomeService,
        public gameManager: GameManagerService,
        public clientsocket: ClientSocketService,
        public translate: TranslateService,
        public router: Router,
    ) {
        this.configRoute = '/admin';
        this.homeRoute = '/home';
        this.chatRoute = '/chat';
        this.profileRoute = '/profil';
    }

    onSubmitHome(): void {
        this.clientsocket.disconnect('auth');
        // this.clientsocket.disconnect('lobby');
        // this.clientsocket.disconnect('game');
        this.router.navigate(['/login']);
    }
    onManageGames(): void {
        this.manageGame.emit();
    }
}
