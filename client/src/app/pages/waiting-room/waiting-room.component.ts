import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
import { Lobby } from '@common/game-interfaces';

@Component({
    selector: 'app-waiting-room',
    templateUrl: './waiting-room.component.html',
    styleUrls: ['./waiting-room.component.scss'],
})
export class WaitingRoomComponent implements OnInit {
    lobby: Lobby;

    constructor(public router: Router, public roomManagerService: RoomManagerService) {}

    ngOnInit(): void {
        this.roomManagerService.wait = true;
        this.roomManagerService.handleRoomEvents();
        this.roomManagerService.lobby$.subscribe((lobby: Lobby) => {
            this.lobby = lobby;
        });
        // this.roomManagerService.lobby$.pipe(filter((lobby) => !!lobby)).subscribe((lobby) => {
        //     this.lobby = lobby;
        //     console.log('wait' + this.lobby.players.length);
        // });
    }
}
