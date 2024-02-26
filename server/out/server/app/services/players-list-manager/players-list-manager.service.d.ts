import { GameService } from '@app/services/game/game.service';
import { MessageManagerService } from '@app/services/message-manager/message-manager.service';
import { GameRoom, Player, PlayerData } from '@common/game-interfaces';
import * as io from 'socket.io';
export declare class PlayersListManagerService {
    private readonly gameService;
    private readonly messageManagerService;
    private joinedPlayersByGameId;
    constructor(gameService: GameService, messageManagerService: MessageManagerService);
    updateWaitingPlayerNameList(playerPayLoad: PlayerData, socket: io.Socket): void;
    getWaitingPlayerNameList(hostId: string, gameId: string, server: io.Server): void;
    refusePlayer(playerPayLoad: PlayerData, server: io.Server): void;
    getAcceptPlayer(gameId: string, server: io.Server): Player;
    checkIfPlayerNameIsAvailable(playerPayLoad: PlayerData, server: io.Server): void;
    cancelJoiningByPlayerId(playerId: string, gameId: string): void;
    cancelAllJoining(gameId: string, server: io.Server): void;
    getGameIdByPlayerId(playerId: string): string;
    deleteJoinedPlayerByPlayerId(playerId: string, gameId: string): void;
    resetAllTopTime(server: io.Server): Promise<void>;
    deleteJoinedPlayersByGameId(gameId: string): void;
    resetTopTime(gameId: string, server: io.Server): Promise<void>;
    updateTopBestTime(room: GameRoom, playerName: string, server: io.Server): Promise<number>;
    private cancelJoiningByPlayerName;
    private getPlayerIdByPlayerName;
    private insertNewTopTime;
    private sendNewTopTimeMessage;
}
