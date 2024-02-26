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
exports.GameListsManagerService = void 0;
const constants_1 = require("../../../../common/constants");
const common_1 = require("@nestjs/common");
const fs = require("fs");
let GameListsManagerService = class GameListsManagerService {
    constructor() {
        this.carouselGames = [];
    }
    buildGameCardFromGame(game) {
        const gameCard = {
            _id: game._id,
            name: game.name,
            difficultyLevel: game.isHard,
            soloTopTime: constants_1.DEFAULT_BEST_TIMES,
            oneVsOneTopTime: constants_1.DEFAULT_BEST_TIMES,
            thumbnail: `assets/${game.name}/original.bmp`,
        };
        return gameCard;
    }
    addGameCarousel(gameCard) {
        let lastIndex = this.carouselGames.length - 1;
        gameCard.thumbnail = fs.readFileSync(gameCard.thumbnail, 'base64');
        if (this.carouselGames[lastIndex].gameCards.length < constants_1.GAME_CARROUSEL_SIZE) {
            this.carouselGames[lastIndex].gameCards.push(gameCard);
        }
        else {
            this.carouselGames.push({
                hasNext: false,
                hasPrevious: true,
                gameCards: [],
            });
            this.carouselGames[lastIndex].hasNext = true;
            this.carouselGames[++lastIndex].gameCards.push(gameCard);
        }
    }
    buildGameCarousel(gameCards) {
        this.carouselGames = [];
        this.carouselGames.push({
            hasNext: false,
            hasPrevious: false,
            gameCards: [],
        });
        for (const gameCard of gameCards) {
            this.addGameCarousel(gameCard);
        }
    }
    getCarouselGames() {
        return this.carouselGames;
    }
};
GameListsManagerService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [])
], GameListsManagerService);
exports.GameListsManagerService = GameListsManagerService;
//# sourceMappingURL=game-lists-manager.service.js.map