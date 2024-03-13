import { AfterViewInit, Component } from '@angular/core';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
import { GameModes } from '@common/enums';
import { Lobby } from '@common/game-interfaces';

@Component({
    selector: 'app-create-room-page',
    templateUrl: './create-room-page.component.html',
    styleUrls: ['./create-room-page.component.scss'],
})
export class CreateRoomPageComponent implements AfterViewInit {
    isCheatModeEnabled = false;
    gameModes: typeof GameModes = GameModes;
    mode: GameModes;
    time: number | null;
    password: string;
    nDifferences: number;
    lobby: Lobby;
    constructor(private readonly roomManagerService: RoomManagerService) {
        this.mode = GameModes.Classic;
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
            mode: this.mode,
            timeLimit: this.time as number,
            password: this.password,
            nDifferences: this.nDifferences,
        };
        if (this.mode === GameModes.Limited) {
            this.roomManagerService.createLimitedRoom(roomPayload);
        } else if (this.mode === GameModes.Classic) {
            roomPayload.time = this.time as number;
            this.roomManagerService.createClassicRoom(roomPayload);
        }
    }
}
