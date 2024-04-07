/* eslint-disable @typescript-eslint/no-magic-numbers */
import { Component, OnDestroy, OnInit } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { WaitingGameDialogComponent } from '@app/components/waiting-game-dialog/waiting-game-dialog.component';
import { WaitingPlayerToJoinComponent } from '@app/components/waiting-player-to-join/waiting-player-to-join.component';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { GameManagerService } from '@app/services/game-manager-service/game-manager.service';
import { GlobalChatService } from '@app/services/global-chat-service/global-chat.service';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
import { LobbyEvents, MessageTag } from '@common/enums';
import { TranslateService } from '@ngx-translate/core';
import { Subscription } from 'rxjs';
import { Chat, Lobby, Player } from './../../../../../common/game-interfaces';
import { WelcomeService } from './../../services/welcome-service/welcome.service';
@Component({
    selector: 'app-waiting-room',
    templateUrl: './waiting-room.component.html',
    styleUrls: ['./waiting-room.component.scss'],
})
export class WaitingRoomComponent implements OnInit, OnDestroy {
    lobby: Lobby;
    lobbies: Lobby[] = [];
    messages: Chat[] = [];
    messageGlobal: Chat[] = [];
    chatSubscription: Subscription;
    chatSubscriptionGlobal: Subscription;
    lobbiesSubscription: Subscription;
    requestSubscription: Subscription;
    private lobbySubscription: Subscription;
    // eslint-disable-next-line max-params
    constructor(
        public router: Router,
        public dialog: MatDialog,
        public roomManagerService: RoomManagerService,
        private clientSocketService: ClientSocketService,
        public welcome: WelcomeService,
        public gameManager: GameManagerService,
        public globalChatService: GlobalChatService,
        public translate: TranslateService,
        private readonly matDialog: MatDialog,
    ) {}

    ngOnInit(): void {
        if (this.welcome.onChatGame) this.clientSocketService.connect(this.welcome.account.id as string, 'lobby');
        this.roomManagerService.handleRoomEvents();
        this.roomManagerService.retrieveLobbies();
        this.roomManagerService.wait = true;

        if (this.lobbySubscription) {
            this.lobbySubscription?.unsubscribe();
        }

        this.lobbiesSubscription = this.roomManagerService.lobbies$.subscribe((lobbies: Lobby[]) => {
            this.lobbies = lobbies;
            this.updateCurrentLobby();
        });
        this.lobbySubscription = this.roomManagerService.lobby$.subscribe((lobby: Lobby) => {
            this.lobby = lobby;
            this.messages = this.lobby.chatLog?.chat as Chat[];
            this.messages.forEach((message: Chat) => {
                if (message.name === this.welcome.account.credentials.username) message.tag = MessageTag.Sent;
                else message.tag = MessageTag.Received;
            });
        });
        this.chatSubscription = this.roomManagerService.message$.subscribe((message: Chat) => {
            this.receiveMessage(message);
        });
        this.requestSubscription = this.roomManagerService.playerNameRequesting$.subscribe((playerName: string) => {
            this.dialog.open(WaitingPlayerToJoinComponent, {
                data: { lobby: this.lobby, username: playerName },
                disableClose: true,
                panelClass: 'dialog',
            });
        });
        this.clientSocketService.on('lobby', LobbyEvents.CancelRequestAcessHost, () => {
            this.dialog.closeAll();
        });
        this.clientSocketService.on('lobby', LobbyEvents.Leave, () => {
            this.router.navigate(['/game-mode']);
        });

        this.clientSocketService.on('lobby', LobbyEvents.Start, () => {
            this.showLoadingDialog();
            this.welcome.onChatLobby = false;
            this.router.navigate(['/game']);
        });

        if (this.clientSocketService.isSocketAlive('auth')) {
            this.globalChatService.manage();
            this.globalChatService.updateLog();
            this.chatSubscriptionGlobal = this.globalChatService.message$.subscribe((message: Chat) => {
                this.receiveMessageGlobal(message);
            });
        }
    }

    getPlayers(): Player[] {
        if (this.lobby) return this.lobby.players;
        return [];
    }
    updateCurrentLobby(): void {
        this.lobby = this.lobbies.find((lobby) => lobby.lobbyId === this.lobby.lobbyId) || this.lobby;
    }

    onQuit(): void {
        this.roomManagerService.onQuit(this.lobby);
    }

    receiveMessage(chat: Chat): void {
        this.messages.push(chat);
    }

    sendMessage(message: string): void {
        this.roomManagerService.sendMessage(this.lobby.lobbyId, message);
    }

    sendMessageGlobal(message: string): void {
        this.globalChatService.sendMessage(message);
    }

    onStart(): void {
        this.roomManagerService.onStart(this.lobby.lobbyId ? this.lobby.lobbyId : '');
    }

    receiveMessageGlobal(chat: Chat): void {
        this.messageGlobal.push(chat);
    }

    showLoadingDialog(): void {
        this.matDialog.open(WaitingGameDialogComponent, {
            data: { lobby: this.lobby },
            disableClose: true,
            panelClass: 'dialog',
        });
    }

    ngOnDestroy(): void {
        if (this.clientSocketService.isSocketAlive('lobby')) {
            // this.clientSocketService.disconnect('lobby');
            this.lobbySubscription?.unsubscribe();
            this.chatSubscription?.unsubscribe();
            this.requestSubscription?.unsubscribe();
            // this.roomManagerService.off();
            this.gameManager.lobbyWaiting = this.lobby;
        }
        if (this.clientSocketService.isSocketAlive('auth')) {
            this.globalChatService.off();
        }
        this.chatSubscriptionGlobal?.unsubscribe();
        this.matDialog.closeAll();
    }
}
