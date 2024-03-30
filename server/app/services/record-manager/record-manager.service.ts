import { GameRecord, GameRecordDocument } from '@app/model/database/game-record';
import { DatabaseService } from '@app/services/database/database.service';
import { DEFAULT_COUNTDOWN_VALUE, PADDING_N_DIGITS } from '@common/constants';
import { GameEvents } from '@common/enums';
import { Game, GameEventData } from '@common/game-interfaces';
import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';

@Injectable()
export class RecordManagerService {
    private pendingGames: Map<string, GameRecord>;

    constructor(
        @InjectModel(GameRecord.name) private gameRecordModel: Model<GameRecordDocument>,
        private readonly logger: Logger,
        private readonly databaseService: DatabaseService,
    ) {}

    // eslint-disable-next-line max-params
    async createGameRecord(game: Game, username: string, isCheatEnabled?: boolean, timeLimit?: number): Promise<GameRecord> {
        this.logger.verbose(`Record Manager from lobby :${game.lobbyId} is creating a new record for game :${game.gameId} `);
        const date = new Date();

        const gameEventData: GameEventData = {
            username,
            players: [],
            timestamp: Date.now(),
            gameEvent: GameEvents.StartGame,
        };

        const newRecord = new this.gameRecordModel({
            game,
            date,
            startTime: Date.now(),
            isCheatEnabled: isCheatEnabled != null ? isCheatEnabled : false,
            timeLimit: timeLimit != null ? timeLimit : DEFAULT_COUNTDOWN_VALUE,
            gameEvents: [gameEventData],
        });
        return newRecord.save();
    }

    async addGameEvent(lobbyId: string, eventData: GameEventData): Promise<void> {
        eventData.timestamp = Date.now();
        try {
            await this.gameRecordModel.findOneAndUpdate({ lobbyId }, { $push: { gameEvents: eventData } }, { new: true });
            this.logger.verbose(`Record Manager from lobby :${lobbyId} has registered ${eventData} successfully`);
        } catch (error) {
            this.logger.error(`Record Manager from lobby :${lobbyId} has failed to register ${eventData} with error: ${error}`);
        }
    }

    // the player account id is added to the gameRecord when he wants to save it to view in his profile
    async addAccountId(lobbyId: string, accountId: string): Promise<void> {
        await this.gameRecordModel.findOneAndUpdate({ lobbyId }, { $push: { accountIds: accountId } }, { new: true });
    }

    async saveGameRecord(lobbyId: string): Promise<void> {
        const endTime = Date.now();
        try {
            await this.gameRecordModel.findOneAndUpdate({ lobbyId }, { endTime }, { new: true });
        } catch (error) {
            this.logger.error(`Record Manager from lobby :${lobbyId} has failed
            to save the game record with error: ${error}`);
        }
    }

    async getRecordedGameByLobbyId(lobbyId: string): Promise<GameRecord> {
        return this.gameRecordModel.findOne({ lobbyId });
    }

    // the player account id is removed from the gameRecord when he wants to delete it from his profile
    async deleteAccountId(lobbyId: string, accountId: string): Promise<void> {
        await this.gameRecordModel.findOneAndUpdate({ lobbyId }, { $pull: { accountIds: accountId } }, { new: true });
    }

    // if no player saves the record, it can be deleted from the database
    async deleteOneGameRecordByLobbyId(lobbyId: string): Promise<void> {
        await this.gameRecordModel.deleteOne({ lobbyId });
    }

    async deleteAllGameRecords(): Promise<void> {
        await this.databaseService.deleteAllGameRecords();
    }

    private getFormattedDate(date: Date): string {
        const month = this.padValue(date.getMonth() + 1);
        const day = this.padValue(date.getDate());
        const year = date.getFullYear();

        return `${year}-${month}-${day}`;
    }

    private getFormattedTime(date: Date): string {
        const hours = this.padValue(date.getHours());
        const minutes = this.padValue(date.getMinutes());
        const seconds = this.padValue(date.getSeconds());

        return `${hours}:${minutes}:${seconds}`;
    }

    private padValue(value: number): string {
        return value.toString().padStart(PADDING_N_DIGITS, '0');
    }
}
