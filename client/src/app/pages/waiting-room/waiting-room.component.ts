import { Component, OnDestroy, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
import { LobbyEvents, MessageTag } from '@common/enums';
import { Chat, Lobby } from '@common/game-interfaces';
import { Subscription } from 'rxjs';
import { WelcomeService } from './../../services/welcome-service/welcome.service';
@Component({
    selector: 'app-waiting-room',
    templateUrl: './waiting-room.component.html',
    styleUrls: ['./waiting-room.component.scss'],
})
export class WaitingRoomComponent implements OnInit, OnDestroy {
    lobby: Lobby;
    lobbies: Lobby[] = [];
    messages: Chat[] = [];
    chatSubscription: Subscription;
    lobbiesSubscription: Subscription;
    private lobbySubscription: Subscription;
    constructor(
        public router: Router,
        public roomManagerService: RoomManagerService,
        private clientSocketService: ClientSocketService,
        public welcome: WelcomeService,
    ) {}

    ngOnInit(): void {
        this.roomManagerService.handleRoomEvents();
        this.roomManagerService.retrieveLobbies();
        this.roomManagerService.wait = true;

        if (this.lobbySubscription) {
            this.lobbySubscription?.unsubscribe();
        }

        this.lobbiesSubscription = this.roomManagerService.lobbies$.subscribe((lobbies: Lobby[]) => {
            this.lobbies = lobbies;
            this.updateCurrentLobby();
        });
        this.lobbySubscription = this.roomManagerService.lobby$.subscribe((lobby: Lobby) => {
            this.lobby = lobby;
            this.messages = this.lobby.chatLog?.chat as Chat[];
            this.messages.forEach((message: Chat) => {
                if (message.name === this.welcome.account.credentials.username) message.tag = MessageTag.Sent;
                else message.tag = MessageTag.Received;
            });
        });
        this.chatSubscription = this.roomManagerService.message$.subscribe((message: Chat) => {
            this.receiveMessage(message);
        });
        this.clientSocketService.on('lobby', LobbyEvents.Leave, () => {
            this.router.navigate(['/game-mode']);
        });

        this.clientSocketService.on('lobby', LobbyEvents.Start, () => {
            this.router.navigate(['/game']);
        });
    }

    updateCurrentLobby(): void {
        this.lobby = this.lobbies.find((lobby) => lobby.lobbyId === this.lobby.lobbyId) || this.lobby;
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

    onStart(): void {
        this.roomManagerService.onStart(this.lobby.lobbyId ? this.lobby.lobbyId : '');
    }
    ngOnDestroy(): void {
        // this.onQuit();
        if (this.clientSocketService.isSocketAlive('lobby')) {
            // this.clientSocketService.disconnect('lobby');
            this.lobbySubscription?.unsubscribe();
            this.chatSubscription?.unsubscribe();
            this.roomManagerService.off();
        }
        this.roomManagerService.wait = false;
    }
}
