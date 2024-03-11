/* eslint-disable @typescript-eslint/no-explicit-any */
import { Injectable } from '@angular/core';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { GameCardEvents, LobbyEvents, PlayerEvents, RoomEvents } from '@common/enums';
import { Lobby, Player, PlayerData } from '@common/game-interfaces';
import { Subject } from 'rxjs';

@Injectable({
    providedIn: 'root',
})
export class RoomManagerService {
    password: string;
    isOrganizer: boolean = false;
    private lobby: Subject<Lobby>;

    private player: Player[];
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
    }

    get joinedPlayerNamesByGameId$() {
        return this.joinedPlayerNames.asObservable();
    }

    // get playerNameAvailability$() {
    //     return this.playerNameAvailability.asObservable();
    // }

    // get roomOneVsOneId$() {
    //     return this.roomOneVsOneId.asObservable();
    // }

    // get roomSoloId$() {
    //     return this.roomSoloId.asObservable();
    // }

    // get roomLimitedId$() {
    //     return this.roomLimitedId.asObservable();
    // }

    // get oneVsOneRoomsAvailabilityByRoomId$() {
    //     return this.rooms1V1AvailabilityByGameId.asObservable();
    // }

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

    // get isLimitedCoopRoomAvailable$() {
    //     return this.isLimitedCoopRoomAvailable.asObservable();
    // }

    // get hasNoGameAvailable$() {
    //     return this.hasNoGameAvailable.asObservable();
    // }

    get isGameHistoryReloadNeeded$() {
        return this.isGameHistoryReloadNeeded.asObservable();
    }

    get lobby$() {
        return this.lobby.asObservable();
    }

    get lobbies$() {
        return this.lobbies.asObservable();
    }

    createClassicRoom(roomPayload: Lobby) {
        this.clientSocket.send('lobby', LobbyEvents.Create, roomPayload);
    }

    retrieveLobbies() {
        this.clientSocket.send('lobby', LobbyEvents.UpdateLobbys);
    }

    joinRoom(lobbyId: string) {
        this.clientSocket.send('lobby', LobbyEvents.Join, lobbyId);
    }

    createOneVsOneRoom(playerPayLoad: PlayerData): void {
        this.clientSocket.send('game', RoomEvents.CreateOneVsOneRoom, playerPayLoad);
    }

    createLimitedRoom(roomPayload: Lobby): void {
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

    isPlayerNameIsAlreadyTaken(playerPayLoad: PlayerData): void {
        this.clientSocket.send('lobby', PlayerEvents.CheckIfPlayerNameIsAvailable, playerPayLoad);
    }

    refusePlayer(playerPayLoad: PlayerData): void {
        this.clientSocket.send('lobby', PlayerEvents.RefusePlayer, playerPayLoad);
    }

    acceptPlayer(gameId: string, roomId: string, playerName: string) {
        this.clientSocket.send('lobby', PlayerEvents.AcceptPlayer, { gameId, roomId, playerName });
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

    setPlayers() {
        this.lobby$.subscribe((lobby: Lobby) => {
            this.player = lobby.players;
        });
    }

    handleRoomEvents(): void {
        this.setPlayers();
        if (this.player.length >= 1)
            this.lobby$.subscribe((lobby: Lobby) => {
                this.joinRoom(lobby.lobbyId ? lobby.lobbyId : '');
            });

        this.clientSocket.on('lobby', LobbyEvents.Create, (lobby: Lobby) => {
            this.lobby.next(lobby);
        });

        this.clientSocket.on('lobby', LobbyEvents.UpdateLobbys, (lobbies: Lobby[]) => {
            this.lobbies.next(lobbies);
        });

        // this.clientSocket.on('lobby', LobbyEvents.Join, (playerNames: string[]) => {
        //     this.joinedPlayerNames.next(playerNames);
        // });
    }
}
