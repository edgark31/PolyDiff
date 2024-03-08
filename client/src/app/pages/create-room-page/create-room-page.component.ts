import { Component } from '@angular/core';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';

@Component({
    selector: 'app-create-room-page',
    templateUrl: './create-room-page.component.html',
    styleUrls: ['./create-room-page.component.scss'],
})
export class CreateRoomPageComponent {
    isCheatModeEnabled = false;
    gameMode = 'limited';
    constructor(private readonly roomManagerService: RoomManagerService) {
        this.gameMode = this.roomManagerService.gameMode;
    }

    formatLabel(value: number | null) {
        return value + ' sec';
    }
}
