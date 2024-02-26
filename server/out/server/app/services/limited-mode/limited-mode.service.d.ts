import { RoomsManagerService } from '@app/services/rooms-manager/rooms-manager.service';
import { PlayerData } from '@common/game-interfaces';
import * as io from 'socket.io';
import { HistoryService } from '@app/services/history/history.service';
export declare class LimitedModeService {
    private readonly roomsManagerService;
    private readonly historyService;
    private availableGameByRoomId;
    constructor(roomsManagerService: RoomsManagerService, historyService: HistoryService);
    createLimitedRoom(socket: io.Socket, playerPayLoad: PlayerData, server: io.Server): Promise<void>;
    startNextGame(socket: io.Socket, server: io.Server): Promise<void>;
    checkIfAnyCoopRoomExists(socket: io.Socket, playerPayLoad: PlayerData, server: io.Server): void;
    deleteAvailableGame(roomId: string): void;
    handleDeleteGame(gameId: string): void;
    handleDeleteAllGames(): void;
    private joinLimitedCoopRoom;
    private getGameIds;
    private endGame;
    private equalizeDifferencesFound;
    private sendEndMessage;
}
