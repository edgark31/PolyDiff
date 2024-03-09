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
    time: number | null = 0;
    password: string;
    constructor(private readonly roomManagerService: RoomManagerService) {
        this.gameMode = 'limited';
    }

    formatLabel(value: number | null) {
        this.time = value;
        return value + ' sec';
    }

    onSubmit() {
        this.roomManagerService.password = this.password;
    }
}
