/* eslint-disable max-lines */
import { AfterViewInit, Component, ElementRef, HostListener, OnDestroy, OnInit, ViewChild } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
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
import { GameEvents, GameModes, GamePageEvent } from '@common/enums';
import { Game, Lobby, Player } from '@common/game-interfaces';
import { TranslateService } from '@ngx-translate/core';
import { Subject, Subscription } from 'rxjs';
@Component({
    selector: 'app-replay-game-page',
    templateUrl: './replay-game-page.component.html',
    styleUrls: ['./replay-game-page.component.scss'],
})
export class ReplayGamePageComponent implements OnDestroy, OnInit, AfterViewInit {
    @ViewChild('originalCanvas', { static: false }) originalCanvas!: ElementRef<HTMLCanvasElement>;
    @ViewChild('modifiedCanvas', { static: false }) modifiedCanvas!: ElementRef<HTMLCanvasElement>;
    @ViewChild('originalCanvasFG', { static: false }) originalCanvasForeground!: ElementRef<HTMLCanvasElement>;
    @ViewChild('modifiedCanvasFG', { static: false }) modifiedCanvasForeground!: ElementRef<HTMLCanvasElement>;

    remainingDifference: Coordinate[][];
    timer: number;
    nDifferencesFound: number;
    playerShare: Player[]; // vu que maintenant le compteur player devient 0 avant fin de game
    endMessage: string;
    isReplayAvailable: boolean;
    gameLobby: Game;
    lobby: Lobby;
    mode: string;
    isAbandon = false;
    gameMode: typeof GameModes;
    readonly canvasSize: CanvasMeasurements;
    timeSubscription: Subscription;
    lobbySubscription: Subscription;
    lobbiesSubscription: Subscription;
    observersSubscription: Subscription;
    replayTimerSubscription: Subscription;
    replayPlayerCountSubscription: Subscription;
    replayDifferenceFoundSubscription: Subscription;
    private onDestroy$: Subject<void>;

    // Services are needed for the dialog and dialog needs to talk to the parent component
    // eslint-disable-next-line max-params
    constructor(
        private imageService: ImageService,
        private clientSocket: ClientSocketService,
        private readonly gameAreaService: GameAreaService,
        private readonly gameManager: GameManagerService,
        private readonly replayService: ReplayService,
        private readonly matDialog: MatDialog,
        public roomManager: RoomManagerService,
        public welcome: WelcomeService,
        private navigationService: NavigationService,
        private translate: TranslateService,
    ) {
        this.gameLobby = this.replayService.record.game;
        this.nDifferencesFound = 0;
        this.timer = 0;
        this.canvasSize = CANVAS_MEASUREMENTS;
        this.isReplayAvailable = true;
        this.replayService.isInReplayGamePage = true;
        this.gameMode = GameModes;
        this.onDestroy$ = new Subject();
        this.lobby = {
            lobbyId: '', // a envoyer
            gameId: this.replayService.record.game.gameId,
            isAvailable: false,
            players: this.replayService.record.players,
            observers: [
                {
                    accountId: 'O789',
                    name: 'ObserverOne',
                },
            ], // a envoyer
            isCheatEnabled: false, // a envoyer
            mode: GameModes.Classic,
            password: '',
            timeLimit: this.replayService.record.timeLimit,
            timePlayed: 0,
            nDifferences: this.replayService.record.game.differences ? this.replayService.record.game.differences.length : 0,
        };
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
        this.remainingDifference = this.gameLobby.differences as Coordinate[][];
        this.timeSubscription = this.gameManager.timerLobby$.subscribe((timer: number) => {
            this.timer = timer;
        });
        this.welcome.onChatGame = false;
        this.remainingDifference = this.replayService.record.game.differences as Coordinate[][];
        this.replayService.lobby = this.lobby;
        this.timer = this.replayService.record.timeLimit;
    }

    ngAfterViewInit(): void {
        this.setUpGame();
        this.setUpReplay();
        this.replayService.startReplay();
    }

    ngOnDestroy(): void {
        this.onDestroy$.next();
        this.onDestroy$.complete();
    }

    resetGameStats(): void {
        this.playerShare = this.lobby.players.map((player) => ({ ...player }));
        this.nDifferencesFound = 0;
        for (const player of this.lobby.players) {
            player.count = 0;
        }
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
        // if (this.lobby.mode === this.gameMode.Classic) this.isReplayAvailable = true;
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
        this.replayObserverSubscription = this.replayService.replayObservers$.subscribe((observers: Observer[]) => {
            this.lobby.observers = observers;
        });
    }
}
