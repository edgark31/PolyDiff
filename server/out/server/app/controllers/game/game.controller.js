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
exports.GameController = void 0;
const create_game_dto_1 = require("../../model/dto/game/create-game.dto");
const game_constants_dto_1 = require("../../model/dto/game/game-constants.dto");
const game_service_1 = require("../../services/game/game.service");
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
let GameController = class GameController {
    constructor(gameService) {
        this.gameService = gameService;
    }
    async getGameConstants(response) {
        try {
            const gameConfigConstants = await this.gameService.getGameConstants();
            response.status(common_1.HttpStatus.OK).json(gameConfigConstants);
        }
        catch (error) {
            response.status(common_1.HttpStatus.NOT_FOUND).send(error.message);
        }
    }
    async getGamesHistory(response) {
        try {
            const gameHistory = await this.gameService.getGamesHistory();
            response.status(common_1.HttpStatus.OK).json(gameHistory);
        }
        catch (error) {
            response.status(common_1.HttpStatus.NOT_FOUND).send(error.message);
        }
    }
    async getGameCarrousel(index, response) {
        try {
            const gameCarrousel = await this.gameService.getGameCarousel();
            response.status(common_1.HttpStatus.OK).json(gameCarrousel[+index]);
        }
        catch (error) {
            response.status(common_1.HttpStatus.NOT_FOUND).send(error.message);
        }
    }
    async gameById(id, response) {
        try {
            const game = await this.gameService.getGameById(id);
            response.status(common_1.HttpStatus.OK).json(game);
        }
        catch (error) {
            response.status(common_1.HttpStatus.NOT_FOUND).send(error.message);
        }
    }
    async verifyIfGameExists(name, response) {
        const gameExists = await this.gameService.verifyIfGameExists(name);
        response.status(common_1.HttpStatus.OK).json(gameExists);
    }
    async addGame(gameDto, response) {
        try {
            await this.gameService.addGame(gameDto);
            response.status(common_1.HttpStatus.CREATED).send();
        }
        catch (error) {
            response.status(common_1.HttpStatus.BAD_REQUEST).send(error.message);
        }
    }
    async deleteAllGamesHistory(response) {
        try {
            await this.gameService.deleteAllGamesHistory();
            response.status(common_1.HttpStatus.OK).send();
        }
        catch (error) {
            response.status(common_1.HttpStatus.NO_CONTENT).send(error.message);
        }
    }
    async deleteGameById(id, response) {
        try {
            await this.gameService.deleteGameById(id);
            response.status(common_1.HttpStatus.OK).send();
        }
        catch (error) {
            response.status(common_1.HttpStatus.NO_CONTENT).send(error.message);
        }
    }
    async deleteAllGames(response) {
        try {
            await this.gameService.deleteAllGames();
            response.status(common_1.HttpStatus.OK).send();
        }
        catch (error) {
            response.status(common_1.HttpStatus.NO_CONTENT).send(error.message);
        }
    }
    async updateGameConstants(gameConstantsDto, response) {
        try {
            await this.gameService.updateGameConstants(gameConstantsDto);
            response.status(common_1.HttpStatus.OK).send();
        }
        catch (error) {
            response.status(common_1.HttpStatus.NO_CONTENT).send(error.message);
        }
    }
};
__decorate([
    (0, common_1.Get)('/constants'),
    __param(0, (0, common_1.Res)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], GameController.prototype, "getGameConstants", null);
__decorate([
    (0, common_1.Get)('/history'),
    __param(0, (0, common_1.Res)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], GameController.prototype, "getGamesHistory", null);
__decorate([
    (0, common_1.Get)('carousel/:index'),
    __param(0, (0, common_1.Param)('index')),
    __param(1, (0, common_1.Res)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Object]),
    __metadata("design:returntype", Promise)
], GameController.prototype, "getGameCarrousel", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Res)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], GameController.prototype, "gameById", null);
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, common_1.Query)('name')),
    __param(1, (0, common_1.Res)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], GameController.prototype, "verifyIfGameExists", null);
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Res)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_game_dto_1.CreateGameDto, Object]),
    __metadata("design:returntype", Promise)
], GameController.prototype, "addGame", null);
__decorate([
    (0, common_1.Delete)('/history'),
    __param(0, (0, common_1.Res)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], GameController.prototype, "deleteAllGamesHistory", null);
__decorate([
    (0, common_1.Delete)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Res)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], GameController.prototype, "deleteGameById", null);
__decorate([
    (0, common_1.Delete)(),
    __param(0, (0, common_1.Res)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], GameController.prototype, "deleteAllGames", null);
__decorate([
    (0, common_1.Put)('/constants'),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Res)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [game_constants_dto_1.GameConstantsDto, Object]),
    __metadata("design:returntype", Promise)
], GameController.prototype, "updateGameConstants", null);
GameController = __decorate([
    (0, swagger_1.ApiTags)('Games'),
    (0, common_1.Controller)('games'),
    __metadata("design:paramtypes", [game_service_1.GameService])
], GameController);
exports.GameController = GameController;
//# sourceMappingURL=game.controller.js.map