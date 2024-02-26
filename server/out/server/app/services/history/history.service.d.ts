import { GameService } from '@app/services/game/game.service';
import { PlayerStatus } from '@common/enums';
import { GameRoom } from '@common/game-interfaces';
import * as io from 'socket.io';
export declare class HistoryService {
    private readonly gameService;
    private pendingGames;
    constructor(gameService: GameService);
    createEntry(room: GameRoom): void;
    closeEntry(roomId: string, server: io.Server): Promise<void>;
    markPlayer(roomId: string, playerName: string, status: PlayerStatus): void;
    private getFormattedDate;
    private getFormattedTime;
    private padValue;
}
