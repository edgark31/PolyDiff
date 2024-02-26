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
exports.LimitedModeService = void 0;
const rooms_manager_service_1 = require("../rooms-manager/rooms-manager.service");
const enums_1 = require("../../../../common/enums");
const common_1 = require("@nestjs/common");
const history_service_1 = require("../history/history.service");
let LimitedModeService = class LimitedModeService {
    constructor(roomsManagerService, historyService) {
        this.roomsManagerService = roomsManagerService;
        this.historyService = historyService;
        this.availableGameByRoomId = new Map();
    }
    async createLimitedRoom(socket, playerPayLoad, server) {
        const limitedRoom = await this.roomsManagerService.createRoom(playerPayLoad);
        if (!limitedRoom) {
            socket.emit(enums_1.RoomEvents.NoGameAvailable);
            return;
        }
        this.availableGameByRoomId.set(limitedRoom.roomId, [limitedRoom.clientGame.id]);
        socket.join(limitedRoom.roomId);
        server.to(limitedRoom.roomId).emit(enums_1.RoomEvents.RoomLimitedCreated, limitedRoom.roomId);
        limitedRoom.clientGame.mode = playerPayLoad.gameMode;
        limitedRoom.player1.playerId = socket.id;
        limitedRoom.timer = limitedRoom.gameConstants.countdownTime;
        this.roomsManagerService.updateRoom(limitedRoom);
    }
    async startNextGame(socket, server) {
        const room = this.roomsManagerService.getRoomByPlayerId(socket.id);
        if (!room)
            return;
        const playedGameIds = this.getGameIds(room.roomId);
        const nextGameId = await this.roomsManagerService.loadNextGame(room, playedGameIds);
        this.equalizeDifferencesFound(room, server);
        if (!nextGameId) {
            await this.endGame(room, server);
            return;
        }
        if (playedGameIds)
            this.availableGameByRoomId.set(room.roomId, [...playedGameIds, nextGameId]);
        this.roomsManagerService.startGame(socket, server);
    }
    checkIfAnyCoopRoomExists(socket, playerPayLoad, server) {
        const room = this.roomsManagerService.getCreatedCoopRoom();
        if (room)
            this.joinLimitedCoopRoom(socket, playerPayLoad, server);
        else
            this.createLimitedRoom(socket, playerPayLoad, server);
    }
    deleteAvailableGame(roomId) {
        this.availableGameByRoomId.delete(roomId);
    }
    handleDeleteGame(gameId) {
        for (const gameIds of this.availableGameByRoomId.values())
            gameIds.push(gameId);
    }
    handleDeleteAllGames() {
        this.availableGameByRoomId.clear();
    }
    joinLimitedCoopRoom(socket, playerPayLoad, server) {
        const room = this.roomsManagerService.getCreatedCoopRoom();
        if (!room)
            return;
        socket.join(room.roomId);
        room.player2 = { name: playerPayLoad.playerName, playerId: socket.id, differenceData: room.player1.differenceData };
        this.roomsManagerService.updateRoom(room);
        server.to(room.roomId).emit(enums_1.RoomEvents.LimitedCoopRoomJoined);
    }
    getGameIds(roomId) {
        return this.availableGameByRoomId.get(roomId);
    }
    async endGame(room, server) {
        await this.historyService.closeEntry(room.roomId, server);
        this.sendEndMessage(room, server);
        this.roomsManagerService.leaveRoom(room, server);
        this.roomsManagerService.deleteRoom(room.roomId);
        this.deleteAvailableGame(room.roomId);
    }
    equalizeDifferencesFound(room, server) {
        if (room.clientGame.mode === enums_1.GameModes.LimitedCoop) {
            server.to(room.roomId).emit(enums_1.GameEvents.UpdateDifferencesFound, room.player1.differenceData.differencesFound);
        }
    }
    sendEndMessage(room, server) {
        room.endMessage = `Vous avez trouvé les ${room.player1.differenceData.differencesFound} différences! Bravo!`;
        server.to(room.roomId).emit(enums_1.GameEvents.EndGame, room.endMessage);
    }
};
LimitedModeService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [rooms_manager_service_1.RoomsManagerService, history_service_1.HistoryService])
], LimitedModeService);
exports.LimitedModeService = LimitedModeService;
//# sourceMappingURL=limited-mode.service.js.map