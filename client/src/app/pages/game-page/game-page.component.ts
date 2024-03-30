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
import { Chat, Game, Lobby } from '@common/game-interfaces';
import { Subject, Subscription, takeUntil } from 'rxjs';
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
    endMessage: string;
    messages: Chat[];
    messageGlobal: Chat[];
    isReplayAvailable: boolean;
    lobbies: Lobby[] = [];
    gameLobby: Game;
    lobby: Lobby;
    gameMode: typeof GameModes;
    readonly canvasSize: CanvasMeasurements;
    chatSubscription: Subscription;
    chatSubscriptionGlobal: Subscription;
    timeSubscription: Subscription;
    lobbySubscription: Subscription;
    lobbiesSubscription: Subscription;
    observersSubscription: Subscription;
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
        if (!this.roomManager.isObserver) {
            if (eventHTMLElement.tagName !== INPUT_TAG_NAME) {
                if (event.key === 't' && this.lobby.isCheatEnabled && this.lobby.mode !== this.gameMode.Practice) {
                    if (this.gameAreaService.isCheatModeActivated) {
                        this.clientSocket.send('game', GameEvents.CheatDeactivated);
                    } else {
                        this.clientSocket.send('game', GameEvents.CheatActivated);
                    }
                    const differencesCoordinates = this.gameLobby?.differences ? ([] as Coordinate[]).concat(...this.remainingDifference) : [];
                    this.gameAreaService.toggleCheatMode(differencesCoordinates);
                }
            }
        }
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

        this.clientSocket.on('game', GameEvents.AbandonGame, (lobby: Lobby) => {
            this.router.navigate(['/game-mode']);
            this.clientSocket.disconnect('lobby');
            this.clientSocket.disconnect('game');
        });
        this.chatSubscription = this.gameManager.message$.subscribe((message: Chat) => {
            this.receiveMessage(message);
        });

        this.gameSubscription = this.gameManager.game$.subscribe((game: Game) => {
            this.gameLobby = game;
            this.remainingDifference = this.gameLobby.differences as Coordinate[][];
        });
        this.nextGameSubscription = this.gameManager.nextGame$.subscribe((nextGame: Game) => {
            this.gameLobby = nextGame;
            this.setUpGame();
        });
        this.timeSubscription = this.gameManager.timerLobby$.subscribe((timer: number) => {
            this.timer = timer;
        });
        this.endMessageSubscription = this.gameManager.endMessage$.subscribe((endMessage: string) => {
            this.endMessage = endMessage;
            this.showEndGameDialog(this.endMessage);
            this.welcome.onChatGame = false;
        });

        this.remainingDifferenceSubscription = this.gameManager.remainingDifference$.subscribe((remainingDifference: Coordinate[][]) => {
            this.remainingDifference = remainingDifference;
        });

        this.lobbySubscription = this.gameManager.lobbyGame$.subscribe((lobby: Lobby) => {
            this.lobby = lobby;
            this.nDifferencesFound = lobby.players.reduce((acc, player) => acc + (player.count as number), 0);
            if (this.roomManager.isObserver) {
            this.messages = this.lobby.chatLog?.chat as Chat[];
            this.messages.forEach((message: Chat) => {
                if (message.name === this.welcome.account.credentials.username) message.tag = MessageTag.Sent;
                else message.tag = MessageTag.Received;
            });
        }
        });
        // this.lobby = this.gameManager.lobbyWaiting;
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

            this.roomManager.off();
            this.gameManager.off();
        }
        if (this.clientSocket.isSocketAlive('auth')) {
            this.globalChatService.off();
        }
        this.chatSubscriptionGlobal?.unsubscribe();
    }

    sendMessage(message: string): void {
        this.gameManager.sendMessage(this.gameLobby.lobbyId, message);
    }

    sendMessageGlobal(message: string): void {
        this.globalChatService.sendMessage(message);
    }

    receiveMessage(chat: Chat): void {
        this.messages.push(chat);
    }

    receiveMessageGlobal(chat: Chat): void {
        this.messageGlobal.push(chat);
    }

    // goPageChatGame(): void {
    //     this.welcome.onChatGame = true;
    //     this.clientSocket.disconnect('game');
    //     this.router.navigate(['/chat']);
    // }

    showEndGameDialog(endingMessage: string): void {
        if (this.lobby.mode === this.gameMode.Classic) this.isReplayAvailable = true;
        this.matDialog.open(GamePageDialogComponent, {
            data: { action: GamePageEvent.EndGame, message: endingMessage, isReplayMode: this.lobby.mode === this.gameMode.Classic },
            disableClose: true,
            panelClass: 'dialog',
        });
    }

    showAbandonDialog(): void {
        this.matDialog.open(GamePageDialogComponent, {
            data: { action: GamePageEvent.Abandon, message: 'Êtes-vous certain de vouloir abandonner la partie ? ', lobby: this.lobby },
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
        // eslint-disable-next-line no-unused-vars

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
        this.replayService.replayTimer$.pipe(takeUntil(this.onDestroy$)).subscribe((replayTimer: number) => {
            if (this.isReplayAvailable) {
                this.timer = replayTimer;
                if (replayTimer === 0) {
                    this.messages = [];
                }
            }
        });
    }
}
