import { Injectable } from '@angular/core';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { CardEvents } from '@common/enums';
import { GameDetails } from '@common/game-interfaces';

@Injectable({
    providedIn: 'root',
})
export class CardManagerService {
    constructor(private readonly clientSocket: ClientSocketService) {}

    createCard(game: GameDetails) {
        this.clientSocket.send('game', CardEvents.CardCreated, game);
    }
}
