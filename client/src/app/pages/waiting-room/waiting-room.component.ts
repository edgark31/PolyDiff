import { AfterViewInit, Component, OnDestroy, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
import { Chat, Lobby } from '@common/game-interfaces';
@Component({
    selector: 'app-waiting-room',
    templateUrl: './waiting-room.component.html',
    styleUrls: ['./waiting-room.component.scss'],
})
export class WaitingRoomComponent implements OnInit, OnDestroy, AfterViewInit {
    lobby: Lobby;
    messages: Chat[] = [];
    constructor(public router: Router, public roomManagerService: RoomManagerService, private clientSocketService: ClientSocketService) {}

    ngOnInit(): void {
        this.roomManagerService.wait = true;
        this.roomManagerService.handleRoomEvents();
        if (this.clientSocketService.isSocketAlive('lobby')) {
            this.roomManagerService.lobby$.subscribe((lobby: Lobby) => {
                this.lobby = lobby;
                this.messages = lobby.chatLog?.chat as Chat[];
            });
        }
    }

    ngAfterViewInit(): void {
        if (this.clientSocketService.isSocketAlive('lobby')) {
            this.roomManagerService.handleRoomEvents();
            this.roomManagerService.updateLog();
            this.roomManagerService.message$.subscribe((message: Chat) => {
                this.receiveMessage(message);
            });
        }
    }

    ngOnDestroy(): void {
        this.roomManagerService.updateLog();
        this.roomManagerService.wait = false;
        if (this.clientSocketService.isSocketAlive('lobby')) {
            this.roomManagerService.off();
        }
    }

    onQuit(): void {
        this.router.navigate(['/Limited']);
        this.roomManagerService.onQuit(this.lobby);
    }
    receiveMessage(chat: Chat): void {
        this.messages.push(chat);
    }
    sendMessage(message: string): void {
        this.roomManagerService.sendMessage(this.lobby.lobbyId, message);
    }
}
