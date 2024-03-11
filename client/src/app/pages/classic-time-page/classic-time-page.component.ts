import { Component, OnDestroy, OnInit } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { PageEvent } from '@angular/material/paginator';
import { Router } from '@angular/router';
import { ModalAccessMatchComponent } from '@app/components/modal-access-match/modal-access-match.component';
import { NoGameAvailableDialogComponent } from '@app/components/no-game-available-dialog/no-game-available-dialog.component';
// import { PlayerNameDialogBoxComponent } from '@app/components/player-name-dialog-box/player-name-dialog-box.component';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { GameModes } from '@common/enums';
import { Lobby } from '@common/game-interfaces';
import { Subscription, filter } from 'rxjs';

@Component({
    selector: 'app-classic-time-page',
    templateUrl: './classic-time-page.component.html',
    styleUrls: ['./classic-time-page.component.scss'],
})
export class ClassicTimePageComponent implements OnDestroy, OnInit {
    pageSize = 2;
    currentPage = 0;
    pagedLobby: Lobby[] = [];
    lobbys: Lobby[] = [
        {
            lobbyId: '123',
            gameId: '65ea441aeb239647b3c747a8',
            players: [{ name: 'yoyoyoy' }],
            observers: [],
            isAvailable: true,
            isCheatEnabled: true,
            mode: 'classic',
        },
        {
            lobbyId: '123',
            gameId: '65ea441aeb239647b3c747a8',
            players: [{ name: 'yayaya' }],
            observers: [],
            isAvailable: true,
            isCheatEnabled: true,
            mode: 'classic',
        },
        {
            lobbyId: '123',
            gameId: '65ea441aeb239647b3c747a8',
            players: [{ name: 'sallluuuu' }],
            observers: [],
            isAvailable: true,
            isCheatEnabled: true,
            mode: 'classic',
        },
    ];
    totalPages: number;
    gameModes: typeof GameModes;
    nPlayersConnected: number;
    private hasNoGameAvailableSubscription: Subscription;
    private roomIdSubscription: Subscription;
    private isLimitedCoopRoomAvailableSubscription: Subscription;
    constructor(
        public router: Router,
        private readonly roomManagerService: RoomManagerService,
        private readonly dialog: MatDialog,
        // private readonly clientSocket: ClientSocketService,
        // private readonly gameManager: GameManagerService,
        private readonly welcome: WelcomeService,
    ) {
        this.gameModes = GameModes;
        this.nPlayersConnected = 0;
    }

    ngOnInit(): void {
        console.log('ennnddddddd shhhhott' + this.lobbys);
        // this.clientSocket.connect(this.gameManager.username, 'lobby');
        this.updatePagedImages();
        this.roomManagerService.handleRoomEvents();
        this.welcome.isLimited = true;

        // this.totalPages = Math.ceil(this.lobbys.length / this.pageSize);
        // this.openDialog();
        this.handleJoinCoopRoom();
        this.handleNoGameAvailable();
    }

    previousPage() {
        if (this.currentPage > 0) {
            this.currentPage--;
            this.updatePagedImages();
        }
    }

    // ngOnChanges(changes: SimpleChanges): void {
    //     if (changes.lobbys) {
    //         this.updatePagedImages();
    //     }
    // }

    nextPage() {
        const v = this.lobbys.length / this.pageSize - 1;
        console.log(v > this.currentPage);
        if (v > this.currentPage) {
            this.currentPage++;
            this.updatePagedImages();
        }
    }

    updatePagedImages() {
        const startIndex = this.currentPage * this.pageSize;
        const endIndex = startIndex + this.pageSize;
        console.log(`Updating images for page ${this.currentPage}: startIndex=${startIndex}, endIndex=${endIndex}`);
        console.log(this.lobbys.length);
        console.log(this.pageSize - 1);
        console.log(this.currentPage);
        console.log(this.lobbys.length / this.pageSize - 1 > this.currentPage);
        this.pagedLobby = this.lobbys.slice(startIndex, endIndex);
        console.log('Paged images:', this.lobbys);
    }

    handlePageEvent(event: PageEvent) {
        this.currentPage = event.pageIndex;
        this.updatePagedImages();
    }

    manageGames(): void {
        this.dialog.open(ModalAccessMatchComponent);
    }

    ngOnDestroy(): void {
        // this.clientSocket.disconnect('lobby');
        this.roomIdSubscription?.unsubscribe();
        this.isLimitedCoopRoomAvailableSubscription?.unsubscribe();
        this.hasNoGameAvailableSubscription?.unsubscribe();
        this.roomManagerService.removeAllListeners();
    }

    // private openDialog() {
    //     this.dialog
    //         .open(PlayerNameDialogBoxComponent, { disableClose: true, panelClass: 'dialog' })
    //         .afterClosed()
    //         .subscribe((playerName) => {
    //             if (playerName) {
    //                 this.playerName = playerName;
    //             } else {
    //                 this.router.navigate(['/']);
    //             }
    //         });
    // }

    private handleJoinCoopRoom() {
        this.isLimitedCoopRoomAvailableSubscription = this.roomManagerService.isLimitedCoopRoomAvailable$
            .pipe(filter((isRoomAvailable) => isRoomAvailable))
            .subscribe(() => {
                this.router.navigate(['/game']);
                this.dialog.closeAll();
            });
    }

    private handleNoGameAvailable() {
        this.hasNoGameAvailableSubscription = this.roomManagerService.hasNoGameAvailable$.subscribe((hasNoGameAvailable) => {
            if (hasNoGameAvailable) this.dialog.open(NoGameAvailableDialogComponent, { disableClose: true, panelClass: 'dialog' });
        });
    }
}
