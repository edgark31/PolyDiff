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
exports.HistoryService = void 0;
const game_service_1 = require("../game/game.service");
const constants_1 = require("../../../../common/constants");
const enums_1 = require("../../../../common/enums");
const common_1 = require("@nestjs/common");
let HistoryService = class HistoryService {
    constructor(gameService) {
        this.gameService = gameService;
        this.pendingGames = new Map();
    }
    createEntry(room) {
        if (this.pendingGames.has(room.roomId))
            return;
        const date = new Date();
        const gameHistory = {
            date: this.getFormattedDate(date),
            startingHour: this.getFormattedTime(date),
            duration: date.getTime(),
            gameMode: room.clientGame.mode,
            player1: {
                name: room.player1.name,
                isWinner: false,
                isQuitter: false,
            },
        };
        if (room.player2) {
            gameHistory.player2 = {
                name: room.player2.name,
                isWinner: false,
                isQuitter: false,
            };
        }
        this.pendingGames.set(room.roomId, gameHistory);
    }
    async closeEntry(roomId, server) {
        const gameHistory = this.pendingGames.get(roomId);
        if (!gameHistory)
            return;
        gameHistory.duration = new Date().getTime() - gameHistory.duration;
        this.pendingGames.delete(roomId);
        await this.gameService.saveGameHistory(gameHistory);
        server.emit(enums_1.HistoryEvents.RequestReload);
    }
    markPlayer(roomId, playerName, status) {
        const gameHistory = this.pendingGames.get(roomId);
        if (!gameHistory)
            return;
        const playerInfoToChange = gameHistory.player2 && gameHistory.player2.name === playerName ? gameHistory.player2 : gameHistory.player1;
        switch (status) {
            case enums_1.PlayerStatus.Winner:
                playerInfoToChange.isWinner = true;
                break;
            case enums_1.PlayerStatus.Quitter:
                playerInfoToChange.isQuitter = true;
                break;
        }
        this.pendingGames.set(roomId, gameHistory);
    }
    getFormattedDate(date) {
        const month = this.padValue(date.getMonth() + 1);
        const day = this.padValue(date.getDate());
        const year = date.getFullYear();
        return `${year}-${month}-${day}`;
    }
    getFormattedTime(date) {
        const hours = this.padValue(date.getHours());
        const minutes = this.padValue(date.getMinutes());
        const seconds = this.padValue(date.getSeconds());
        return `${hours}:${minutes}:${seconds}`;
    }
    padValue(value) {
        return value.toString().padStart(constants_1.PADDING_N_DIGITS, '0');
    }
};
HistoryService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [game_service_1.GameService])
], HistoryService);
exports.HistoryService = HistoryService;
//# sourceMappingURL=history.service.js.map