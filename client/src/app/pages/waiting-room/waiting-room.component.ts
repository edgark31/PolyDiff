import { AfterViewInit, Component } from '@angular/core';
import { Router } from '@angular/router';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';

import { Lobby } from '@common/game-interfaces';

@Component({
    selector: 'app-waiting-room',
    templateUrl: './waiting-room.component.html',
    styleUrls: ['./waiting-room.component.scss'],
})
export class WaitingRoomComponent implements AfterViewInit {
    lobby: Lobby;

    constructor(public router: Router, private readonly roomManagerService: RoomManagerService) {}

    ngAfterViewInit(): void {
        this.roomManagerService.lobby$.subscribe((lobby) => {
            this.lobby = lobby;
            console.log(this.lobby);
        });
    }
}
