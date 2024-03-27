import { ChangeDetectorRef, Component, OnDestroy, OnInit } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { PageEvent } from '@angular/material/paginator';
import { Router } from '@angular/router';
import { ModalAccessMatchComponent } from '@app/components/modal-access-match/modal-access-match.component';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { GameManagerService } from '@app/services/game-manager-service/game-manager.service';
import { NavigationService } from '@app/services/navigation-service/navigation.service';
// import { PlayerNameDialogBoxComponent } from '@app/components/player-name-dialog-box/player-name-dialog-box.component';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
import { ChannelEvents, GameModes, LobbyEvents } from '@common/enums';
import { Lobby } from '@common/game-interfaces';
import { Subscription } from 'rxjs';

@Component({
    selector: 'app-limited-time-page',
    templateUrl: './limited-time-page.component.html',
    styleUrls: ['./limited-time-page.component.scss'],
})
export class LimitedTimePageComponent implements OnDestroy, OnInit {
    lobbies: Lobby[];
    pageSize = 2;
    currentPage = 0;
    pagedLobbies: Lobby[] = [];
    gameModes: typeof GameModes;
    nPlayersConnected: number;
    private lobbiesSubscription: Subscription;
    private hasNoGameAvailableSubscription: Subscription;
    private roomIdSubscription: Subscription;
    private isLimitedCoopRoomAvailableSubscription: Subscription;
    // private playerName: string;
    // private isStartingGame: boolean;
    // eslint-disable-next-line max-params
    constructor(
        public router: Router,
        private readonly roomManagerService: RoomManagerService,
        private readonly gameManager: GameManagerService,
        private readonly dialog: MatDialog,
        private readonly clientSocket: ClientSocketService,
        private readonly navigationService: NavigationService,
        private cdr: ChangeDetectorRef,
    ) {
        this.gameModes = GameModes;
        // this.isStartingGame = false;
        this.nPlayersConnected = 0;
        this.lobbies = [];
    }

    ngOnInit(): void {
        this.roomManagerService.handleRoomEvents();
        this.roomManagerService.retrieveLobbies();
        this.updatePagedImages();
        this.clientSocket.on('lobby', LobbyEvents.Spectate, (lobby: Lobby) => {
            this.gameManager.lobbyWaiting = lobby;
            this.router.navigate(['/game']);
        });
    }
    previousPage() {
        if (this.currentPage > 0) {
            this.currentPage--;
            this.updatepagedLobbies();
        }
    }

    nextPage() {
        const lobbyLengthValid = this.lobbies.length / (this.pageSize - 1);

        if (lobbyLengthValid > this.currentPage) {
            this.currentPage++;
            this.updatepagedLobbies();
        }
    }

    updatepagedLobbies() {
        const startIndex = this.currentPage * this.pageSize;
        const endIndex = startIndex + this.pageSize;
        this.pagedLobbies = this.lobbies.slice(startIndex, endIndex);
    }

    updatePagedImages() {
        if (this.lobbiesSubscription) {
            this.lobbiesSubscription?.unsubscribe();
        }
        this.lobbiesSubscription = this.roomManagerService.lobbies$.subscribe((lobbies) => {
            if (lobbies.length > 0) {
                this.lobbies = lobbies.filter((lobby) => lobby.mode === GameModes.Limited);
                this.updatepagedLobbies();
                this.cdr.detectChanges();
            }
        });
    }

    handlePageEvent(event: PageEvent) {
        this.currentPage = event.pageIndex;
        this.updatepagedLobbies();
    }
    manageGames(): void {
        this.dialog.open(ModalAccessMatchComponent);
    }

    ngOnDestroy(): void {
        if (this.clientSocket.isSocketAlive('lobby') && this.roomManagerService.isObserver) {
            this.clientSocket.disconnect('lobby');
            this.roomManagerService.off();
        }
        this.navigationService.setPreviousUrl('/limited');
        this.lobbiesSubscription?.unsubscribe();
        this.roomIdSubscription?.unsubscribe();
        this.isLimitedCoopRoomAvailableSubscription?.unsubscribe();
        this.hasNoGameAvailableSubscription?.unsubscribe();

        this.clientSocket.lobbySocket.off(ChannelEvents.LobbyMessage);
    }
}
