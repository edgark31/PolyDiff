/* eslint-disable @typescript-eslint/no-explicit-any */
import { Injectable } from '@angular/core';

import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { ChannelEvents, GameCardEvents, LobbyEvents, PlayerEvents, RoomEvents } from '@common/enums';
import { Chat, Game, Lobby, PlayerData } from '@common/game-interfaces';
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
        this.lobby = new Subject<Lobby>();
        this.lobbies = new Subject<Lobby[]>();
        this.joinedPlayerNames = new Subject<string[]>();
        this.deletedGameId = new Subject<string>();
        this.isGameCardsReloadNeeded = new Subject<boolean>();
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
        this.clientSocket.lobbySocket.off(LobbyEvents.Create);
        this.clientSocket.authSocket.off(LobbyEvents.Join);
        this.clientSocket.lobbySocket.off(LobbyEvents.UpdateLobbys);
        this.clientSocket.authSocket.off(ChannelEvents.LobbyMessage);
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

    createOneVsOneRoom(playerPayLoad: PlayerData): void {
        this.clientSocket.send('game', RoomEvents.CreateOneVsOneRoom, playerPayLoad);
    }

    createLimitedRoom(roomPayload: Lobby): void {
        this.isOrganizer = true;
        this.clientSocket.send('lobby', LobbyEvents.Create, roomPayload);
    }

    createPracticeRoom(roomPayload: Lobby): void {
        this.isOrganizer = true;
        this.clientSocket.send('lobby', LobbyEvents.Create, roomPayload);
    }

    updateRoomOneVsOneAvailability(gameId: string): void {
        this.clientSocket.send('game', RoomEvents.UpdateRoomOneVsOneAvailability, gameId);
    }

    checkRoomOneVsOneAvailability(gameId: string): void {
        this.clientSocket.send('lobby', RoomEvents.CheckRoomOneVsOneAvailability, gameId);
    }

    deleteCreatedOneVsOneRoom(roomId: string) {
        this.clientSocket.send('game', RoomEvents.DeleteCreatedOneVsOneRoom, roomId);
    }

    deleteCreatedCoopRoom(roomId: string) {
        this.clientSocket.send('game', RoomEvents.DeleteCreatedCoopRoom, roomId);
    }

    getJoinedPlayerNames(gameId: string): void {
        this.clientSocket.send('game', PlayerEvents.GetJoinedPlayerNames, gameId);
    }

    updateWaitingPlayerNameList(playerPayLoad: PlayerData): void {
        this.clientSocket.send('lobby', PlayerEvents.UpdateWaitingPlayerNameList, playerPayLoad);
    }

    onQuit(lobby: Lobby): void {
        this.clientSocket.send('lobby', LobbyEvents.Leave, lobby.lobbyId);
        if (this.isOrganizer) this.isOrganizer = false;
    }

    isPlayerNameIsAlreadyTaken(playerPayLoad: PlayerData): void {
        this.clientSocket.send('lobby', PlayerEvents.CheckIfPlayerNameIsAvailable, playerPayLoad);
    }

    refusePlayer(playerPayLoad: PlayerData): void {
        this.clientSocket.send('lobby', PlayerEvents.RefusePlayer, playerPayLoad);
    }

    acceptPlayer(gameId: string, roomId: string, playerName: string) {
        this.clientSocket.send('lobby', PlayerEvents.AcceptPlayer, { gameId, roomId, playerName });
    }

    onStart(id: string) {
        this.clientSocket.send('lobby', LobbyEvents.Start, id);
    }
    cancelJoining(gameId: string): void {
        this.clientSocket.send('lobby', PlayerEvents.CancelJoining, gameId);
    }

    checkIfAnyCoopRoomExists(playerPayLoad: PlayerData) {
        this.clientSocket.send('game', RoomEvents.CheckIfAnyCoopRoomExists, playerPayLoad);
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

    async setPlayers() {
        // this.lobby$.subscribe((lobby: Lobby) => {
        //     this.player = lobby.players;
        // });
    }

    handleRoomEvents(): void {
        this.lobby = new Subject<Lobby>();
        this.lobbies = new Subject<Lobby[]>();
        this.message = new Subject<Chat>();
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
