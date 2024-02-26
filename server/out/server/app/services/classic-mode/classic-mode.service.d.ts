import { HistoryService } from '@app/services/history/history.service';
import { PlayersListManagerService } from '@app/services/players-list-manager/players-list-manager.service';
import { RoomsManagerService } from '@app/services/rooms-manager/rooms-manager.service';
import { GameRoom, Player, PlayerData } from '@common/game-interfaces';
import * as io from 'socket.io';
export declare class ClassicModeService {
    private readonly roomsManagerService;
    private readonly historyService;
    private readonly playersListManagerService;
    private roomAvailability;
    constructor(roomsManagerService: RoomsManagerService, historyService: HistoryService, playersListManagerService: PlayersListManagerService);
    createSoloRoom(socket: io.Socket, playerPayLoad: PlayerData, server: io.Server): Promise<void>;
    createOneVsOneRoom(socket: io.Socket, playerPayLoad: PlayerData, server: io.Server): Promise<void>;
    deleteCreatedRoom(hostId: string, roomId: string, server: io.Server): void;
    deleteOneVsOneAvailability(socket: io.Socket, server: io.Server): void;
    checkStatus(socket: io.Socket, server: io.Server): Promise<void>;
    endGame(room: GameRoom, player: Player, server: io.Server): Promise<void>;
    updateRoomOneVsOneAvailability(hostId: string, gameId: string, server: io.Server): void;
    checkRoomOneVsOneAvailability(hostId: string, gameId: string, server: io.Server): void;
    acceptPlayer(acceptedPlayer: Player, roomId: string, server: io.Server): void;
    handleSocketDisconnect(socket: io.Socket, server: io.Server): Promise<void>;
    private handleDisconnectBeforeCreated;
    private handleDisconnectBeforeStarted;
    private handleGuestDisconnect;
    private createClassicRoom;
    private getGameIdByHostId;
}
