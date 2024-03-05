import { Component, EventEmitter, Output } from '@angular/core';

import { Router } from '@angular/router';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { WelcomeService } from './../../services/welcome-service/welcome.service';
@Component({
    selector: 'app-menu',
    templateUrl: './menu.component.html',
    styleUrls: ['./menu.component.scss'],
})
export class MenuComponent {
    @Output() manageGame: EventEmitter<void> = new EventEmitter();
    imageData: string;
    showFiller = false;

    constructor(public welcomeService: WelcomeService, public clientsocket: ClientSocketService, public router: Router) {}

    onDeconnexion(): void {
        this.clientsocket.disconnect();
        this.router.navigate(['/login']);
    }

    onManageGames(): void {
        this.manageGame.emit();
    }

    // close() {
    //     this.sidenav.close();
    // }

    // toggle() {
    //     this.sidenav.toggle();
    // }
}
