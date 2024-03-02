import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { WelcomeService } from './../../services/welcome-service/welcome.service';

@Component({
    selector: 'app-menu',
    templateUrl: './menu.component.html',
    styleUrls: ['./menu.component.scss'],
})
export class MenuComponent {
    imageData: string;
    constructor(public welcomeService: WelcomeService, public clientsocket: ClientSocketService, public router: Router) {}

    onDeconnexion(): void {
        this.clientsocket.disconnect();
        this.router.navigate(['/login']);
    }
}
