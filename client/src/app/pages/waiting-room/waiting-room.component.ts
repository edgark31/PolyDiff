import { AfterViewInit, Component, OnDestroy, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
import { Chat, Lobby } from '@common/game-interfaces';
import { Subscription } from 'rxjs';
@Component({
    selector: 'app-waiting-room',
    templateUrl: './waiting-room.component.html',
    styleUrls: ['./waiting-room.component.scss'],
})
export class WaitingRoomComponent implements OnInit, AfterViewInit, OnDestroy {
    lobby: Lobby;
    messages: Chat[] = [];
    lobbySuscription: Subscription;
    messageSubscription: Subscription;
    constructor(public router: Router, public roomManagerService: RoomManagerService, private clientSocketService: ClientSocketService) {}

    ngOnInit(): void {
        this.roomManagerService.wait = true;
        this.roomManagerService.handleRoomEvents();
        this.lobbySuscription = this.roomManagerService.lobby$.subscribe((lobby: Lobby) => {
            this.lobby = lobby;
        });
        // this.roomManagerService.lobby$.pipe(filter((lobby) => !!lobby)).subscribe((lobby) => {
        //     this.lobby = lobby;
        //     console.log('wait' + this.lobby.players.length);
        // });
    }

    ngAfterViewInit(): void {
        if (this.clientSocketService.isSocketAlive('lobby')) {
            this.roomManagerService.updateLog();
            this.messageSubscription = this.roomManagerService.message$.subscribe((message: Chat) => {
                this.receiveMessage(message);
            });
        }
    }

    ngOnDestroy(): void {
        this.roomManagerService.wait = false;
        this.lobbySuscription.unsubscribe();
        this.messageSubscription.unsubscribe();
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
