import { Injectable } from '@angular/core';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { GameCardEvents, HistoryEvents, PlayerEvents, RoomEvents } from '@common/enums';
import { PlayerData, PlayerNameAvailability, RoomAvailability } from '@common/game-interfaces';
import { Subject } from 'rxjs';

@Injectable({
    providedIn: 'root',
})
export class RoomManagerService {
    gameMode: string;
    private joinedPlayerNames: Subject<string[]>;
    private playerNameAvailability: Subject<PlayerNameAvailability>;
    private rooms1V1AvailabilityByGameId: Subject<RoomAvailability>;
    private isPlayerAccepted: Subject<boolean>;
    private refusedPlayerId: Subject<string>;
    private roomOneVsOneId: Subject<string>;
    private roomSoloId: Subject<string>;
    private roomLimitedId: Subject<string>;
    private deletedGameId: Subject<string>;
    private isGameCardsReloadNeeded: Subject<boolean>;
    private isLimitedCoopRoomAvailable: Subject<boolean>;
    private hasNoGameAvailable: Subject<boolean>;
    private isGameHistoryReloadNeeded: Subject<boolean>;

    constructor(private readonly clientSocket: ClientSocketService) {
        this.playerNameAvailability = new Subject<PlayerNameAvailability>();
        this.roomOneVsOneId = new Subject<string>();
        this.isPlayerAccepted = new Subject<boolean>();
        this.joinedPlayerNames = new Subject<string[]>();
        this.rooms1V1AvailabilityByGameId = new Subject<RoomAvailability>();
        this.deletedGameId = new Subject<string>();
        this.refusedPlayerId = new Subject<string>();
        this.isGameCardsReloadNeeded = new Subject<boolean>();
        this.isLimitedCoopRoomAvailable = new Subject<boolean>();
        this.hasNoGameAvailable = new Subject<boolean>();
        this.roomSoloId = new Subject<string>();
        this.roomLimitedId = new Subject<string>();
        this.isGameHistoryReloadNeeded = new Subject<boolean>();
    }

    get joinedPlayerNamesByGameId$() {
        return this.joinedPlayerNames.asObservable();
    }

    get playerNameAvailability$() {
        return this.playerNameAvailability.asObservable();
    }

    get roomOneVsOneId$() {
        return this.roomOneVsOneId.asObservable();
    }

    get roomSoloId$() {
        return this.roomSoloId.asObservable();
    }

    get roomLimitedId$() {
        return this.roomLimitedId.asObservable();
    }

    get oneVsOneRoomsAvailabilityByRoomId$() {
        return this.rooms1V1AvailabilityByGameId.asObservable();
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

    get isLimitedCoopRoomAvailable$() {
        return this.isLimitedCoopRoomAvailable.asObservable();
    }

    get hasNoGameAvailable$() {
        return this.hasNoGameAvailable.asObservable();
    }

    get isGameHistoryReloadNeeded$() {
        return this.isGameHistoryReloadNeeded.asObservable();
    }

    setGameMode(gameMode: string) {
        this.gameMode = gameMode;
    }

    createSoloRoom(playerPayLoad: PlayerData) {
        this.clientSocket.send('game', RoomEvents.CreateClassicSoloRoom, playerPayLoad);
    }

    createOneVsOneRoom(playerPayLoad: PlayerData): void {
        this.clientSocket.send('game', RoomEvents.CreateOneVsOneRoom, playerPayLoad);
    }

    createLimitedRoom(playerPayLoad: PlayerData): void {
        this.clientSocket.send('game', RoomEvents.CreateLimitedRoom, playerPayLoad);
    }

    updateRoomOneVsOneAvailability(gameId: string): void {
        this.clientSocket.send('game', RoomEvents.UpdateRoomOneVsOneAvailability, gameId);
    }

    checkRoomOneVsOneAvailability(gameId: string): void {
        this.clientSocket.send('game', RoomEvents.CheckRoomOneVsOneAvailability, gameId);
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

    handleRoomEvents(): void {
        this.clientSocket.on('lobby', RoomEvents.RoomSoloCreated, (roomId: string) => {
            this.roomSoloId.next(roomId);
        });

        this.clientSocket.on('lobby', RoomEvents.RoomOneVsOneCreated, (roomId: string) => {
            this.roomOneVsOneId.next(roomId);
        });

        this.clientSocket.on('lobby', RoomEvents.RoomLimitedCreated, (roomId: string) => {
            this.roomLimitedId.next(roomId);
        });

        this.clientSocket.on('lobby', RoomEvents.RoomOneVsOneAvailable, (availabilityData: RoomAvailability) => {
            this.rooms1V1AvailabilityByGameId.next(availabilityData);
        });

        this.clientSocket.on('lobby', RoomEvents.OneVsOneRoomDeleted, (availabilityData: RoomAvailability) => {
            this.rooms1V1AvailabilityByGameId.next(availabilityData);
        });

        this.clientSocket.on('lobby', RoomEvents.LimitedCoopRoomJoined, () => {
            this.isLimitedCoopRoomAvailable.next(true);
        });

        this.clientSocket.on('lobby', RoomEvents.NoGameAvailable, () => {
            this.hasNoGameAvailable.next(true);
        });

        this.clientSocket.on('lobby', PlayerEvents.WaitingPlayerNameListUpdated, (waitingPlayerNameList: string[]) => {
            this.joinedPlayerNames.next(waitingPlayerNameList);
        });

        this.clientSocket.on('lobby', PlayerEvents.PlayerNameTaken, (playerNameAvailability: PlayerNameAvailability) => {
            this.playerNameAvailability.next(playerNameAvailability);
        });

        this.clientSocket.on('lobby', PlayerEvents.PlayerAccepted, (isAccepted: boolean) => {
            this.isPlayerAccepted.next(isAccepted);
        });

        this.clientSocket.on('lobby', PlayerEvents.PlayerRefused, (playerId: string) => {
            this.refusedPlayerId.next(playerId);
        });

        this.clientSocket.on('lobby', GameCardEvents.GameDeleted, (gameId: string) => {
            this.deletedGameId.next(gameId);
        });

        this.clientSocket.on('lobby', GameCardEvents.RequestReload, () => {
            this.isGameCardsReloadNeeded.next(true);
        });

        this.clientSocket.on('lobby', HistoryEvents.RequestReload, () => {
            this.isGameHistoryReloadNeeded.next(true);
        });
    }
}
