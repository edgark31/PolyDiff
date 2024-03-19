import { AfterViewInit, ChangeDetectorRef, Component, ElementRef, HostListener, OnDestroy, OnInit, ViewChild } from '@angular/core';
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
import { GameEvents, GameModes, GamePageEvent } from '@common/enums';
import { Chat, ClientSideGame, Game, Players } from '@common/game-interfaces';
import { Subject, Subscription } from 'rxjs';

@Component({
    selector: 'app-game-page',
    templateUrl: './game-page.component.html',
    styleUrls: ['./game-page.component.scss'],
})
export class GamePageComponent implements OnDestroy, OnInit, AfterViewInit {
    @ViewChild('originalCanvasPlayerOne', { static: false }) originalCanvasPlayerOne!: ElementRef<HTMLCanvasElement>;
    @ViewChild('modifiedCanvasPlayerOne', { static: false }) modifiedCanvasPlayerOne!: ElementRef<HTMLCanvasElement>;
    @ViewChild('originalCanvasPlayerTwo', { static: false }) originalCanvasPlayerTwo!: ElementRef<HTMLCanvasElement>;
    @ViewChild('modifiedCanvasPlayerTwo', { static: false }) modifiedCanvasPlayerTwo!: ElementRef<HTMLCanvasElement>;
    @ViewChild('originalCanvasPlayerThree', { static: false }) originalCanvasPlayerThree!: ElementRef<HTMLCanvasElement>;
    @ViewChild('modifiedCanvasPlayerThree', { static: false }) modifiedCanvasPlayerThree!: ElementRef<HTMLCanvasElement>;
    @ViewChild('originalCanvasPlayerFour', { static: false }) originalCanvasPlayerFour!: ElementRef<HTMLCanvasElement>;
    @ViewChild('modifiedCanvasPlayerFour', { static: false }) modifiedCanvasPlayerFour!: ElementRef<HTMLCanvasElement>;
    playerList = ['PlayerOne', 'PlayerTwo', 'PlayerThree', 'PlayerFour'];
    game: ClientSideGame;
    differencesFound: number;
    opponentDifferencesFound: number;
    timer: number;
    messages: Chat[];
    player: string;
    players: Players;
    hintsAssets: string[];
    isReplayAvailable: boolean;

    gameLobby: Game;
    gameMode: typeof GameModes;
    readonly canvasSize: CanvasMeasurements;
    chatSubscription: Subscription;
    timeSubscription: Subscription;
    private gameSubscription: Subscription;
    private canvasGameSubscription: Subscription;
    private onDestroy$: Subject<void>;

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
        private cdr: ChangeDetectorRef,
    ) {
        // this.gameManager.manageSocket();
        this.differencesFound = 0;
        this.opponentDifferencesFound = 0;
        this.timer = 0;
        this.messages = [];
        this.hintsAssets = ASSETS_HINTS;
        this.player = '';
        this.players = DEFAULT_PLAYERS;
        this.canvasSize = CANVAS_MEASUREMENTS;
        this.isReplayAvailable = false;
        this.gameMode = GameModes;
        this.onDestroy$ = new Subject();
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
                this.gameAreaService.toggleCheatMode(differencesCoordinates);
            }
        }
    }
    getPlayerList(size: number): string[] {
        return this.playerList.slice(0, size);
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
        });
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
    receiveMessage(chat: Chat): void {
        this.messages.push(chat);
        console.log(this.messages);
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
            this.onDestroy$.next();
            this.onDestroy$.complete();
            this.canvasGameSubscription?.unsubscribe();
            this.gameAreaService.resetCheatMode();
            this.gameManager.off();
        }
    }

    setUpGame(): void {
        // this.canvasGameSubscription = this.gameManager.currentGame$
        //     .pipe(
        //         tap((value) => console.log('Observable emitted: ', value)),
        //         takeUntil(this.onDestroy$),
        //     )
        //     .subscribe((game) => {
        //         setTimeout(() => {

        this.gameAreaService.setoriginalContextPlayerOne(
            this.originalCanvasPlayerOne.nativeElement.getContext('2d', {
                willReadFrequently: true,
            }) as CanvasRenderingContext2D,
        );
        this.gameAreaService.setmodifiedContextPlayerOne(
            this.modifiedCanvasPlayerOne.nativeElement.getContext('2d', {
                willReadFrequently: true,
            }) as CanvasRenderingContext2D,
        );
        this.gameAreaService.setOriginalContextPlayerTwo(
            this.originalCanvasPlayerTwo.nativeElement.getContext('2d', {
                willReadFrequently: true,
            }) as CanvasRenderingContext2D,
        );
        this.gameAreaService.setModifiedContextPlayerTwo(
            this.modifiedCanvasPlayerTwo.nativeElement.getContext('2d', {
                willReadFrequently: true,
            }) as CanvasRenderingContext2D,
        );

        this.gameAreaService.setoriginalContextPlayerThree(
            this.originalCanvasPlayerThree.nativeElement.getContext('2d', {
                willReadFrequently: true,
            }) as CanvasRenderingContext2D,
        );
        this.gameAreaService.setmodifiedContextPlayerThree(
            this.modifiedCanvasPlayerThree.nativeElement.getContext('2d', {
                willReadFrequently: true,
            }) as CanvasRenderingContext2D,
        );
        this.gameAreaService.setoriginalContextPlayerFour(
            this.originalCanvasPlayerFour.nativeElement.getContext('2d', {
                willReadFrequently: true,
            }) as CanvasRenderingContext2D,
        );
        this.gameAreaService.setmodifiedContextPlayerFour(
            this.modifiedCanvasPlayerFour.nativeElement.getContext('2d', {
                willReadFrequently: true,
            }) as CanvasRenderingContext2D,
        );
        this.imageService.loadImage(this.gameAreaService.getoriginalContextPlayerOne(), this.gameLobby.original);
        this.imageService.loadImage(this.gameAreaService.getmodifiedContextPlayerOne(), this.gameLobby.modified);

        this.gameAreaService.setAllData();
        this.cdr.detectChanges();
        //     }, 6000);
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
