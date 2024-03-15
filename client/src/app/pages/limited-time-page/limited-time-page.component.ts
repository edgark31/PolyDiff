import { ChangeDetectorRef, Component, OnDestroy, OnInit } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { PageEvent } from '@angular/material/paginator';
import { Router } from '@angular/router';
import { ModalAccessMatchComponent } from '@app/components/modal-access-match/modal-access-match.component';
// import { NoGameAvailableDialogComponent } from '@app/components/no-game-available-dialog/no-game-available-dialog.component';
// import { PlayerNameDialogBoxComponent } from '@app/components/player-name-dialog-box/player-name-dialog-box.component';
// import { WaitingForPlayerToJoinComponent } from '@app/components/waiting-player-to-join/waiting-player-to-join.component';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { NavigationService } from '@app/services/navigation-service/navigation.service';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { ChannelEvents, GameModes } from '@common/enums';
import { Lobby } from '@common/game-interfaces';
// import { PlayerData } from '@common/game-interfaces';
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
    constructor(
        public router: Router,
        private readonly roomManagerService: RoomManagerService,
        private readonly dialog: MatDialog,
        private readonly clientSocket: ClientSocketService,
        private readonly welcomeService: WelcomeService,
        private readonly navigationService: NavigationService,
        private cdr: ChangeDetectorRef,
    ) {
        this.gameModes = GameModes;
        // this.isStartingGame = false;
        this.nPlayersConnected = 0;
        this.lobbies = [];
    }

    ngOnInit(): void {
        this.clientSocket.connect(this.welcomeService.account.id as string, 'lobby');
        this.roomManagerService.handleRoomEvents();
        this.roomManagerService.retrieveLobbies();
        this.updatePagedImages();
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
        this.lobbies = this.lobbies.filter((lobby) => lobby.mode === GameModes.Limited);
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
        this.navigationService.setPreviousUrl('/limited');
        this.lobbiesSubscription?.unsubscribe();
        this.roomIdSubscription?.unsubscribe();
        this.isLimitedCoopRoomAvailableSubscription?.unsubscribe();
        this.hasNoGameAvailableSubscription?.unsubscribe();

        this.clientSocket.lobbySocket.off(ChannelEvents.LobbyMessage);
    }
}
