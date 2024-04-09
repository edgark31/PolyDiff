/* eslint-disable max-lines */
import { AfterViewInit, Component, ElementRef, HostListener, OnDestroy, OnInit, ViewChild } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { GamePageDialogComponent } from '@app/components/game-page-dialog/game-page-dialog.component';
import { INPUT_TAG_NAME } from '@app/constants/constants';
import { CANVAS_MEASUREMENTS } from '@app/constants/image';
import { CanvasMeasurements } from '@app/interfaces/game-interfaces';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { GameAreaService } from '@app/services/game-area-service/game-area.service';
import { GameManagerService } from '@app/services/game-manager-service/game-manager.service';
import { ImageService } from '@app/services/image-service/image.service';
import { NavigationService } from '@app/services/navigation-service/navigation.service';
import { ReplayService } from '@app/services/replay-service/replay.service';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { Coordinate } from '@common/coordinate';
import { GameEvents, GameModes, GamePageEvent, MessageTag } from '@common/enums';
import { Chat, Game, GameRecord, Lobby, Player } from '@common/game-interfaces';
import { TranslateService } from '@ngx-translate/core';
import { Subject, Subscription } from 'rxjs';
import { GlobalChatService } from './../../services/global-chat-service/global-chat.service';
@Component({
    selector: 'app-game-page',
    templateUrl: './game-page.component.html',
    styleUrls: ['./game-page.component.scss'],
})
export class GamePageComponent implements OnDestroy, OnInit, AfterViewInit {
    @ViewChild('originalCanvas', { static: false }) originalCanvas!: ElementRef<HTMLCanvasElement>;
    @ViewChild('modifiedCanvas', { static: false }) modifiedCanvas!: ElementRef<HTMLCanvasElement>;
    @ViewChild('originalCanvasFG', { static: false }) originalCanvasForeground!: ElementRef<HTMLCanvasElement>;
    @ViewChild('modifiedCanvasFG', { static: false }) modifiedCanvasForeground!: ElementRef<HTMLCanvasElement>;

    remainingDifference: Coordinate[][];
    timer: number;
    nDifferencesFound: number;
    playerShare: Player[]; // vu que maintenant le compteur player devient 0 avant fin de game
    endMessage: string;
    messages: Chat[];
    messageGlobal: Chat[];
    isReplayAvailable: boolean;
    lobbies: Lobby[] = [];
    gameLobby: Game;
    lobby: Lobby;
    mode: string;
    isAbandon = false;
    gameMode: typeof GameModes;
    readonly canvasSize: CanvasMeasurements;
    chatSubscription: Subscription;
    chatSubscriptionGlobal: Subscription;
    timeSubscription: Subscription;
    lobbySubscription: Subscription;
    lobbiesSubscription: Subscription;
    observersSubscription: Subscription;
    replayTimerSubscription: Subscription;
    replayPlayerCountSubscription: Subscription;
    replayDifferenceFoundSubscription: Subscription;
    private gameSubscription: Subscription;
    private nextGameSubscription: Subscription;
    private endMessageSubscription: Subscription;
    private remainingDifferenceSubscription: Subscription;
    private onDestroy$: Subject<void>;

    // Services are needed for the dialog and dialog needs to talk to the parent component
    // eslint-disable-next-line max-params
    constructor(
        private router: Router,
        private imageService: ImageService,
        private clientSocket: ClientSocketService,
        private readonly gameAreaService: GameAreaService,
        private readonly gameManager: GameManagerService,
        private readonly replayService: ReplayService,
        private readonly matDialog: MatDialog,
        public roomManager: RoomManagerService,
        public welcome: WelcomeService,
        public globalChatService: GlobalChatService,
        private navigationService: NavigationService,
        private translate: TranslateService,
    ) {
        this.nDifferencesFound = 0;
        this.timer = 0;
        this.messages = [];
        this.messageGlobal = [];
        this.canvasSize = CANVAS_MEASUREMENTS;
        this.isReplayAvailable = false;
        this.gameMode = GameModes;
        this.onDestroy$ = new Subject();
    }

    @HostListener('window:keydown', ['$event'])
    keyboardEvent(event: KeyboardEvent) {
        const eventHTMLElement = event.target as HTMLElement;
        if (eventHTMLElement.tagName !== INPUT_TAG_NAME) {
            if (event.key === 't' && this.lobby.isCheatEnabled && this.lobby.mode !== this.gameMode.Practice) {
                if (this.gameAreaService.isCheatModeActivated) {
                    this.clientSocket.send('game', GameEvents.CheatDeactivated, this.lobby.lobbyId);
                } else {
                    this.clientSocket.send('game', GameEvents.CheatActivated, this.lobby.lobbyId);
                }
                const differencesCoordinates = this.gameLobby?.differences ? ([] as Coordinate[]).concat(...this.remainingDifference) : [];
                this.gameAreaService.toggleCheatMode(differencesCoordinates);
            }
        }
    }

    translateCharacter(character: string): string {
        return this.translate.instant(`chat.${character}`);
    }

    getMode(): string {
        return this.navigationService.getPreviousUrl();
    }

    ngOnInit(): void {
        this.clientSocket.connect(this.welcome.account.id as string, 'game');
        this.gameManager.manageSocket();
        if (this.roomManager.isObserver) {
            this.clientSocket.send('game', GameEvents.Spectate, this.gameManager.lobbyWaiting.lobbyId);
        }
        this.clientSocket.send('game', GameEvents.StartGame, this.gameManager.lobbyWaiting.lobbyId);
        // this.lobby = this.gameManager.lobbyWaiting;
        this.lobbySubscription = this.gameManager.lobbyGame$.subscribe((lobby: Lobby) => {
            this.lobby = lobby;
            this.nDifferencesFound = lobby.players.reduce((acc, player) => acc + (player.count as number), 0);

            this.messages = this.lobby.chatLog?.chat as Chat[];
            this.messages.forEach((message: Chat) => {
                if (message.raw.includes('a trouvé une différence')) {
                    const username = message.raw.split(' ').shift();
                    message.raw = username + this.translateCharacter('foundDifférence');
                } else if (message.raw.includes("s'est trompé")) {
                    const username = message.raw.split(' ').shift();
                    message.raw = username + this.translateCharacter('error');
                } else if (message.raw.includes('a abandonné')) {
                    const username = message.raw.split(' ').shift();
                    message.raw = username + this.translateCharacter('abandonParty');
                }
                if (message.name === this.welcome.account.credentials.username && message.name) message.tag = MessageTag.Sent;
                else if (message.name !== this.welcome.account.credentials.username && message.name) message.tag = MessageTag.Received;
            });
        });

        this.gameSubscription = this.gameManager.game$.subscribe((game: Game) => {
            this.gameLobby = game;
            this.remainingDifference = this.gameLobby.differences as Coordinate[][];
        });
        this.nextGameSubscription = this.gameManager.nextGame$.subscribe((nextGame: Game) => {
            this.gameLobby = nextGame;
            this.setUpGame();
        });
        this.clientSocket.on('game', GameEvents.AbandonGame, () => {
            this.router.navigate(['/home']);
            this.clientSocket.disconnect('lobby');
            this.clientSocket.disconnect('game');
        });
        this.chatSubscription = this.gameManager.message$.subscribe((message: Chat) => {
            this.receiveMessage(message);
        });
        this.timeSubscription = this.gameManager.timerLobby$.subscribe((timer: number) => {
            this.timer = timer;
        });
        this.endMessageSubscription = this.gameManager.endMessage$.subscribe((endMessage: string) => {
            if (endMessage.includes('a gagné')) {
                const username = endMessage.split(' ').shift();
                this.endMessage = username + this.translateCharacter('winGame');
            } else if (endMessage.includes('pratique')) {
                this.endMessage = this.translateCharacter('endPractice');
            } else if (endMessage.includes('Match nul')) {
                this.endMessage = this.translateCharacter('tie');
            } else if (endMessage.includes('Temps écoulé')) {
                this.endMessage = this.translateCharacter('expiredTime');
            } else if (endMessage.includes('a abandonné')) {
                const username = endMessage.split(' ').shift();
                this.endMessage = username + this.translateCharacter('abandonParty');
            }
            this.showEndGameDialog(this.endMessage);
            this.welcome.onChatGame = false;
        });
        this.remainingDifferenceSubscription = this.gameManager.remainingDifference$.subscribe((remainingDifference: Coordinate[][]) => {
            this.remainingDifference = remainingDifference;
        });
        this.clientSocket.on('game', GameEvents.GameRecord, (record: GameRecord) => {
            this.replayService.lobby = this.lobby;
            this.replayService.setReplay(record);
            this.timer = record.timeLimit;
            this.resetGameStats();
        });
        if (this.clientSocket.isSocketAlive('auth')) {
            this.globalChatService.manage();
            this.globalChatService.updateLog();
            this.chatSubscriptionGlobal = this.globalChatService.message$.subscribe((message: Chat) => {
                this.receiveMessageGlobal(message);
            });
        }
    }

    ngAfterViewInit(): void {
        this.setUpGame();
        this.setUpReplay();
    }

    ngOnDestroy(): void {
        this.onDestroy$.next();
        this.onDestroy$.complete();
        if (this.clientSocket.isSocketAlive('game')) {
            this.gameSubscription?.unsubscribe();
            this.nextGameSubscription?.unsubscribe();
            this.chatSubscription?.unsubscribe();
            this.lobbySubscription?.unsubscribe();
            this.timeSubscription?.unsubscribe();
            this.endMessageSubscription?.unsubscribe();
            this.lobbySubscription?.unsubscribe();
            this.remainingDifferenceSubscription?.unsubscribe();
            this.observersSubscription?.unsubscribe();
            this.replayTimerSubscription?.unsubscribe();
            this.replayDifferenceFoundSubscription?.unsubscribe();
            this.replayPlayerCountSubscription?.unsubscribe();

            this.roomManager.off();
            this.gameManager.off();
            if (!this.isAbandon) {
                // this.clientSocket.disconnect('lobby');
                // this.clientSocket.disconnect('game');
            }
        }
        if (this.clientSocket.isSocketAlive('auth')) {
            this.globalChatService.off();
        }
        this.chatSubscriptionGlobal?.unsubscribe();
    }

    resetGameStats(): void {
        this.playerShare = this.lobby.players.map((player) => ({ ...player }));
        this.nDifferencesFound = 0;
        for (const player of this.lobby.players) {
            player.count = 0;
        }
        this.messages = [];
    }

    translateGameMode(mode: GameModes): string {
        switch (mode) {
            case GameModes.Classic:
                return this.translate.instant('game.classic');
            case GameModes.Limited:
                return this.translate.instant('game.limited');
            case GameModes.Practice:
                return this.translate.instant('game.practice');
            default:
                return '';
        }
    }

    sendMessage(message: string): void {
        this.gameManager.sendMessage(this.gameLobby.lobbyId, message);
    }

    sendMessageGlobal(message: string): void {
        this.globalChatService.sendMessage(message);
    }

    receiveMessage(chat: Chat): void {
        if (chat.raw.includes('a trouvé une différence')) {
            const username = chat.raw.split(' ').shift();
            chat.raw = username + this.translateCharacter('foundDifférence');
        } else if (chat.raw.includes("s'est trompé")) {
            const username = chat.raw.split(' ').shift();
            chat.raw = username + this.translateCharacter('error');
        } else if (chat.raw.includes('a abandonné')) {
            const username = chat.raw.split(' ').shift();
            chat.raw = username + this.translateCharacter('abandonParty');
        }
        this.messages.push(chat);
    }

    receiveMessageGlobal(chat: Chat): void {
        this.messageGlobal.push(chat);
    }

    showEndGameDialog(endingMessage: string): void {
        this.matDialog.open(GamePageDialogComponent, {
            data: {
                action: GamePageEvent.EndGame,
                message: endingMessage,
                isReplayMode: this.lobby.mode === this.gameMode.Classic,
                lobby: this.lobby,
                players: this.playerShare,
            },
            disableClose: true,
            panelClass: 'dialog',
        });
        if (this.lobby.mode === this.gameMode.Classic) this.isReplayAvailable = true;
    }

    showAbandonDialog(): void {
        this.isAbandon = true;
        this.matDialog.open(GamePageDialogComponent, {
            data: { action: GamePageEvent.Abandon, message: this.translateCharacter('partyAbandon'), lobby: this.lobby },
            disableClose: true,
            panelClass: 'dialog',
        });
    }

    mouseClickOnCanvas(event: MouseEvent, isLeft: boolean) {
        if (!this.gameAreaService.detectLeftClick(event)) return;
        this.gameAreaService.setAllData();
        this.gameManager.setIsLeftCanvas(isLeft);
        this.gameManager.requestVerification(this.lobby.lobbyId as string, this.gameAreaService.getMousePosition());
    }
    setUpGame(): void {
        this.gameAreaService.setOriginalContext(
            this.originalCanvas.nativeElement.getContext('2d', {
                willReadFrequently: true,
            }) as CanvasRenderingContext2D,
        );
        this.gameAreaService.setModifiedContext(
            this.modifiedCanvas.nativeElement.getContext('2d', {
                willReadFrequently: true,
            }) as CanvasRenderingContext2D,
        );
        this.gameAreaService.setOriginalFrontContext(
            this.originalCanvasForeground.nativeElement.getContext('2d', {
                willReadFrequently: true,
            }) as CanvasRenderingContext2D,
        );
        this.gameAreaService.setModifiedFrontContext(
            this.modifiedCanvasForeground.nativeElement.getContext('2d', {
                willReadFrequently: true,
            }) as CanvasRenderingContext2D,
        );

        this.imageService.loadImage(this.gameAreaService.getOriginalContext(), this.gameLobby.original);
        this.imageService.loadImage(this.gameAreaService.getModifiedContext(), this.gameLobby.modified);
        this.gameAreaService.setAllData();
    }
    private setUpReplay(): void {
        this.replayTimerSubscription = this.replayService.replayTimerSubject$.subscribe((replayTimer: number) => {
            this.timer = replayTimer;
            this.messages = [];
        });
        this.replayPlayerCountSubscription = this.replayService.replayPlayerCount$.subscribe((replayPlayerCount: Player) => {
            for (const player of this.lobby.players) {
                if (player.name === replayPlayerCount.name) {
                    player.count = replayPlayerCount.count;
                }
            }
        });
        this.replayDifferenceFoundSubscription = this.replayService.replayDifferenceFound$.subscribe((nDifferencesFound: number) => {
            this.nDifferencesFound = nDifferencesFound;
        });
    }
}
