// Id comes from database to allow _id
/* eslint-disable no-underscore-dangle */
import { Game, GameDocument } from '@app/model/database/game';
import { GameCard, GameCardDocument } from '@app/model/database/game-card';
import { GameConstants, GameConstantsDocument } from '@app/model/database/game-config-constants';
import { GameHistory, GameHistoryDocument } from '@app/model/database/game-history';
import { CreateGameDto } from '@app/model/dto/game/create-game.dto';
import { GameConstantsDto } from '@app/model/dto/game/game-constants.dto';
import { GameListsManagerService } from '@app/services/game-lists-manager/game-lists-manager.service';
import { DEFAULT_BEST_TIMES, DEFAULT_BONUS_TIME, DEFAULT_COUNTDOWN_VALUE, DEFAULT_HINT_PENALTY } from '@common/constants';
import { GameModes } from '@common/enums';
import { CarouselPaginator, PlayerTime } from '@common/game-interfaces';
import { Injectable, OnModuleInit } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import * as fs from 'fs';
import { Model } from 'mongoose';

@Injectable()
export class DatabaseService implements OnModuleInit {
    private defaultConstants: GameConstants = {
        countdownTime: DEFAULT_COUNTDOWN_VALUE,
        penaltyTime: DEFAULT_HINT_PENALTY,
        bonusTime: DEFAULT_BONUS_TIME,
    };
    private gameIds: string[];
    // Services are needed for the dialog and dialog needs to talk to the parent component
    // eslint-disable-next-line max-params
    constructor(
        @InjectModel(Game.name) private readonly gameModel: Model<GameDocument>,
        @InjectModel(GameCard.name) private readonly gameCardModel: Model<GameCardDocument>,
        @InjectModel(GameConstants.name) private readonly gameConstantsModel: Model<GameConstantsDocument>,
        @InjectModel(GameHistory.name) private readonly gameHistoryModel: Model<GameHistoryDocument>,
        private readonly gameListManager: GameListsManagerService,
    ) {
        this.gameIds = [];
    }
    async onModuleInit() {
        await this.getAllGameIds();
        await this.loadGamesInServer();
    }

    async loadGamesInServer(): Promise<void> {
        try {
            // Delete les assets du server saud l'avatar bien sur
            fs.readdirSync('assets', { withFileTypes: true })
                .filter((item) => item.isDirectory() && item.name !== 'avatar')
                .forEach((item) => fs.rmdirSync(`assets/${item.name}`, { recursive: true }));

            // Database vers les assets du server
            const games = await this.gameModel.find().exec();
            games.forEach((game) => {
                this.saveFiles(game);
            });
        } catch (error) {
            return Promise.reject(`Failed to load games in server: ${error}`);
        }
    }

    async getGamesCards(): Promise<GameCard[]> {
        const originalGameCards = await this.gameCardModel.find().exec();
        const modifiedGameCards = originalGameCards.map((gameCard) => {
            const thumbnailBase64 = fs.readFileSync(gameCard.thumbnail, 'base64');
            return { ...gameCard.toObject(), thumbnail: thumbnailBase64 } as GameCard;
        });
        return modifiedGameCards;
    }

    async getGamesCarrousel(): Promise<CarouselPaginator[]> {
        if (this.gameListManager['carouselGames'].length === 0) {
            const gameCardsList: GameCard[] = await this.gameCardModel.find().exec();
            this.gameListManager.buildGameCarousel(gameCardsList);
        }
        return this.gameListManager.getCarouselGames();
    }

    async getTopTimesGameById(gameId: string, gameMode: string): Promise<PlayerTime[]> {
        const mode = gameMode === GameModes.ClassicSolo ? 'soloTopTime' : 'oneVsOneTopTime';
        try {
            const topTimes = await this.gameCardModel
                .findById(gameId)
                .sort({ [mode]: -1 })
                .exec();
            return topTimes[mode];
        } catch (error) {
            return Promise.reject(`Failed to get top times: ${error}`);
        }
    }
    async getGameById(id: string): Promise<Game> {
        try {
            return await this.gameModel.findById(id, '-__v').exec();
        } catch (error) {
            return Promise.reject(`Failed to get game: ${error}`);
        }
    }

    async getGameConstants(): Promise<GameConstants> {
        try {
            await this.populateDbWithGameConstants();
            return await this.gameConstantsModel.findOne().select('-__v -_id').exec();
        } catch (error) {
            return Promise.reject(`Failed to get game constants: ${error}`);
        }
    }

    async verifyIfGameExists(gameName: string): Promise<boolean> {
        try {
            return Boolean(await this.gameModel.exists({ name: gameName }));
        } catch (error) {
            return Promise.reject(`Failed to verify if game exists: ${error}`);
        }
    }

    saveFiles(newGame: Game): void {
        const dirName = `assets/${newGame._id.toString()}`;
        const dataOfOriginalImage = Buffer.from(newGame.originalImage.replace(/^data:image\/\w+;base64,/, ''), 'base64');
        const dataOfModifiedImage = Buffer.from(newGame.modifiedImage.replace(/^data:image\/\w+;base64,/, ''), 'base64');
        if (!fs.existsSync(dirName)) {
            fs.mkdirSync(dirName);
            fs.writeFileSync(`assets/${newGame._id.toString()}/original.bmp`, dataOfOriginalImage);
            fs.writeFileSync(`assets/${newGame._id.toString()}/modified.bmp`, dataOfModifiedImage);
            fs.writeFileSync(`assets/${newGame._id.toString()}/differences.json`, JSON.stringify(newGame.differences));
        }
    }

    async addGameInDb(newGame: CreateGameDto): Promise<void> {
        try {
            const newGameInDB: Game = {
                name: newGame.name,
                originalImage: newGame.originalImage,
                modifiedImage: newGame.modifiedImage,
                differences: JSON.stringify(newGame.differences),
                nDifference: newGame.nDifference,
                isHard: newGame.isHard,
            };
            const id = (await this.gameModel.create(newGameInDB))._id.toString();
            this.gameIds.push(id);
            newGameInDB._id = id;
            this.saveFiles(newGameInDB);
            const gameCard = this.gameListManager.buildGameCardFromGame(newGameInDB);
            await this.gameCardModel.create(gameCard);
            this.gameListManager.addGameCarousel(gameCard);
        } catch (error) {
            return Promise.reject(`Failed to insert game: ${error}`);
        }
    }

    deleteGameAssetsByName(gameName: string): void {
        fs.unlinkSync(`assets/${gameName}/original.bmp`);
        fs.unlinkSync(`assets/${gameName}/modified.bmp`);
        fs.unlinkSync(`assets/${gameName}/differences.json`);
        fs.rmdirSync(`assets/${gameName}/`);
    }

    async deleteGameById(id: string): Promise<void> {
        try {
            this.gameIds = this.gameIds.filter((gameId) => gameId !== id);
            await this.gameModel.findByIdAndDelete(id).exec();
            const gameName = (await this.gameCardModel.findByIdAndDelete(id).exec()).name;
            this.deleteGameAssetsByName(gameName);
            await this.rebuildGameCarousel();
        } catch (error) {
            return Promise.reject(`Failed to delete game with id : ${id} --> ${error}`);
        }
    }

    async deleteAllGames() {
        try {
            this.gameIds = [];
            this.gameListManager.buildGameCarousel([]);
            const gamesName = (await this.gameModel.find().select('-_id name').exec()).map((game) => game.name);
            for (const gameName of gamesName) {
                this.deleteGameAssetsByName(gameName);
            }
            await this.gameModel.deleteMany({}).exec();
            await this.gameCardModel.deleteMany({}).exec();
        } catch (error) {
            return Promise.reject(`Failed to delete all games --> ${error}`);
        }
    }

    async updateTopTimesGameById(id: string, gameMode: string, topTimes: PlayerTime[]): Promise<void> {
        try {
            const mode = gameMode === GameModes.ClassicSolo ? 'soloTopTime' : 'oneVsOneTopTime';
            await this.gameCardModel.findByIdAndUpdate(id, { [mode]: topTimes }).exec();
            await this.rebuildGameCarousel();
        } catch (error) {
            return Promise.reject(`Failed to update top times game with id : ${id} --> ${error}`);
        }
    }

    async updateGameConstants(gameConstantsDto: GameConstantsDto): Promise<void> {
        try {
            await this.gameConstantsModel.replaceOne({}, gameConstantsDto).exec();
        } catch (error) {
            return Promise.reject(`Failed to update game constants --> ${error}`);
        }
    }

    async resetTopTimesGameById(gameId: string) {
        try {
            await this.gameCardModel.findByIdAndUpdate(gameId, { soloTopTime: DEFAULT_BEST_TIMES, oneVsOneTopTime: DEFAULT_BEST_TIMES }).exec();
            await this.rebuildGameCarousel();
        } catch (error) {
            return Promise.reject(`Failed to reset top times game with id : ${gameId} --> ${error}`);
        }
    }

    async resetAllTopTimes() {
        try {
            await this.gameCardModel.updateMany({}, { soloTopTime: DEFAULT_BEST_TIMES, oneVsOneTopTime: DEFAULT_BEST_TIMES }).exec();
            await this.rebuildGameCarousel();
        } catch (error) {
            return Promise.reject(`Failed to reset all top times --> ${error}`);
        }
    }

    async getRandomGame(playedGameIds: string[]): Promise<Game> {
        try {
            const gameIdsToPlay = this.gameIds.filter((id) => !playedGameIds.includes(id));
            const randomGameId = gameIdsToPlay[Math.floor(Math.random() * gameIdsToPlay.length)];
            return await this.getGameById(randomGameId);
        } catch (error) {
            return Promise.reject(`Failed to get random game --> ${error}`);
        }
    }

    async getGamesHistory(): Promise<GameHistory[]> {
        try {
            return await this.gameHistoryModel.find().select('-__v -_id').exec();
        } catch (error) {
            return Promise.reject(`Failed to get games history --> ${error}`);
        }
    }

    async saveGameHistory(gameHistory: GameHistory): Promise<void> {
        try {
            await this.gameHistoryModel.create(gameHistory);
        } catch (error) {
            return Promise.reject(`Failed to add game history --> ${error}`);
        }
    }

    async deleteAllGamesHistory() {
        try {
            await this.gameHistoryModel.deleteMany({}).exec();
        } catch (error) {
            return Promise.reject(`Failed to delete all games history --> ${error}`);
        }
    }

    private async populateDbWithGameConstants(): Promise<void> {
        try {
            if (!(await this.gameConstantsModel.exists({}))) {
                await this.gameConstantsModel.create(this.defaultConstants);
            }
        } catch (error) {
            return Promise.reject(`Failed to populate game constants --> ${error}`);
        }
    }

    private async getAllGameIds(): Promise<void> {
        try {
            const gameCardsIds = await this.gameCardModel.find().select('_id').exec();
            this.gameIds = gameCardsIds.map((gameCard) => gameCard._id.toString());
        } catch (error) {
            return Promise.reject(`Failed to get all game ids --> ${error}`);
        }
    }

    private async rebuildGameCarousel(): Promise<void> {
        const gameCardsList: GameCard[] = await this.gameCardModel.find().exec();
        this.gameListManager.buildGameCarousel(gameCardsList);
    }
}
