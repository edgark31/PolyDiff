// Id comes from database to allow _id
/* eslint-disable no-underscore-dangle */
import { Component, Input, OnDestroy, OnInit } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { DomSanitizer, SafeResourceUrl } from '@angular/platform-browser';
import { Router } from '@angular/router';
import { DeleteResetConfirmationDialogComponent } from '@app/components/delete-reset-confirmation-dialog/delete-reset-confirmation-dialog.component';
import { Actions } from '@app/enum/delete-reset-actions';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { NavigationService } from '@app/services/navigation-service/navigation.service';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { GameModes, LobbyEvents } from '@common/enums';
// import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
import { WaitingGameDialogComponent } from '@app/components/waiting-game-dialog/waiting-game-dialog.component';
import { GameManagerService } from '@app/services/game-manager-service/game-manager.service';
import { GameCard, Lobby } from '@common/game-interfaces';
import { Subscription } from 'rxjs';

@Component({
    selector: 'app-game-sheet',
    templateUrl: './game-sheet.component.html',
    styleUrls: ['./game-sheet.component.scss'],
})
export class GameSheetComponent implements OnDestroy, OnInit {
    @Input() game: GameCard;
    url: SafeResourceUrl;
    mode: GameModes = GameModes.Practice;
    lobby: Lobby;
    actions: typeof Actions;
    private isAvailable: boolean;
    private lobbySubscription: Subscription;

    // Services are needed for the dialog and dialog needs to talk to the parent component
    // eslint-disable-next-line max-params
    constructor(
        private readonly dialog: MatDialog,
        public router: Router,
        private readonly roomManagerService: RoomManagerService,
        private readonly welcomeService: WelcomeService,
        private readonly clientSocketService: ClientSocketService,
        private sanitizer: DomSanitizer,
        private readonly navigationService: NavigationService,
        private readonly gameManagerService: GameManagerService,
    ) {
        this.actions = Actions;
    }
    ngOnInit(): void {
        this.url = this.sanitizer.bypassSecurityTrustUrl('data:image/png;base64,' + this.game.thumbnail);
    }

    getMode(): string {
        return this.navigationService.getPreviousUrl();
    }

    isAvailableToJoin(): boolean {
        return this.isAvailable;
    }

    openConfirmationDialog(actions: Actions): void {
        this.dialog.open(DeleteResetConfirmationDialogComponent, {
            data: { actions, gameId: this.game._id },
            disableClose: true,
            panelClass: 'dialog',
        });
    }

    showLoadingDialog(): void {
        this.dialog.open(WaitingGameDialogComponent, {
            data: { lobby: this.lobby },
            disableClose: true,
            panelClass: 'dialog',
        });

        setTimeout(() => {
            this.dialog.closeAll();
        }, 2000);
    }

    setGameId(): void {
        this.navigationService.setGameId(this.game._id);
        this.navigationService.setNDifferences(this.game.nDifference as number);
    }

    startGame() {
        if (this.mode === GameModes.Practice) {
            this.navigationService.setGameId(this.game._id);
            this.navigationService.setNDifferences(this.game.nDifference as number);
            const roomPayload: Lobby = {
                isAvailable: true,
                isCheatEnabled: false,
                players: [],
                observers: [],
                mode: this.mode,
                timeLimit: 0,
                time: 0,
                nDifferences: this.game.nDifference as number,
                gameId: this.game._id,
                timePlayed: 0,
            };
            this.clientSocketService.on('lobby', LobbyEvents.Start, () => {
                this.welcomeService.onChatLobby = false;
            });
            this.clientSocketService.on('lobby', LobbyEvents.Create, (lobby: Lobby) => {
                this.lobby = lobby;
                this.gameManagerService.lobbyWaiting = this.lobby;
                this.router.navigate(['/game']);
                this.roomManagerService.onStart(this.lobby.lobbyId as string);
            });
            this.roomManagerService.createPracticeRoom(roomPayload);
        }
    }

    ngOnDestroy(): void {
        this.lobbySubscription?.unsubscribe();
    }
}
