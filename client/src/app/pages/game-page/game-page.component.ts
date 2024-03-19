import { AfterViewInit, Component, ElementRef, HostListener, OnDestroy, OnInit, ViewChild } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { GamePageDialogComponent } from '@app/components/game-page-dialog/game-page-dialog.component';
import { DEFAULT_PLAYERS, INPUT_TAG_NAME } from '@app/constants/constants';
import { ASSETS_HINTS } from '@app/constants/hint';
import { CANVAS_MEASUREMENTS } from '@app/constants/image';
import { CanvasMeasurements } from '@app/interfaces/game-interfaces';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { GameAreaService } from '@app/services/game-area-service/game-area.service';
import { GameManagerService } from '@app/services/game-manager-service/game-manager.service';
import { ImageService } from '@app/services/image-service/image.service';
import { ReplayService } from '@app/services/replay-service/replay.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { Coordinate } from '@common/coordinate';
import { ChatState, GameEvents, GameModes, GamePageEvent } from '@common/enums';
import { Chat, ClientSideGame, Game, Players } from '@common/game-interfaces';
import { Subscription } from 'rxjs';
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

    game: ClientSideGame;
    differencesFound: number;
    opponentDifferencesFound: number;
    timer: number;
    messages: Chat[];
    messagesLobby: Chat[];
    player: string;
    players: Players;
    hintsAssets: string[];
    isReplayAvailable: boolean;

    gameLobby: Game;
    gameMode: typeof GameModes;
    readonly canvasSize: CanvasMeasurements;
    chatSubscription: Subscription;
    chatSubscriptionlobby: Subscription;
    timeSubscription: Subscription;
    private gameSubscription: Subscription;
    private canvasGameSubscription: Subscription;

    // Services are needed for the dialog and dialog needs to talk to the parent component
    // eslint-disable-next-line max-params
    constructor(
        replayService: ReplayService,
        private router: Router,
        private imageService: ImageService,
        private readonly gameAreaService: GameAreaService,
        public gameManager: GameManagerService,
        private clientSocket: ClientSocketService,
        public welcome: WelcomeService,
        private readonly matDialog: MatDialog,
        public globalChatService: GlobalChatService,
    ) {
        // this.gameManager.manageSocket();
        this.differencesFound = 0;
        this.opponentDifferencesFound = 0;
        this.timer = 0;
        this.messages = [];
        this.messagesLobby = [];
        this.hintsAssets = ASSETS_HINTS;
        this.player = '';
        this.players = DEFAULT_PLAYERS;
        this.canvasSize = CANVAS_MEASUREMENTS;
        this.isReplayAvailable = false;
        this.gameMode = GameModes;
        this.welcome.currentChatState = ChatState.Game;
    }

    private get differences(): Coordinate[][] {
        return this.gameManager.differences;
    }

    @HostListener('window:keydown', ['$event'])
    keyboardEvent(event: KeyboardEvent) {
        const eventHTMLElement = event.target as HTMLElement;
        if (eventHTMLElement.tagName !== INPUT_TAG_NAME) {
            if (event.key === 't') {
                const differencesCoordinates = ([] as Coordinate[]).concat(...this.differences);
                this.clientSocket.send('game', GameEvents.Clic, { lobbyId: this.gameLobby.lobbyId, coordClic: differencesCoordinates });
                this.gameAreaService.toggleCheatMode(differencesCoordinates);
            }
        }
    }
    ngOnInit(): void {
        this.clientSocket.connect(this.welcome.account.id as string, 'game');
        this.gameManager.manageSocket();
        this.clientSocket.send('game', GameEvents.StartGame, this.gameManager.lobbyWaiting.lobbyId);
        this.chatSubscription = this.gameManager.message$.subscribe((message: Chat) => {
            this.receiveMessage(message);
        });
        this.gameSubscription = this.gameManager.game$.subscribe((game: Game) => {
            this.gameLobby = game;
        });
        this.timeSubscription = this.gameManager.timerLobby$.subscribe((timer: number) => {
            this.timer = timer;
        });

        this.clientSocket.on('game', GameEvents.EndGame, (response: string) => {
            this.router.navigate(['/game-mode']);
            this.welcome.goChat = false;
        });

        if (this.clientSocket.isSocketAlive('auth')) {
            this.globalChatService.manage();
            this.globalChatService.updateLog();
            this.chatSubscriptionlobby = this.globalChatService.message$.subscribe((message: Chat) => {
                this.receiveMessageLobby(message);
            });
        }
    }
    ngAfterViewInit(): void {
        //     // this.gameManager.startGame();
        //     // // this.getPlayers();
        this.setUpGame();
        //     // this.setUpReplay();
        //     // this.updateTimer();
        //     // this.handleDifferences();
        //     // this.handleMessages();
        //     // this.showEndMessage();
        //     // this.updateIfFirstDifferencesFound();
        //     // this.updateGameMode();
        //     // this.handlePageRefresh();
    }
    sendMessage(message: string): void {
        this.gameManager.sendMessage(this.gameLobby.lobbyId, message);
    }

    sendMessageLobby(message: string): void {
        console.log('affiche toi message: ' + message);
        this.globalChatService.sendMessage('yo');
    }
    receiveMessage(chat: Chat): void {
        this.messages.push(chat);
        console.log(this.messages);
    }

    receiveMessageLobby(chat: Chat): void {
        this.messagesLobby.push(chat);
        console.log(this.messagesLobby);
    }

    goPageChat(): void {
        this.welcome.goChat = true;
        this.clientSocket.disconnect('game');
        this.router.navigate(['/chat']);
    }
    showAbandonDialog(): void {
        this.matDialog.open(GamePageDialogComponent, {
            data: { action: GamePageEvent.Abandon, message: 'Êtes-vous certain de vouloir abandonner la partie ? ' },
            disableClose: true,
            panelClass: 'dialog',
        });
    }

    mouseClickOnCanvas(event: MouseEvent, isLeft: boolean) {
        if (!this.gameAreaService.detectLeftClick(event)) return;
        this.gameAreaService.setAllData();
        this.gameManager.setIsLeftCanvas(isLeft);
        this.gameManager.requestVerification(this.gameAreaService.getMousePosition());
    }

    isMultiplayerMode(): boolean {
        return this.game.mode === GameModes.LimitedCoop || this.game.mode === GameModes.ClassicOneVsOne;
    }
    ngOnDestroy(): void {
        if (this.clientSocket.isSocketAlive('game')) {
            this.gameSubscription?.unsubscribe();
            this.chatSubscription?.unsubscribe();
            this.timeSubscription?.unsubscribe();
            this.canvasGameSubscription?.unsubscribe();
            this.gameManager.off();
        }
        this.clientSocket.disconnect('game');

        if (this.clientSocket.isSocketAlive('auth')) {
            this.globalChatService.off();
        }
        this.chatSubscriptionlobby?.unsubscribe();
    }

    setUpGame(): void {
        // this.canvasGameSubscription = this.gameManager.currentGame$.pipe(takeUntil(this.onDestroy$)).subscribe((game) => {
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
        this.imageService.loadImage(
            this.gameAreaService.getModifiedContext(),
            this.gameLobby.modified,
            // 'http://localhost:3000/' + game.gameId.toString() + '/original.bmp',
        );
        this.gameAreaService.setAllData();
        // });
    }

    // private setUpReplay(): void {
    //     this.replayService.replayTimer$.pipe(takeUntil(this.onDestroy$)).subscribe((replayTimer: number) => {
    //         if (this.isReplayAvailable) {
    //             this.timer = replayTimer;
    //             if (replayTimer === 0) {
    //                 this.messages = [];
    //                 this.differencesFound = 0;
    //             }
    //         }
    //     });

    //     this.replayService.replayDifferenceFound$.pipe(takeUntil(this.onDestroy$)).subscribe((replayDiffFound) => {
    //         if (this.isReplayAvailable) this.differencesFound = replayDiffFound;
    //     });

    //     this.replayService.replayOpponentDifferenceFound$.pipe(takeUntil(this.onDestroy$)).subscribe((replayDiffFound) => {
    //         if (this.isReplayAvailable) this.opponentDifferencesFound = replayDiffFound;
    //     });
    // }

    // this.gameAreaService.resetCheatMode();
    // this.gameManager.removeAllListeners('game');

    // private isLimitedMode(): boolean {
    //     return this.game.mode === GameModes.LimitedCoop || this.game.mode === GameModes.LimitedSolo;
    // }

    // private showEndGameDialog(endingMessage: string): void {
    //     this.matDialog.open(GamePageDialogComponent, {
    //         data: { action: GamePageEvent.EndGame, message: endingMessage, isReplayMode: this.game?.mode.includes('Classic') },
    //         disableClose: true,
    //         panelClass: 'dialog',
    //     });
    //     if (this.game?.mode.includes('Classic')) this.isReplayAvailable = true;
    // }

    // private updateTimer(): void {
    //     this.gameManager.timer$.pipe(takeUntil(this.onDestroy$)).subscribe((timer) => {
    //         this.timer = timer;
    //     });
    // }

    // private handleMessages(): void {
    //     this.gameManager.message$.pipe(takeUntil(this.onDestroy$)).subscribe((message) => {
    //         this.messages.push(message);
    //     });
    // }

    // private showEndMessage(): void {
    //     this.gameManager.endMessage$.pipe(takeUntil(this.onDestroy$)).subscribe((endMessage) => {
    //         this.showEndGameDialog(endMessage);
    //     });
    // }

    // private handleDifferences(): void {
    //     this.gameManager.differencesFound$.pipe(takeUntil(this.onDestroy$)).subscribe((differencesFound) => {
    //         this.differencesFound = differencesFound;
    //     });

    //     this.gameManager.opponentDifferencesFound$.pipe(takeUntil(this.onDestroy$)).subscribe((opponentDifferencesFound) => {
    //         this.opponentDifferencesFound = opponentDifferencesFound;
    //     });
    // }

    // private updateIfFirstDifferencesFound(): void {
    //     this.gameManager.isFirstDifferencesFound$.pipe(takeUntil(this.onDestroy$)).subscribe((isFirstDifferencesFound) => {
    //         if (isFirstDifferencesFound && this.isLimitedMode()) this.gameManager.startNextGame();
    //     });
    // }

    // private updateGameMode(): void {
    //     this.gameManager.isGameModeChanged$.pipe(takeUntil(this.onDestroy$)).subscribe((isGameModeChanged) => {
    //         if (isGameModeChanged) this.game.mode = GameModes.LimitedSolo;
    //     });
    // }

    // private handlePageRefresh(): void {
    //     this.gameManager.isGamePageRefreshed$.pipe(takeUntil(this.onDestroy$)).subscribe((isGamePageRefreshed) => {
    //         if (isGamePageRefreshed) this.router.navigate(['/']);
    //     });
    // }

    // private getPlayers(): void {
    //     this.gameManager.players$.pipe(takeUntil(this.onDestroy$)).subscribe((players) => {
    //         this.players = players;
    //         if (players.player1.accountId === this.gameManager.getSocketId('game')) {
    //             this.player = players.player1.name ?? '';
    //         } else if (players.player2 && players.player2.accountId === this.gameManager.getSocketId('game')) {
    //             this.player = players.player2.name ?? '';
    //         }
    //     });
    // }
}
