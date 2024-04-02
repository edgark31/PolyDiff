/* eslint-disable @typescript-eslint/naming-convention */
import { GameRecord, GameRecordDocument } from '@app/model/database/game-record';
import { DatabaseService } from '@app/services/database/database.service';
import { DEFAULT_COUNTDOWN_VALUE } from '@common/constants';
import { GameEvents } from '@common/enums';
import { Game, GameEventData, Player } from '@common/game-interfaces';
import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';

@Injectable()
export class RecordManagerService {
    constructor(
        @InjectModel(GameRecord.name) private gameRecordModel: Model<GameRecordDocument>,
        private readonly logger: Logger,
        private readonly databaseService: DatabaseService,
    ) {}

    // eslint-disable-next-line max-params
    async createGameRecord(game: Game, players: Player[], isCheatEnabled?: boolean, timeLimit?: number): Promise<GameRecord> {
        this.logger.verbose(`Record Manager from lobby :${game.lobbyId} is creating a new record for game :${game.gameId} `);
        const date = new Date();

        const gameEventData: GameEventData = {
            timestamp: Date.now(),
            gameEvent: GameEvents.StartGame,
        };

        const newRecord = new this.gameRecordModel({
            lobbyId: game.lobbyId,
            accountIds: [],
            game,
            players,
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
            await this.gameRecordModel.findOneAndUpdate({ lobbyId }, { gameEvents: eventData }).exec();
            this.logger.verbose(`Record Manager from lobby :${lobbyId} has registered ${eventData} successfully`);
        } catch (error) {
            this.logger.error(`Record Manager from lobby :${lobbyId} has failed to register ${eventData} with error: ${error}`);
        }
    }

    // account id is added to the gameRecord when players saves it
    async addAccountId(lobbyId: string, accountId: string): Promise<void> {
        try {
            await this.gameRecordModel.findOneAndUpdate({ lobbyId }, { accountIds: accountId }).exec();
        } catch (error) {
            this.logger.error(`Record Manager from lobby :${lobbyId} has failed to add the account id with error: ${error}`);
        }
    }

    async saveGameRecord(lobbyId: string): Promise<void> {
        const endTime = Date.now();
        const gameEventData: GameEventData = {
            timestamp: endTime,
            gameEvent: GameEvents.EndGame,
        };

        try {
            await this.gameRecordModel.findOneAndUpdate({ lobbyId }, { endTime }, { new: true }).exec();
            await this.gameRecordModel.findOneAndUpdate({ lobbyId }, { gameEvents: gameEventData }).exec();
        } catch (error) {
            this.logger.error(`Record Manager from lobby :${lobbyId} has failed
            to save the game record with error: ${error}`);
        }
    }

    async get(lobbyId: string): Promise<GameRecord> {
        try {
            const record = await this.gameRecordModel.findOne({ lobbyId }).exec();
            this.logger.log(`Record Manager from lobby :${lobbyId} has fetched the game record successfully`);
            return record;
        } catch (error) {
            this.logger.error(`Record Manager from lobby :${lobbyId} has failed to get the game record with error: ${error}`);
        }
    }

    // all saved game records are fetch when user wants to see his profile
    async fetchSavedGameRecordsByAccountId(accountId: string) {
        try {
            return this.gameRecordModel.find({ accountIds: accountId }).exec();
        } catch (error) {
            this.logger.error(`Record Manager has failed to fetch saved game records for accountId: ${accountId} with error: ${error}`);
        }
    }

    // player account id is removed from the gameRecord when he wants to delete it from his profile
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
}
