import { ChannelEvents, GameEvents, MessageEvents, MessageTag } from './../../../../../common/enums';
/* eslint-disable no-console */
import { Injectable } from '@angular/core';
import { ReplayEvent } from '@app/interfaces/replay-actions';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { GameAreaService } from '@app/services/game-area-service/game-area.service';
import { SoundService } from '@app/services/sound-service/sound.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { Coordinate } from '@common/coordinate';
import { Chat, ChatMessageGlobal, Game, GameConfigConst, Lobby, Players } from '@common/game-interfaces';
import { Subject, filter } from 'rxjs';
@Injectable({
    providedIn: 'root',
})
export class GameManagerService {
    replayEventsSubject: Subject<ReplayEvent>;
    differences: Coordinate[][];
    gameConstants: GameConfigConst;
    username: string;
    isLeftCanvas: boolean;
    game: Subject<Game>;
    nextGame: Subject<Game>;
    timerLobby: Subject<number>;
    endGame: string;
    lobbyWaiting: Lobby;
    private lobbyGame: Subject<Lobby>;
    private timer: Subject<number>;
    private differenceFound: Subject<Coordinate[]>;
    private differencesFound: Subject<number>;
    private opponentDifferencesFound: Subject<number>;
    private currentGame: Subject<Game>;
    private message: Subject<Chat>;
    private abandon: Subject<string>;
    private endMessage: Subject<string>;
    private players: Subject<Players>;
    private isFirstDifferencesFound: Subject<boolean>;
    private isGameModeChanged: Subject<boolean>;
    private isGamePageRefreshed: Subject<boolean>;
    private globalMessage: Subject<ChatMessageGlobal>;

    // Service are needed to be used in this service
    // eslint-disable-next-line max-params
    constructor(
        private readonly clientSocket: ClientSocketService,
        private readonly gameAreaService: GameAreaService,
        private readonly soundService: SoundService,
        private readonly welcome: WelcomeService,
    ) {
        this.currentGame = new Subject<Game>();
        this.lobbyGame = new Subject<Lobby>(); // used
        this.differenceFound = new Subject<Coordinate[]>();
        this.differencesFound = new Subject<number>();
        this.timer = new Subject<number>();
        this.players = new Subject<Players>();
        this.game = new Subject<Game>();
        this.nextGame = new Subject<Game>();
        this.timerLobby = new Subject<number>();
        this.message = new Subject<Chat>();
        this.abandon = new Subject<string>();
        this.endMessage = new Subject<string>();
        this.opponentDifferencesFound = new Subject<number>();
        this.replayEventsSubject = new Subject<ReplayEvent>();
        this.isFirstDifferencesFound = new Subject<boolean>();
        this.isGameModeChanged = new Subject<boolean>();
        this.isGamePageRefreshed = new Subject<boolean>();
        this.globalMessage = new Subject<ChatMessageGlobal>();
    }

    get lobbyGame$() {
        return this.lobbyGame.asObservable();
    }

    get currentGame$() {
        return this.currentGame.asObservable();
    }

    get timer$() {
        return this.timer.asObservable().pipe(filter((timer) => !!timer));
    }
    get differencesFound$() {
        return this.differencesFound.asObservable().pipe(filter((differencesFound) => !!differencesFound));
    }
    get message$() {
        return this.message.asObservable();
    }

    get abandon$() {
        return this.abandon.asObservable();
    }

    get game$() {
        return this.game.asObservable();
    }

    get nextGame$() {
        return this.nextGame.asObservable();
    }

    get timerLobby$() {
        return this.timerLobby.asObservable();
    }

    get endMessage$() {
        return this.endMessage.asObservable().pipe(filter((message) => !!message));
    }

    get opponentDifferencesFound$() {
        return this.opponentDifferencesFound.asObservable().pipe(filter((differencesFound) => !!differencesFound));
    }

    get players$() {
        return this.players.asObservable().pipe(filter((players) => !!players));
    }

    get isFirstDifferencesFound$() {
        return this.isFirstDifferencesFound.asObservable();
    }

    get isGameModeChanged$() {
        return this.isGameModeChanged.asObservable();
    }

    get isGamePageRefreshed$() {
        return this.isGamePageRefreshed.asObservable();
    }

    get globalMessage$() {
        return this.globalMessage.asObservable();
    }

    setMessage(message: Chat) {
        this.message.next(message);
    }

    getSocketId(nameSpace: string): string {
        switch (nameSpace) {
            case 'lobby':
                return this.clientSocket.lobbySocket.id;
            case 'game':
                return this.clientSocket.gameSocket.id;
            case 'auth':
                return this.clientSocket.authSocket.id;
            default:
                throw new Error(`Unknown namespace: ${nameSpace}`);
        }
    }

    startGame(): void {
        this.clientSocket.send('game', GameEvents.StartGameByRoomId);
    }

    startNextGame(): void {
        this.clientSocket.send('game', GameEvents.StartNextGame);
    }

    requestVerification(id: string, coords: Coordinate): void {
        this.clientSocket.send('game', GameEvents.Clic, { lobbyId: id, coordClic: coords });
    }

    abandonGame(lobbyId: string): void {
        this.clientSocket.send('game', GameEvents.AbandonGame, lobbyId);
    }

    setIsLeftCanvas(isLeft: boolean): void {
        this.isLeftCanvas = isLeft;
    }

    sendMessage(lobbyId: string | undefined, message: string): void {
        this.clientSocket.send('game', ChannelEvents.SendGameMessage, { lobbyId, message });
    }
    removeAllListeners(nameSpace: string) {
        switch (nameSpace) {
            case 'lobby':
                this.clientSocket.lobbySocket.off();
                break;
            case 'game':
                this.clientSocket.gameSocket.off();
                break;
            case 'auth':
                this.clientSocket.authSocket.off();
                break;
            default:
                throw new Error(`Unknown namespace: ${nameSpace}`);
        }
    }

    sendGlobalMessage(textMessage: string): void {
        const newMessage = { tag: MessageTag.Received, message: textMessage, userName: this.username };
        this.clientSocket.send('game', MessageEvents.GlobalMessage, newMessage);
    }

    manageSocket(): void {
        this.game = new Subject<Game>();
        this.timerLobby = new Subject<number>();
        this.message = new Subject<Chat>();
        this.lobbyGame = new Subject<Lobby>();
        this.differenceFound = new Subject<Coordinate[]>();
        this.endMessage = new Subject<string>();
        this.nextGame = new Subject<Game>();
        this.clientSocket.on('game', GameEvents.StartGame, (game: Game) => {
            this.game.next(game);
            this.lobbyGame.next(this.lobbyWaiting);
        });

        this.clientSocket.on('game', GameEvents.NextGame, (nextGame: Game) => {
            this.nextGame.next(nextGame);
        });

        this.clientSocket.on('game', GameEvents.Found, (data: { lobby: Lobby; difference: Coordinate[] }) => {
            this.handleFound(data.lobby, data.difference);
        });

        this.clientSocket.on('game', GameEvents.NotFound, (coordClic: Coordinate) => {
            this.handleNotFound(coordClic);
        });

        this.clientSocket.on('game', ChannelEvents.GameMessage, (chat: Chat) => {
            this.message.next(chat);
        });

        this.clientSocket.on('game', GameEvents.TimerUpdate, (time: number) => {
            this.timerLobby.next(time);
        });

        this.clientSocket.on('game', GameEvents.EndGame, (endMessage: string) => {
            this.endMessage.next(endMessage);
        });
    }

    off(): void {
        if (this.game && !this.game.closed) {
            this.game?.unsubscribe();
        }
        if (this.message && !this.message.closed) this.message?.unsubscribe();
        if (this.timerLobby && !this.timerLobby.closed) this.timerLobby?.unsubscribe();
        if (this.lobbyGame && !this.lobbyGame.closed) this.lobbyGame?.unsubscribe();
        if (this.differenceFound && !this.differenceFound.closed) this.differenceFound?.unsubscribe();
        if (this.endMessage && !this.endMessage.closed) this.endMessage?.unsubscribe();
        if (this.nextGame && !this.nextGame.closed) this.nextGame?.unsubscribe();
        this.clientSocket.disconnect('game');
    }

    private handleNotFound(coordClic: Coordinate): void {
        this.soundService.playIncorrectSound(this.welcome.account.profile.onErrorSound);
        this.gameAreaService.showError(this.isLeftCanvas, coordClic);
        this.gameAreaService.setAllData();
        return;
    }

    private handleFound(lobby: Lobby, differenceFound: Coordinate[]): void {
        this.differenceFound.next(differenceFound);
        this.lobbyGame.next(lobby);
        if (differenceFound.length !== 0) {
            this.soundService.playCorrectSoundDifference(this.welcome.account.profile.onCorrectSound);
            this.gameAreaService.setAllData();
            this.gameAreaService.replaceDifference(differenceFound);
        }
    }
}
