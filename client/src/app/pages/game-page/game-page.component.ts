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
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { Coordinate } from '@common/coordinate';
import { GameEvents, GameModes, GamePageEvent } from '@common/enums';
import { Chat, Game, Lobby } from '@common/game-interfaces';
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

    timer: number;
    nDifferencesFound: number;
    messages: Chat[];
    messageGlobal: Chat[];
    isReplayAvailable: boolean;
    gameLobby: Game;
    lobby: Lobby;
    gameMode: typeof GameModes;
    readonly canvasSize: CanvasMeasurements;
    chatSubscription: Subscription;
    chatSubscriptionGlobal: Subscription;
    timeSubscription: Subscription;
    lobbySubscription: Subscription;
    private gameSubscription: Subscription;

    // Services are needed for the dialog and dialog needs to talk to the parent component
    // eslint-disable-next-line max-params
    constructor(
        private router: Router,
        private imageService: ImageService,
        private readonly gameAreaService: GameAreaService,
        public gameManager: GameManagerService,
        private clientSocket: ClientSocketService,
        private readonly matDialog: MatDialog,
        public welcome: WelcomeService,
        public globalChatService: GlobalChatService,
    ) {
        this.nDifferencesFound = 0;
        this.timer = 0;
        this.messages = [];
        this.messageGlobal = [];
        this.canvasSize = CANVAS_MEASUREMENTS;
        this.isReplayAvailable = false;
        this.gameMode = GameModes;
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
        this.clientSocket.send('game', GameEvents.StartGame, this.gameManager.lobbyWaiting.lobbyId);
        this.gameManager.manageSocket();
        this.lobby = this.gameManager.lobbyWaiting;

        this.chatSubscription = this.gameManager.message$.subscribe((message: Chat) => {
            console.log('retour' + message);
            this.receiveMessage(message);
        });
        this.gameSubscription = this.gameManager.game$.subscribe((game: Game) => {
            this.gameLobby = game;
        });
        this.timeSubscription = this.gameManager.timerLobby$.subscribe((timer: number) => {
            this.timer = timer;
        });
        this.clientSocket.on('game', GameEvents.EndGame, () => {
            this.router.navigate(['/game-mode']);
            this.welcome.onChatGame = false;
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
        //     // this.gameManager.startGame();
        // if (this.lobbySubscription) {
        //     this.lobbySubscription?.unsubscribe();
        // }
        this.setUpGame();
        this.lobbySubscription = this.gameManager.lobbyGame$.subscribe((lobby: Lobby) => {
            this.lobby = lobby;
            this.nDifferencesFound = lobby.players.reduce((acc, player) => acc + (player.count as number), 0);
        });
        //     // this.setUpReplay();
        //     // this.updateTimer();
        //     // this.handleDifferences();
        //     // this.handleMessages();
        //     // this.showEndMessage();
        //     // this.updateGameMode();
        //     // this.handlePageRefresh();
    }
    sendMessage(message: string): void {
        this.gameManager.sendMessage(this.gameLobby.lobbyId, message);
        console.log('yo' + message);
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

    goPageChatGame(): void {
        this.welcome.onChatGame = true;
        this.clientSocket.disconnect('game');
        this.router.navigate(['/chat']);
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

    ngOnDestroy(): void {
        if (this.clientSocket.isSocketAlive('game')) {
            this.gameSubscription?.unsubscribe();
            this.chatSubscription?.unsubscribe();
            this.lobbySubscription?.unsubscribe();
            this.timeSubscription?.unsubscribe();

            this.gameManager.off();
        }
        if (this.clientSocket.isSocketAlive('auth')) {
            this.globalChatService.off();
        }
        this.chatSubscriptionGlobal?.unsubscribe();
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
}
