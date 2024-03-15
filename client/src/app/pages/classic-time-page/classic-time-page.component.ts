import { AfterViewInit, Component, OnDestroy, OnInit } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { PageEvent } from '@angular/material/paginator';
import { Router } from '@angular/router';
import { ModalAccessMatchComponent } from '@app/components/modal-access-match/modal-access-match.component';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { NavigationService } from '@app/services/navigation-service/navigation.service';
// import { PlayerNameDialogBoxComponent } from '@app/components/player-name-dialog-box/player-name-dialog-box.component';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { ChannelEvents, GameModes } from '@common/enums';
import { Lobby } from '@common/game-interfaces';
import { Subscription } from 'rxjs';

@Component({
    selector: 'app-classic-time-page',
    templateUrl: './classic-time-page.component.html',
    styleUrls: ['./classic-time-page.component.scss'],
})
export class ClassicTimePageComponent implements OnDestroy, OnInit, AfterViewInit {
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
    ) {
        this.gameModes = GameModes;
        // this.isStartingGame = false;
        this.nPlayersConnected = 0;
        this.lobbies = [];
        this.clientSocket.connect(this.welcomeService.account.id as string, 'lobby');
        this.roomManagerService.handleRoomEvents();
    }

    ngOnInit(): void {
        this.roomManagerService.retrieveLobbies();
    }

    ngAfterViewInit(): void {
        this.updatePagedImages();
    }

    previousPage() {
        if (this.currentPage > 0) {
            this.currentPage--;
            this.updatePagedImages();
        }
    }

    nextPage() {
        const v = this.lobbies.length / this.pageSize - 1;

        if (v > this.currentPage) {
            this.currentPage++;
            this.updatePagedImages();
        }
    }

    updatePagedImages() {
        this.lobbiesSubscription = this.roomManagerService.lobbies$.subscribe((lobbies) => {
            if (lobbies.length > 0) {
                this.lobbies = lobbies.filter((lobby) => lobby.mode === GameModes.Classic);
                const startIndex = this.currentPage * this.pageSize;
                const endIndex = startIndex + this.pageSize;
                this.pagedLobbies = this.lobbies.slice(startIndex, endIndex);
            }
        });
    }

    handlePageEvent(event: PageEvent) {
        this.currentPage = event.pageIndex;
        this.updatePagedImages();
    }
    manageGames(): void {
        this.dialog.open(ModalAccessMatchComponent);
    }

    ngOnDestroy(): void {
        this.navigationService.setPreviousUrl('/classic');
        this.lobbiesSubscription?.unsubscribe();
        this.roomIdSubscription?.unsubscribe();
        this.isLimitedCoopRoomAvailableSubscription?.unsubscribe();
        this.hasNoGameAvailableSubscription?.unsubscribe();
        this.clientSocket.lobbySocket.off(ChannelEvents.LobbyMessage);
    }
}
