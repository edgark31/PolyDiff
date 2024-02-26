"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.DatabaseService = void 0;
const game_1 = require("../../model/database/game");
const game_card_1 = require("../../model/database/game-card");
const game_config_constants_1 = require("../../model/database/game-config-constants");
const game_history_1 = require("../../model/database/game-history");
const game_lists_manager_service_1 = require("../game-lists-manager/game-lists-manager.service");
const constants_1 = require("../../../../common/constants");
const enums_1 = require("../../../../common/enums");
const common_1 = require("@nestjs/common");
const mongoose_1 = require("@nestjs/mongoose");
const fs = require("fs");
const mongoose_2 = require("mongoose");
let DatabaseService = class DatabaseService {
    constructor(gameModel, gameCardModel, gameConstantsModel, gameHistoryModel, gameListManager) {
        this.gameModel = gameModel;
        this.gameCardModel = gameCardModel;
        this.gameConstantsModel = gameConstantsModel;
        this.gameHistoryModel = gameHistoryModel;
        this.gameListManager = gameListManager;
        this.defaultConstants = {
            countdownTime: constants_1.DEFAULT_COUNTDOWN_VALUE,
            penaltyTime: constants_1.DEFAULT_HINT_PENALTY,
            bonusTime: constants_1.DEFAULT_BONUS_TIME,
        };
        this.gameIds = [];
    }
    async onModuleInit() {
        await this.getAllGameIds();
    }
    async getGamesCarrousel() {
        if (this.gameListManager['carouselGames'].length === 0) {
            const gameCardsList = await this.gameCardModel.find().exec();
            this.gameListManager.buildGameCarousel(gameCardsList);
        }
        return this.gameListManager.getCarouselGames();
    }
    async getTopTimesGameById(gameId, gameMode) {
        const mode = gameMode === enums_1.GameModes.ClassicSolo ? 'soloTopTime' : 'oneVsOneTopTime';
        try {
            const topTimes = await this.gameCardModel
                .findById(gameId)
                .sort({ [mode]: -1 })
                .exec();
            return topTimes[mode];
        }
        catch (error) {
            return Promise.reject(`Failed to get top times: ${error}`);
        }
    }
    async getGameById(id) {
        try {
            return await this.gameModel.findById(id, '-__v').exec();
        }
        catch (error) {
            return Promise.reject(`Failed to get game: ${error}`);
        }
    }
    async getGameConstants() {
        try {
            await this.populateDbWithGameConstants();
            return await this.gameConstantsModel.findOne().select('-__v -_id').exec();
        }
        catch (error) {
            return Promise.reject(`Failed to get game constants: ${error}`);
        }
    }
    async verifyIfGameExists(gameName) {
        try {
            return Boolean(await this.gameModel.exists({ name: gameName }));
        }
        catch (error) {
            return Promise.reject(`Failed to verify if game exists: ${error}`);
        }
    }
    saveFiles(newGame) {
        const dirName = `assets/${newGame.name}`;
        const dataOfOriginalImage = Buffer.from(newGame.originalImage.replace(/^data:image\/\w+;base64,/, ''), 'base64');
        const dataOfModifiedImage = Buffer.from(newGame.modifiedImage.replace(/^data:image\/\w+;base64,/, ''), 'base64');
        if (!fs.existsSync(dirName)) {
            fs.mkdirSync(dirName);
            fs.writeFileSync(`assets/${newGame.name}/original.bmp`, dataOfOriginalImage);
            fs.writeFileSync(`assets/${newGame.name}/modified.bmp`, dataOfModifiedImage);
            fs.writeFileSync(`assets/${newGame.name}/differences.json`, JSON.stringify(newGame.differences));
        }
    }
    async addGameInDb(newGame) {
        try {
            const newGameInDB = {
                name: newGame.name,
                originalImage: `assets/${newGame.name}/original.bmp`,
                modifiedImage: `assets/${newGame.name}/modified.bmp`,
                differences: `assets/${newGame.name}/differences.json`,
                nDifference: newGame.nDifference,
                isHard: newGame.isHard,
            };
            this.saveFiles(newGame);
            const id = (await this.gameModel.create(newGameInDB))._id.toString();
            this.gameIds.push(id);
            newGameInDB._id = id;
            const gameCard = this.gameListManager.buildGameCardFromGame(newGameInDB);
            await this.gameCardModel.create(gameCard);
            this.gameListManager.addGameCarousel(gameCard);
        }
        catch (error) {
            return Promise.reject(`Failed to insert game: ${error}`);
        }
    }
    deleteGameAssetsByName(gameName) {
        fs.unlinkSync(`assets/${gameName}/original.bmp`);
        fs.unlinkSync(`assets/${gameName}/modified.bmp`);
        fs.unlinkSync(`assets/${gameName}/differences.json`);
        fs.rmdirSync(`assets/${gameName}/`);
    }
    async deleteGameById(id) {
        try {
            this.gameIds = this.gameIds.filter((gameId) => gameId !== id);
            await this.gameModel.findByIdAndDelete(id).exec();
            const gameName = (await this.gameCardModel.findByIdAndDelete(id).exec()).name;
            this.deleteGameAssetsByName(gameName);
            await this.rebuildGameCarousel();
        }
        catch (error) {
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
        }
        catch (error) {
            return Promise.reject(`Failed to delete all games --> ${error}`);
        }
    }
    async updateTopTimesGameById(id, gameMode, topTimes) {
        try {
            const mode = gameMode === enums_1.GameModes.ClassicSolo ? 'soloTopTime' : 'oneVsOneTopTime';
            await this.gameCardModel.findByIdAndUpdate(id, { [mode]: topTimes }).exec();
            await this.rebuildGameCarousel();
        }
        catch (error) {
            return Promise.reject(`Failed to update top times game with id : ${id} --> ${error}`);
        }
    }
    async updateGameConstants(gameConstantsDto) {
        try {
            await this.gameConstantsModel.replaceOne({}, gameConstantsDto).exec();
        }
        catch (error) {
            return Promise.reject(`Failed to update game constants --> ${error}`);
        }
    }
    async resetTopTimesGameById(gameId) {
        try {
            await this.gameCardModel.findByIdAndUpdate(gameId, { soloTopTime: constants_1.DEFAULT_BEST_TIMES, oneVsOneTopTime: constants_1.DEFAULT_BEST_TIMES }).exec();
            await this.rebuildGameCarousel();
        }
        catch (error) {
            return Promise.reject(`Failed to reset top times game with id : ${gameId} --> ${error}`);
        }
    }
    async resetAllTopTimes() {
        try {
            await this.gameCardModel.updateMany({}, { soloTopTime: constants_1.DEFAULT_BEST_TIMES, oneVsOneTopTime: constants_1.DEFAULT_BEST_TIMES }).exec();
            await this.rebuildGameCarousel();
        }
        catch (error) {
            return Promise.reject(`Failed to reset all top times --> ${error}`);
        }
    }
    async getRandomGame(playedGameIds) {
        try {
            const gameIdsToPlay = this.gameIds.filter((id) => !playedGameIds.includes(id));
            const randomGameId = gameIdsToPlay[Math.floor(Math.random() * gameIdsToPlay.length)];
            return await this.getGameById(randomGameId);
        }
        catch (error) {
            return Promise.reject(`Failed to get random game --> ${error}`);
        }
    }
    async getGamesHistory() {
        try {
            return await this.gameHistoryModel.find().select('-__v -_id').exec();
        }
        catch (error) {
            return Promise.reject(`Failed to get games history --> ${error}`);
        }
    }
    async saveGameHistory(gameHistory) {
        try {
            await this.gameHistoryModel.create(gameHistory);
        }
        catch (error) {
            return Promise.reject(`Failed to add game history --> ${error}`);
        }
    }
    async deleteAllGamesHistory() {
        try {
            await this.gameHistoryModel.deleteMany({}).exec();
        }
        catch (error) {
            return Promise.reject(`Failed to delete all games history --> ${error}`);
        }
    }
    async populateDbWithGameConstants() {
        try {
            if (!(await this.gameConstantsModel.exists({}))) {
                await this.gameConstantsModel.create(this.defaultConstants);
            }
        }
        catch (error) {
            return Promise.reject(`Failed to populate game constants --> ${error}`);
        }
    }
    async getAllGameIds() {
        try {
            const gameCardsIds = await this.gameCardModel.find().select('_id').exec();
            this.gameIds = gameCardsIds.map((gameCard) => gameCard._id.toString());
        }
        catch (error) {
            return Promise.reject(`Failed to get all game ids --> ${error}`);
        }
    }
    async rebuildGameCarousel() {
        const gameCardsList = await this.gameCardModel.find().exec();
        this.gameListManager.buildGameCarousel(gameCardsList);
    }
};
DatabaseService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, mongoose_1.InjectModel)(game_1.Game.name)),
    __param(1, (0, mongoose_1.InjectModel)(game_card_1.GameCard.name)),
    __param(2, (0, mongoose_1.InjectModel)(game_config_constants_1.GameConstants.name)),
    __param(3, (0, mongoose_1.InjectModel)(game_history_1.GameHistory.name)),
    __metadata("design:paramtypes", [mongoose_2.Model,
        mongoose_2.Model,
        mongoose_2.Model,
        mongoose_2.Model,
        game_lists_manager_service_1.GameListsManagerService])
], DatabaseService);
exports.DatabaseService = DatabaseService;
//# sourceMappingURL=database.service.js.map