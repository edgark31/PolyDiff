import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
import { Lobby } from '@common/game-interfaces';
import { filter } from 'rxjs';

@Component({
    selector: 'app-waiting-room',
    templateUrl: './waiting-room.component.html',
    styleUrls: ['./waiting-room.component.scss'],
})
export class WaitingRoomComponent implements OnInit {
    lobby: Lobby;

    constructor(public router: Router, private readonly roomManagerService: RoomManagerService) {}

    ngOnInit(): void {
        this.roomManagerService.lobby$.pipe(filter((lobby) => !!lobby)).subscribe((lobby) => {
            this.lobby = lobby;
        });

        this.roomManagerService.handleRoomEvents();
    }
}
