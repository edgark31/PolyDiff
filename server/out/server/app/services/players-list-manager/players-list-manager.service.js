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
exports.PlayersListManagerService = void 0;
const game_service_1 = require("../game/game.service");
const message_manager_service_1 = require("../message-manager/message-manager.service");
const constants_1 = require("../../../../common/constants");
const enums_1 = require("../../../../common/enums");
const common_1 = require("@nestjs/common");
let PlayersListManagerService = class PlayersListManagerService {
    constructor(gameService, messageManagerService) {
        this.gameService = gameService;
        this.messageManagerService = messageManagerService;
        this.joinedPlayersByGameId = new Map();
    }
    updateWaitingPlayerNameList(playerPayLoad, socket) {
        var _a;
        const playerNames = (_a = this.joinedPlayersByGameId.get(playerPayLoad.gameId)) !== null && _a !== void 0 ? _a : [];
        const differenceData = { currentDifference: [], differencesFound: 0 };
        const playerGuest = { name: playerPayLoad.playerName, differenceData, playerId: socket.id };
        playerNames.push(playerGuest);
        this.joinedPlayersByGameId.set(playerPayLoad.gameId, playerNames);
    }
    getWaitingPlayerNameList(hostId, gameId, server) {
        var _a;
        const playerNamesList = Array.from((_a = this.joinedPlayersByGameId.get(gameId)) !== null && _a !== void 0 ? _a : []).map((player) => player.name);
        server.to(hostId).emit(enums_1.PlayerEvents.WaitingPlayerNameListUpdated, playerNamesList);
    }
    refusePlayer(playerPayLoad, server) {
        this.cancelJoiningByPlayerName(playerPayLoad.playerName, playerPayLoad.gameId, server);
    }
    getAcceptPlayer(gameId, server) {
        var _a;
        const acceptedPlayer = (_a = this.joinedPlayersByGameId.get(gameId)) === null || _a === void 0 ? void 0 : _a[0];
        if (!acceptedPlayer)
            return;
        this.cancelAllJoining(gameId, server);
        return acceptedPlayer;
    }
    checkIfPlayerNameIsAvailable(playerPayLoad, server) {
        const joinedPlayerNames = this.joinedPlayersByGameId.get(playerPayLoad.gameId);
        const playerNameAvailability = { gameId: playerPayLoad.gameId, isNameAvailable: true };
        playerNameAvailability.isNameAvailable = !(joinedPlayerNames === null || joinedPlayerNames === void 0 ? void 0 : joinedPlayerNames.some((player) => player.name === playerPayLoad.playerName));
        server.emit(enums_1.PlayerEvents.PlayerNameTaken, playerNameAvailability);
    }
    cancelJoiningByPlayerId(playerId, gameId) {
        const playerNames = this.joinedPlayersByGameId.get(gameId);
        if (!playerNames)
            return;
        const index = playerNames.indexOf(playerNames.find((player) => player.playerId === playerId));
        if (index !== constants_1.NOT_FOUND)
            playerNames.splice(index, 1);
        this.joinedPlayersByGameId.set(gameId, playerNames);
    }
    cancelAllJoining(gameId, server) {
        var _a;
        (_a = structuredClone(this.joinedPlayersByGameId.get(gameId))) === null || _a === void 0 ? void 0 : _a.forEach((player) => {
            this.cancelJoiningByPlayerName(player.name, gameId, server);
        });
    }
    getGameIdByPlayerId(playerId) {
        return Array.from(this.joinedPlayersByGameId.keys()).find((gameId) => this.joinedPlayersByGameId.get(gameId).some((player) => player.playerId === playerId));
    }
    deleteJoinedPlayerByPlayerId(playerId, gameId) {
        const playerNames = this.joinedPlayersByGameId.get(gameId);
        if (!playerNames)
            return;
        const playerIndex = playerNames.findIndex((player) => player.playerId === playerId);
        if (playerIndex !== constants_1.NOT_FOUND)
            playerNames.splice(playerIndex, 1);
        this.joinedPlayersByGameId.set(gameId, playerNames);
    }
    async resetAllTopTime(server) {
        await this.gameService.resetAllTopTimes();
        server.emit(enums_1.GameCardEvents.RequestReload);
    }
    deleteJoinedPlayersByGameId(gameId) {
        this.joinedPlayersByGameId.delete(gameId);
    }
    async resetTopTime(gameId, server) {
        await this.gameService.resetTopTimesGameById(gameId);
        server.emit(enums_1.GameCardEvents.RequestReload);
    }
    async updateTopBestTime(room, playerName, server) {
        const { clientGame, timer } = room;
        if (!(await this.gameService.verifyIfGameExists(clientGame.name)))
            return;
        const topTimes = await this.gameService.getTopTimesGameById(clientGame.id, clientGame.mode);
        if (topTimes[constants_1.MAX_TIMES_INDEX].time > timer) {
            const topTimeIndex = this.insertNewTopTime(playerName, timer, topTimes);
            await this.gameService.updateTopTimesGameById(clientGame.id, clientGame.mode, topTimes);
            server.emit(enums_1.GameCardEvents.RequestReload);
            const newRecord = { playerName, rank: topTimeIndex, gameName: clientGame.name, gameMode: clientGame.mode };
            this.sendNewTopTimeMessage(newRecord, server);
            return topTimeIndex;
        }
    }
    cancelJoiningByPlayerName(playerName, gameId, server) {
        const playerId = this.getPlayerIdByPlayerName(gameId, playerName);
        if (!playerId)
            return;
        this.cancelJoiningByPlayerId(playerId, gameId);
        server.to(playerId).emit(enums_1.PlayerEvents.PlayerRefused, playerId);
        server.emit(enums_1.RoomEvents.UndoRoomCreation, gameId);
    }
    getPlayerIdByPlayerName(gameId, playerName) {
        var _a, _b;
        return (_b = (_a = this.joinedPlayersByGameId.get(gameId)) === null || _a === void 0 ? void 0 : _a.find((player) => player.name === playerName)) === null || _b === void 0 ? void 0 : _b.playerId;
    }
    insertNewTopTime(playerName, timer, topTimes) {
        const newTopTime = { name: playerName, time: timer };
        topTimes.splice(constants_1.MAX_TIMES_INDEX, 1, newTopTime);
        topTimes.sort((a, b) => a.time - b.time);
        return topTimes.findIndex((topTime) => topTime.name === playerName) + 1;
    }
    sendNewTopTimeMessage(newRecord, server) {
        const newRecordMessage = this.messageManagerService.getNewRecordMessage(newRecord);
        server.emit(enums_1.MessageEvents.LocalMessage, newRecordMessage);
    }
};
PlayersListManagerService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [game_service_1.GameService, message_manager_service_1.MessageManagerService])
], PlayersListManagerService);
exports.PlayersListManagerService = PlayersListManagerService;
//# sourceMappingURL=players-list-manager.service.js.map