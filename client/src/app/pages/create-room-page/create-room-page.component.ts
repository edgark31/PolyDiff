import { AfterViewInit, Component } from '@angular/core';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
import { Lobby } from '@common/game-interfaces';

@Component({
    selector: 'app-create-room-page',
    templateUrl: './create-room-page.component.html',
    styleUrls: ['./create-room-page.component.scss'],
})
export class CreateRoomPageComponent implements AfterViewInit {
    isCheatModeEnabled = false;
    gameMode: string;
    time: number | null;
    password: string;
    nDifferences: number;
    lobby: Lobby;
    constructor(private readonly roomManagerService: RoomManagerService) {
        this.gameMode = 'classic';
        this.time = 0;
        this.nDifferences = 0;
    }

    ngAfterViewInit(): void {
        this.roomManagerService.lobby$.subscribe((lobby) => {
            this.lobby = lobby;
        });
    }

    formatLabel(value: number | null) {
        this.time = value;
        return value + ' sec';
    }

    onSubmit() {
        const roomPayload: Lobby = {
            isAvailable: true,
            players: [],
            observers: [],
            isCheatEnabled: this.isCheatModeEnabled,
            mode: this.gameMode,
            password: this.password,
            nDifferences: this.nDifferences,
        };
        if (this.gameMode === 'limited') {
            this.roomManagerService.createLimitedRoom(roomPayload);
        } else if (this.gameMode === 'classic') {
            //  roomPayload.time = this.time as number;
            this.roomManagerService.createClassicRoom(roomPayload);
        }
    }
}
