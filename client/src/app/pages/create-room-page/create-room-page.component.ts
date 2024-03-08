import { Component, OnInit } from '@angular/core';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';

@Component({
    selector: 'app-create-room-page',
    templateUrl: './create-room-page.component.html',
    styleUrls: ['./create-room-page.component.scss'],
})
export class CreateRoomPageComponent implements OnInit {
    isCheatModeEnabled = false;
    gameMode = 'limited';
    constructor(private readonly roomManagerService: RoomManagerService) {}

    formatLabel(value: number | null) {
        return value + ' sec';
    }

    ngOnInit(): void {
        this.gameMode = this.roomManagerService.gameMode;
    }
}
