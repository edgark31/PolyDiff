import { ChannelEvents, GameEvents, MessageEvents, MessageTag } from './../../../../../common/enums';
/* eslint-disable no-console */
import { Injectable } from '@angular/core';
import { ReplayEvent } from '@app/interfaces/replay-actions';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { GameAreaService } from '@app/services/game-area-service/game-area.service';
import { SoundService } from '@app/services/sound-service/sound.service';
import { CORRECT_SOUND_LIST, ERROR_SOUND_LIST } from '@common/constants';
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
    timerLobby: Subject<number>;
    lobbyWaiting: Lobby;
    endGame: string;
    private lobbyGame: Subject<Lobby>;
    private timer: Subject<number>;
    private differenceFound: Subject<Coordinate[]>;
    private differencesFound: Subject<number>;
    private opponentDifferencesFound: Subject<number>;
    private currentGame: Subject<Game>;
    private message: Subject<Chat>;
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
    ) {
        this.currentGame = new Subject<Game>();
        this.lobbyGame = new Subject<Lobby>(); // used
        this.differenceFound = new Subject<Coordinate[]>();
        this.differencesFound = new Subject<number>();
        this.timer = new Subject<number>();
        this.players = new Subject<Players>();
        this.game = new Subject<Game>();
        this.timerLobby = new Subject<number>();
        this.message = new Subject<Chat>();
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

    get game$() {
        return this.game.asObservable();
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

    abandonGame(): void {
        this.clientSocket.send('game', GameEvents.AbandonGame);
    }

    setIsLeftCanvas(isLeft: boolean): void {
        this.isLeftCanvas = isLeft;
    }

    // sendMessage(textMessage: string): void {
    //     const newMessage = { tag: MessageTag.Received, message: textMessage };
    //     this.captureService.saveReplayEvent(ReplayActions.CaptureMessage, { tag: MessageTag.Sent, message: textMessage } as ChatMessage);
    //     this.clientSocket.send('game', MessageEvents.LocalMessage, newMessage);
    // }

    sendMessage(lobbyId: string | undefined, message: string): void {
        this.clientSocket.send('game', ChannelEvents.SendGameMessage, { lobbyId, message });
        console.log('prend mon message' + message + lobbyId);
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
        this.clientSocket.on('game', GameEvents.StartGame, (game: Game) => {
            this.game.next(game);
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
        // this.clientSocket.on('game', GameEvents.GameStarted, (room: GameRoom) => {
        //     this.currentGame.next(room.clientGame);
        //     this.gameConstants = room.gameConstants;
        //     this.players.next({ player1: room.player1, player2: room.player2 });
        //     this.differences = room.originalDifferences;
        //     this.captureService.saveReplayEvent(ReplayActions.StartGame, room);
        // });

        // this.clientSocket.on(
        //     'game',
        //     GameEvents.RemoveDifference,
        //     (data: { differencesData: Differences; playerId: string; cheatDifferences: Coordinate[][] }) => {
        //         this.handleRemoveDifference(data);
        //     },
        // );

        // this.clientSocket.on('game', GameEvents.TimerUpdate, (timer: number) => {
        //     this.timer.next(timer);
        //     this.captureService.saveReplayEvent(ReplayActions.TimerUpdate, timer);
        // });

        // this.clientSocket.on('game', GameEvents.EndGame, (endGameMessage: string) => {
        //     this.endMessage.next(endGameMessage);
        // });

        // this.clientSocket.on('game', MessageEvents.GlobalMessage, (receivedMessage: ChatMessageGlobal) => {
        //     if (receivedMessage.userName === this.username) {
        //         receivedMessage.tag = MessageTag.Sent;
        //     } else {
        //         receivedMessage.tag = MessageTag.Received;
        //     }
        //     this.globalMessage.next(receivedMessage);
        //     // this.captureService.saveReplayEvent(ReplayActions.CaptureMessage, receivedMessage);
        // });

        // this.clientSocket.on('game', GameEvents.UpdateDifferencesFound, (differencesFound: number) => {
        //     this.differencesFound.next(differencesFound);
        // });

        // this.clientSocket.on('game', GameEvents.GameModeChanged, () => {
        //     this.isGameModeChanged.next(true);
        // });

        // this.clientSocket.on('game', GameEvents.GamePageRefreshed, () => {
        //     this.isGamePageRefreshed.next(true);
        // });
    }

    off(): void {
        // this.clientSocket.lobbySocket.off(ChannelEvents.LobbyMessage);
        // this.clientSocket.lobbySocket.off(LobbyEvents.UpdateLobbys);
        if (this.game && !this.game.closed) {
            this.game?.unsubscribe();
        }
        if (this.message && !this.message.closed) this.message?.unsubscribe();
        if (this.timerLobby && !this.timerLobby.closed) this.timerLobby?.unsubscribe();
        if (this.currentGame && !this.currentGame.closed) this.currentGame?.unsubscribe();
    }

    // private checkStatus(): void {
    //     this.clientSocket.send('game', GameEvents.CheckStatus);
    // }

    private handleNotFound(coordClic: Coordinate): void {
        this.soundService.playIncorrectSound(ERROR_SOUND_LIST[1]);
        this.gameAreaService.showError(this.isLeftCanvas, coordClic);
        this.gameAreaService.setAllData();
        return;
    }

    private handleFound(lobby: Lobby, differenceFound: Coordinate[]): void {
        this.differenceFound.next(differenceFound);
        this.lobbyGame.next(lobby);
        if (differenceFound.length !== 0) {
            this.soundService.playCorrectSoundDifference(CORRECT_SOUND_LIST[1]);
            this.gameAreaService.setAllData();
            this.gameAreaService.replaceDifference(differenceFound);
        }
    }
}
