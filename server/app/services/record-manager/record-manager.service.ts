/* eslint-disable no-underscore-dangle */
import { GameRecord } from '@app/model/database/game-record';
import { DEFAULT_COUNTDOWN_VALUE } from '@common/constants';
import { GameEvents } from '@common/enums';
import { Coordinate, Game, GameEventData, Player } from '@common/game-interfaces';
import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { FilterQuery, Model } from 'mongoose';

@Injectable()
export class RecordManagerService {
    private pendingGameRecord = new Map<string, GameRecord>();
    private remainingDifferencesIndex: number[];

    constructor(@InjectModel(GameRecord.name) private gameRecordModel: Model<GameRecord>, private readonly logger: Logger) {}

    // eslint-disable-next-line max-params
    createEntry(game: Game, players: Player[], isCheatEnabled?: boolean, timeLimit?: number): void {
        this.logger.verbose(`Record Manager from lobby :${game.lobbyId} is creating a new record for game :${game.gameId} `);

        try {
            const date = new Date();

            const gameEventData: GameEventData = {
                timestamp: Date.now(),
                gameEvent: GameEvents.StartGame,
            };
            const newGameRecord: GameRecord = {
                accountIds: [],
                game,
                players,
                date,
                startTime: date.getTime(),
                endTime: null,
                duration: 0,
                isCheatEnabled: isCheatEnabled != null ? isCheatEnabled : false,
                timeLimit: timeLimit != null ? timeLimit : DEFAULT_COUNTDOWN_VALUE,
                gameEvents: [gameEventData],
            };

            this.pendingGameRecord.set(game.lobbyId, newGameRecord);

            // Creates an array of index of differences to keep track of the remaining differences
            this.remainingDifferencesIndex = game.differences ? Array.from({ length: game.differences.length }, (_, i) => i) : [];

            this.logger.log(`Record Manager created array of index ${this.remainingDifferencesIndex}`);
            this.logger.verbose(`Record Manager from lobby :${game.lobbyId} has created a new record with id :${newGameRecord}`);
        } catch (error) {
            this.logger.error(`Failed to insert GameRecord: ${error}`);
        }
    }

    addGameEvent(lobbyId: string, eventData: GameEventData): void {
        eventData.timestamp = Date.now();

        const gameRecord = this.getPendingGameRecord(lobbyId);
        if (!gameRecord) return;

        if (eventData.gameEvent === GameEvents.Found) {
            const remainingDifferenceIndex = this.getRemainingDifferenceIndex(gameRecord.game, eventData.coordClic);
            eventData.remainingDifferenceIndex = remainingDifferenceIndex;
        }

        gameRecord.gameEvents.push(eventData);
    }

    closeEntry(lobbyId: string): void {
        const endTime = new Date().getTime();
        const gameEventData: GameEventData = {
            timestamp: endTime,
            gameEvent: GameEvents.EndGame,
        };

        const gameRecord = this.getPendingGameRecord(lobbyId);
        if (!gameRecord) return;

        gameRecord.endTime = endTime;
        gameRecord.duration = endTime - gameRecord.startTime;
        gameRecord.gameEvents.push(gameEventData);

        this.pendingGameRecord.set(lobbyId, gameRecord);
    }

    getPendingGameRecord(lobbyId: string): GameRecord {
        return this.pendingGameRecord.get(lobbyId);
    }

    async post(lobbyId: string): Promise<void> {
        const gameRecord = this.getPendingGameRecord(lobbyId);
        if (!gameRecord) return;

        try {
            await this.gameRecordModel.create(gameRecord);

            this.logger.verbose(`Record Manager from lobby :${lobbyId} has saved the game record successfully`);
        } catch (error) {
            this.logger.error(`Record Manager from lobby :${lobbyId} has failed`);
        }
        // Reset the pending game record
        this.pendingGameRecord = new Map<string, GameRecord>();
        this.remainingDifferencesIndex = [];
    }

    // the date of the game record is used to fetch it from the database
    async findOne(dateFilterQuery: FilterQuery<GameRecord>): Promise<GameRecord> {
        return await this.gameRecordModel.findOne({ dateFilterQuery }).exec();
    }

    async findAll(): Promise<GameRecord[]> {
        return await this.gameRecordModel.find().exec();
    }

    async findAllByAccountId(accountId: string): Promise<GameRecord[]> {
        return await this.gameRecordModel.find({ accountIds: accountId }).exec();
    }

    async addAccountId(date: string, accountId: string): Promise<void> {
        try {
            await this.gameRecordModel.findOneAndUpdate({ date }, { $addToSet: { accountIds: accountId } }).exec();
            this.logger.log(`Record Manager has added account id :${accountId} to the game record with date :${date}`);
        } catch (error) {
            return Promise.reject(`Failed to update game record: ${error}`);
        }
    }

    // if no player saves the record, it can be deleted from the database
    async deleteAccountId(date: string, accountId: string): Promise<void> {
        try {
            await this.gameRecordModel.findOneAndUpdate({ date }, { $pull: { accountIds: accountId } }).exec();
            this.logger.log(`Record Manager has deleted account id :${accountId} from the game record with date :${date}`);
        } catch (error) {
            return Promise.reject(`Failed to update game record: ${error}`);
        }
    }

    async deleteOne(dateFilterQuery: FilterQuery<GameRecord>): Promise<void> {
        await this.gameRecordModel.findOneAndDelete({ dateFilterQuery }).exec();
    }

    async deleteAll(): Promise<void> {
        await this.gameRecordModel.deleteMany({}).exec();
    }

    private getRemainingDifferenceIndex(game: Game, coordinates: Coordinate): number[] {
        game.differences.forEach((difference, index) => {
            if (difference[0].x === coordinates.x || difference[0].y === coordinates.y) {
                const foundIndex = index;
                this.remainingDifferencesIndex = this.remainingDifferencesIndex.filter((value) => value !== foundIndex);
            }
        });
        this.logger.debug(`Record Manager created array of index ${this.remainingDifferencesIndex}`);
        return this.remainingDifferencesIndex;
    }
}
