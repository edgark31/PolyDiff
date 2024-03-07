import { Injectable } from '@angular/core';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { CardEvents } from '@common/enums';

@Injectable({
    providedIn: 'root',
})
export class CardManagerService {
    constructor(private readonly clientSocket: ClientSocketService) {}

    createCard() {
        this.clientSocket.send('game', CardEvents.Create);
    }
}
