import { Component, OnDestroy, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
import { LobbyEvents } from '@common/enums';
import { Chat, Lobby } from '@common/game-interfaces';
import { Subscription } from 'rxjs';
@Component({
    selector: 'app-waiting-room',
    templateUrl: './waiting-room.component.html',
    styleUrls: ['./waiting-room.component.scss'],
})
export class WaitingRoomComponent implements OnInit, OnDestroy {
    lobby: Lobby;
    messages: Chat[] = [];
    chatSubscription: Subscription;
    lobbySubscription: Subscription;
    constructor(public router: Router, public roomManagerService: RoomManagerService, private clientSocketService: ClientSocketService) {}

    ngOnInit(): void {
        this.roomManagerService.retrieveLobbies();
        this.roomManagerService.wait = true;
        if (this.clientSocketService.isSocketAlive('lobby')) {
            this.lobbySubscription = this.roomManagerService.lobby$.subscribe((lobby: Lobby) => {
                this.lobby = lobby;

                this.messages = this.lobby.chatLog?.chat as Chat[];
            });
            this.chatSubscription = this.roomManagerService.message$.subscribe((message: Chat) => {
                this.receiveMessage(message);
            });
            this.clientSocketService.on('lobby', LobbyEvents.Leave, () => {
                this.router.navigate(['/game-mode']);
            });
        }
        this.roomManagerService.handleRoomEvents();
    }

    onQuit(): void {
        this.roomManagerService.onQuit(this.lobby);
    }

    receiveMessage(chat: Chat): void {
        this.messages.push(chat);
    }

    sendMessage(message: string): void {
        this.roomManagerService.sendMessage(this.lobby.lobbyId, message);
    }

    ngOnDestroy(): void {
        if (this.clientSocketService.isSocketAlive('lobby')) {
            this.roomManagerService.off();
            this.clientSocketService.disconnect('lobby');
            cons;
        }
        this.lobbySubscription?.unsubscribe();
        this.chatSubscription?.unsubscribe();

        this.roomManagerService.wait = false;
    }
}
