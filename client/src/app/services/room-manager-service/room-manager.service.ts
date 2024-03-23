/* eslint-disable @typescript-eslint/no-explicit-any */
import { Injectable } from '@angular/core';

import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { ChannelEvents, GameCardEvents, LobbyEvents } from '@common/enums';
import { Chat, Game, Lobby } from '@common/game-interfaces';
import { Subject } from 'rxjs';

@Injectable({
    providedIn: 'root',
})
export class RoomManagerService {
    password: string;
    lobbyGame: Lobby;
    isOrganizer: boolean;
    lobby: Subject<Lobby>;
    wait: boolean;
    game: Game;

    private lobbies: Subject<Lobby[]>;
    private joinedPlayerNames: Subject<string[]>;
    // private playerNameAvailability: Subject<PlayerNameAvailability>;
    // private rooms1V1AvailabilityByGameId: Subject<RoomAvailability>;
    private isPlayerAccepted: Subject<boolean>;
    private refusedPlayerId: Subject<string>;
    // private roomOneVsOneId: Subject<string>;
    // private roomSoloId: Subject<string>;
    // private roomLimitedId: Subject<string>;
    private deletedGameId: Subject<string>;
    private isGameCardsReloadNeeded: Subject<boolean>;
    // private isLimitedCoopRoomAvailable: Subject<boolean>;
    // private hasNoGameAvailable: Subject<boolean>;
    private isGameHistoryReloadNeeded: Subject<boolean>;
    private messages: Subject<Chat[]>;
    private message: Subject<Chat>;

    constructor(private readonly clientSocket: ClientSocketService) {
        // this.playerNameAvailability = new Subject<PlayerNameAvailability>();
        // this.roomOneVsOneId = new Subject<string>();
        // this.isPlayerAccepted = new Subject<boolean>();
        this.lobby = new Subject<Lobby>();
        this.lobbies = new Subject<Lobby[]>();
        this.joinedPlayerNames = new Subject<string[]>();
        // this.rooms1V1AvailabilityByGameId = new Subject<RoomAvailability>();
        this.deletedGameId = new Subject<string>();
        // this.refusedPlayerId = new Subject<string>();
        this.isGameCardsReloadNeeded = new Subject<boolean>();
        // this.isLimitedCoopRoomAvailable = new Subject<boolean>();
        // this.hasNoGameAvailable = new Subject<boolean>();
        // this.roomSoloId = new Subject<string>();
        // this.roomLimitedId = new Subject<string>();
        this.isGameHistoryReloadNeeded = new Subject<boolean>();
        this.messages = new Subject<Chat[]>();
        this.message = new Subject<Chat>();
    }

    get joinedPlayerNamesByGameId$() {
        return this.joinedPlayerNames.asObservable();
    }

    get messages$() {
        return this.messages.asObservable();
    }

    get message$() {
        return this.message.asObservable();
    }

    get isPlayerAccepted$() {
        return this.isPlayerAccepted.asObservable();
    }

    get deletedGameId$() {
        return this.deletedGameId.asObservable();
    }

    get refusedPlayerId$() {
        return this.refusedPlayerId.asObservable();
    }

    get isReloadNeeded$() {
        return this.isGameCardsReloadNeeded.asObservable();
    }

    get isGameHistoryReloadNeeded$() {
        return this.isGameHistoryReloadNeeded.asObservable();
    }

    get lobby$() {
        return this.lobby.asObservable();
    }

    get lobbies$() {
        return this.lobbies.asObservable();
    }

    off(): void {
        if (this.lobby && !this.lobby.closed) {
            this.lobby?.unsubscribe();
        }
        if (this.message && !this.message.closed) this.message?.unsubscribe();
        if (this.lobbies && !this.lobbies.closed) this.lobbies?.unsubscribe();
    }

    sendMessage(lobbyId: string | undefined, message: string): void {
        this.clientSocket.send('lobby', ChannelEvents.SendLobbyMessage, { lobbyId, message });
    }

    createClassicRoom(roomPayload: Lobby) {
        this.isOrganizer = true;
        this.clientSocket.send('lobby', LobbyEvents.Create, roomPayload);
    }

    retrieveLobbies() {
        this.clientSocket.send('lobby', LobbyEvents.UpdateLobbys);
    }

    joinRoom(lobbyId: string) {
        this.clientSocket.send('lobby', LobbyEvents.Join, { lobbyId });
    }

    joinRoomAcces(lobbyId: string, password: string) {
        this.clientSocket.send('lobby', LobbyEvents.Join, { lobbyId, password });
    }

    createLimitedRoom(roomPayload: Lobby): void {
        this.isOrganizer = true;
        this.clientSocket.send('lobby', LobbyEvents.Create, roomPayload);
    }

    onQuit(lobby: Lobby): void {
        this.clientSocket.send('lobby', LobbyEvents.Leave, lobby.lobbyId);
        if (this.isOrganizer) this.isOrganizer = false;
    }

    onStart(id: string) {
        this.clientSocket.send('lobby', LobbyEvents.Start, id);
    }

    notifyGameCardCreated() {
        this.clientSocket.send('game', GameCardEvents.GameCardCreated);
    }

    notifyGameCardDeleted(gameId: string) {
        this.clientSocket.send(GameCardEvents.GameCardDeleted, gameId);
    }

    notifyAllGamesDeleted() {
        this.clientSocket.send('game', GameCardEvents.AllGamesDeleted);
    }

    notifyResetTopTime(gameId: string) {
        this.clientSocket.send('game', GameCardEvents.ResetTopTime, gameId);
    }

    notifyResetAllTopTimes() {
        this.clientSocket.send('game', GameCardEvents.ResetAllTopTimes);
    }

    notifyGameConstantsUpdated() {
        this.clientSocket.send('game', GameCardEvents.GameConstantsUpdated);
    }

    notifyGamesHistoryDeleted() {
        this.clientSocket.send('game', GameCardEvents.GamesHistoryDeleted);
    }

    getSocketId(): string {
        return this.clientSocket.lobbySocket.id;
    }

    removeAllListeners() {
        this.clientSocket.lobbySocket.off();
    }

    handleRoomEvents(): void {
        if (this.isOrganizer)
            this.clientSocket.on('lobby', LobbyEvents.Create, (lobby: Lobby) => {
                this.lobby.next(lobby);
                this.lobbyGame = lobby;
            });
        else
            this.clientSocket.on('lobby', LobbyEvents.Join, (lobby: Lobby) => {
                this.lobbyGame = lobby;
                this.lobby.next(lobby);
            });

        this.clientSocket.on('lobby', LobbyEvents.UpdateLobbys, (lobbies: Lobby[]) => {
            this.lobbies.next(lobbies);
        });

        this.clientSocket.on('lobby', LobbyEvents.UpdateLobbys, (lobbies: Lobby[]) => {
            this.lobbies.next(lobbies);
        });
        this.clientSocket.on('lobby', ChannelEvents.LobbyMessage, (chat: Chat) => {
            this.message.next(chat);
        });
    }
}
