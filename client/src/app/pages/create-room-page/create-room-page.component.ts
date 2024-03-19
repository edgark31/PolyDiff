import { AfterViewInit, Component } from '@angular/core';
import { NavigationService } from '@app/services/navigation-service/navigation.service';
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
    mode: GameModes;
    gameModes: typeof GameModes;
    time: number | null;
    password: string = '';
    nDifferences: number;
    gameId: string;
    lobby: Lobby;
    constructor(private readonly roomManagerService: RoomManagerService, private readonly navigationService: NavigationService) {
        this.time = 0;
        this.nDifferences = 0;
        const previousUrl = this.navigationService.getPreviousUrl();
        this.mode = previousUrl === '/limited' ? GameModes.Limited : GameModes.Classic;
        this.gameId = this.navigationService.getGameId();
        this.nDifferences = this.navigationService.getNDifferences();
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

    onVerifyClassic() {
        return this.mode === GameModes.Classic;
    }
    onSubmit() {
        const roomPayload: Lobby = {
            isAvailable: true,
            players: [],
            observers: [],
            isCheatEnabled: this.isCheatModeEnabled,
            mode: this.mode,
            timeLimit: this.time as number,
            time: this.time as number, // vue que le serveur l'utilise pour diminueer le temps
            password: this.password,
            nDifferences: this.nDifferences,
            gameId: this.gameId,
            timePlayed: 0,
        };
        if (this.mode === GameModes.Limited) {
            this.roomManagerService.createLimitedRoom(roomPayload);
        } else if (this.mode === GameModes.Classic) {
            this.roomManagerService.createClassicRoom(roomPayload);
        }
    }
}
