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
Object.defineProperty(exports, "__esModule", { value: true });
exports.GameService = void 0;
const database_service_1 = require("../database/database.service");
const common_1 = require("@nestjs/common");
let GameService = class GameService {
    constructor(databaseService) {
        this.databaseService = databaseService;
    }
    async getGameConstants() {
        const configConstants = await this.databaseService.getGameConstants();
        if (configConstants) {
            return configConstants;
        }
        throw new common_1.NotFoundException('No game config constants found');
    }
    async getGameCarousel() {
        const gamesCarrousels = await this.databaseService.getGamesCarrousel();
        if (gamesCarrousels) {
            return gamesCarrousels;
        }
        throw new common_1.NotFoundException('No gamesCarrousels found');
    }
    async verifyIfGameExists(gameName) {
        return await this.databaseService.verifyIfGameExists(gameName);
    }
    async getGameById(gameId) {
        const game = this.databaseService.getGameById(gameId);
        if (game) {
            return game;
        }
        throw new common_1.NotFoundException('No games found');
    }
    async deleteGameById(gameId) {
        await this.databaseService.deleteGameById(gameId);
    }
    async deleteAllGames() {
        await this.databaseService.deleteAllGames();
    }
    async addGame(newGame) {
        await this.databaseService.addGameInDb(newGame);
    }
    async getTopTimesGameById(gameId, gameMode) {
        const game = await this.databaseService.getTopTimesGameById(gameId, gameMode);
        if (game) {
            return game;
        }
        throw new common_1.NotFoundException('No games found');
    }
    async updateTopTimesGameById(gameId, gameMode, topTimes) {
        await this.databaseService.updateTopTimesGameById(gameId, gameMode, topTimes);
    }
    async updateGameConstants(gameConstantsDto) {
        await this.databaseService.updateGameConstants(gameConstantsDto);
    }
    async resetTopTimesGameById(gameId) {
        await this.databaseService.resetTopTimesGameById(gameId);
    }
    async resetAllTopTimes() {
        await this.databaseService.resetAllTopTimes();
    }
    async getRandomGame(selectedId) {
        const game = await this.databaseService.getRandomGame(selectedId);
        if (game) {
            return game;
        }
        return null;
    }
    async getGamesHistory() {
        const gamesHistory = await this.databaseService.getGamesHistory();
        if (gamesHistory) {
            return gamesHistory;
        }
        throw new common_1.NotFoundException('No games history found');
    }
    async saveGameHistory(gameHistory) {
        await this.databaseService.saveGameHistory(gameHistory);
    }
    async deleteAllGamesHistory() {
        await this.databaseService.deleteAllGamesHistory();
    }
};
GameService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], GameService);
exports.GameService = GameService;
//# sourceMappingURL=game.service.js.map