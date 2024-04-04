/* eslint-disable @typescript-eslint/naming-convention */
import { GameRecord, GameRecordDocument } from '@app/model/database/game-record';
import { DatabaseService } from '@app/services/database/database.service';
import { DEFAULT_COUNTDOWN_VALUE } from '@common/constants';
import { GameEvents } from '@common/enums';
import { Coordinate, Game, GameEventData, Player } from '@common/game-interfaces';
import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';

@Injectable()
export class RecordManagerService {
    private remainingDifferencesIndex = new Map<string, number[]>();
    private pendingGameRecord = new Map<string, GameRecord>();

    constructor(
        @InjectModel(GameRecord.name) private gameRecordModel: Model<GameRecordDocument>,
        private readonly logger: Logger,
        private readonly databaseService: DatabaseService,
    ) {}

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
                startTime: Date.now(),
                endTime: null,
                duration: 0,
                isCheatEnabled: isCheatEnabled != null ? isCheatEnabled : false,
                timeLimit: timeLimit != null ? timeLimit : DEFAULT_COUNTDOWN_VALUE,
                gameEvents: [gameEventData],
            };

            this.pendingGameRecord.set(game.lobbyId, newGameRecord);

            // Creates an array of index of differences to keep track of the remaining differences
            const remainingDifferencesIndex = game.differences ? Array.from({ length: game.differences.length }, (_, i) => i) : [];
            this.remainingDifferencesIndex.set(game.lobbyId, remainingDifferencesIndex);

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
            this.logger.debug(`FOUND COORDCLIC: ${eventData.coordClic.x}, ${eventData.coordClic.y}`);
            const remainingDifferenceIndex = this.getRemainingDifferenceIndex(gameRecord.game, eventData.coordClic);
            eventData.remainingDifferenceIndex = remainingDifferenceIndex;
        } else if (eventData.gameEvent === GameEvents.CheatActivated || eventData.gameEvent === GameEvents.CheatDeactivated) {
            eventData.remainingDifferenceIndex = this.remainingDifferencesIndex.get(lobbyId);
        }
        gameRecord.gameEvents.push(eventData);
    }

    closeEntry(lobbyId: string): void {
        const endTime = Date.now();
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

    // account id is added to the gameRecord when players saves it
    async updateAccountIds(recordId: string, accountId: string): Promise<void> {
        try {
            await this.gameRecordModel.findOneAndUpdate({ _id: recordId }, { accountIds: accountId }).exec();
        } catch (error) {
            this.logger.error(`Record Manager from lobby :${recordId} has failed to add the account id with error: ${error}`);
        }
    }

    async pushToDatabase(lobbyId: string): Promise<void> {
        const gameRecord = this.getPendingGameRecord(lobbyId);
        if (!gameRecord) return;

        try {
            await this.gameRecordModel.create(gameRecord);
            this.logger.verbose(`Record Manager from lobby :${lobbyId} has saved the game record successfully`);
        } catch (error) {
            this.logger.error(`Record Manager from lobby :${lobbyId} has failed`);
        }
        // Reset the pending game record
        this.pendingGameRecord.set(lobbyId, null);
        this.remainingDifferencesIndex.set(lobbyId, []);
    }

    // TODO: put theses methods in the database service
    async getById(id: string): Promise<GameRecord> {
        try {
            const record = await this.gameRecordModel.findById(id, '-__v').exec();
            this.logger.log(`Record Manager from lobby :${id} has fetched the game record successfully`);
            return record;
        } catch (error) {
            this.logger.error(`Record Manager from lobby :${id} has failed to get the game record with error: ${error}`);
        }
    }

    // all saved game records are fetch when user wants to see his profile
    async getAllByAccountId(accountId: string) {
        try {
            return await this.gameRecordModel.find({ accountIds: accountId }).exec();
        } catch (error) {
            this.logger.error(`Record Manager has failed to fetch saved game records for accountId: ${accountId} with error: ${error}`);
        }
    }

    // player account id is removed from the gameRecord when he wants to delete it from his profile
    async deleteAccountId(recordId: string, accountId: string): Promise<void> {
        await this.gameRecordModel.findOneAndUpdate({ _id: recordId }, { $pull: { accountIds: accountId } }).exec();
    }

    // if no player saves the record, it can be deleted from the database
    async deleteById(id: string): Promise<void> {
        await this.gameRecordModel.findByIdAndDelete(id).exec();
    }

    async deleteAll(): Promise<void> {
        await this.databaseService.deleteAllGameRecords();
    }

    private getRemainingDifferenceIndex(game: Game, coordinates: Coordinate): number[] {
        const foundIndex = game.differences.findIndex((differenceGroup) =>
            differenceGroup.some((coordinate) => coordinate.x === coordinates.x && coordinate.y === coordinates.y),
        );

        if (foundIndex !== -1) {
            const remainingDifferencesIndex = this.remainingDifferencesIndex.get(game.lobbyId).filter((index) => index !== foundIndex);
            this.remainingDifferencesIndex.set(game.lobbyId, remainingDifferencesIndex);
            this.logger.debug(`Record Manager found index : ${foundIndex} at coordinates ${coordinates.x} et ${coordinates.y}`);
        } else {
            this.logger.debug(`Record Manager could not find the difference at coordinates ${coordinates}`);
        }

        this.logger.debug(`Record Manager created array of index ${this.remainingDifferencesIndex}`);
        return this.remainingDifferencesIndex.get(game.lobbyId);
    }
}
