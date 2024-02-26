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
exports.ClassicModeService = void 0;
const history_service_1 = require("../history/history.service");
const players_list_manager_service_1 = require("../players-list-manager/players-list-manager.service");
const rooms_manager_service_1 = require("../rooms-manager/rooms-manager.service");
const constants_1 = require("../../../../common/constants");
const enums_1 = require("../../../../common/enums");
const common_1 = require("@nestjs/common");
let ClassicModeService = class ClassicModeService {
    constructor(roomsManagerService, historyService, playersListManagerService) {
        this.roomsManagerService = roomsManagerService;
        this.historyService = historyService;
        this.playersListManagerService = playersListManagerService;
        this.roomAvailability = new Map();
    }
    async createSoloRoom(socket, playerPayLoad, server) {
        const soloRoomId = await this.createClassicRoom(socket, playerPayLoad);
        if (!soloRoomId)
            return;
        server.to(socket.id).emit(enums_1.RoomEvents.RoomSoloCreated, soloRoomId);
    }
    async createOneVsOneRoom(socket, playerPayLoad, server) {
        const oneVsOneRoomId = await this.createClassicRoom(socket, playerPayLoad);
        if (!oneVsOneRoomId)
            return;
        server.to(socket.id).emit(enums_1.RoomEvents.RoomOneVsOneCreated, oneVsOneRoomId);
    }
    deleteCreatedRoom(hostId, roomId, server) {
        const room = this.roomsManagerService.getRoomById(roomId);
        if (!room)
            return;
        this.updateRoomOneVsOneAvailability(hostId, room.clientGame.id, server);
        this.roomsManagerService.deleteRoom(roomId);
    }
    deleteOneVsOneAvailability(socket, server) {
        const gameId = this.getGameIdByHostId(socket.id);
        if (!gameId)
            return;
        const roomAvailability = { gameId, isAvailableToJoin: false, hostId: socket.id };
        server.emit(enums_1.RoomEvents.RoomOneVsOneAvailable, roomAvailability);
        this.roomAvailability.delete(gameId);
    }
    async checkStatus(socket, server) {
        const roomId = this.roomsManagerService.getRoomIdFromSocket(socket);
        const room = this.roomsManagerService.getRoomById(roomId);
        if (!room)
            return;
        const halfDifferences = Math.ceil(room.clientGame.differencesCount / 2);
        const player = room.player1.playerId === socket.id ? room.player1 : room.player2;
        if (!player)
            return;
        if (room.clientGame.differencesCount === player.differenceData.differencesFound && room.clientGame.mode === enums_1.GameModes.ClassicSolo) {
            await this.endGame(room, player, server);
        }
        else if (halfDifferences === player.differenceData.differencesFound && room.clientGame.mode === enums_1.GameModes.ClassicOneVsOne) {
            this.historyService.markPlayer(room.roomId, player.name, enums_1.PlayerStatus.Winner);
            await this.endGame(room, player, server);
        }
    }
    async endGame(room, player, server) {
        const playerRank = await this.playersListManagerService.updateTopBestTime(room, player.name, server);
        const playerRankMessage = playerRank ? `${player.name} est maintenant classé ${constants_1.SCORE_POSITION[playerRank]}!` : '';
        room.endMessage =
            room.clientGame.mode === enums_1.GameModes.ClassicOneVsOne
                ? `${player.name} remporte la partie avec ${player.differenceData.differencesFound} différences trouvées! ${playerRankMessage}`
                : `Vous avez trouvé les ${room.clientGame.differencesCount} différences! Bravo ${playerRankMessage}!`;
        server.to(room.roomId).emit(enums_1.GameEvents.EndGame, room.endMessage);
        await this.historyService.closeEntry(room.roomId, server);
        this.playersListManagerService.deleteJoinedPlayersByGameId(room.clientGame.id);
        this.roomsManagerService.leaveRoom(room, server);
        this.roomsManagerService.deleteRoom(room.roomId);
    }
    updateRoomOneVsOneAvailability(hostId, gameId, server) {
        const roomAvailability = this.roomAvailability.get(gameId) || { gameId, isAvailableToJoin: false, hostId };
        roomAvailability.isAvailableToJoin = !roomAvailability.isAvailableToJoin;
        this.roomAvailability.set(gameId, roomAvailability);
        server.emit(enums_1.RoomEvents.RoomOneVsOneAvailable, roomAvailability);
    }
    checkRoomOneVsOneAvailability(hostId, gameId, server) {
        const availabilityData = this.roomAvailability.has(gameId)
            ? { gameId, isAvailableToJoin: this.roomAvailability.get(gameId).isAvailableToJoin, hostId }
            : { gameId, isAvailableToJoin: false, hostId };
        server.emit(enums_1.RoomEvents.RoomOneVsOneAvailable, availabilityData);
    }
    acceptPlayer(acceptedPlayer, roomId, server) {
        const room = this.roomsManagerService.getRoomById(roomId);
        if (!room)
            return;
        this.roomsManagerService.addAcceptedPlayer(room, acceptedPlayer);
        server.to(acceptedPlayer.playerId).emit(enums_1.PlayerEvents.PlayerAccepted, true);
    }
    async handleSocketDisconnect(socket, server) {
        var _a;
        const room = this.roomsManagerService.getRoomByPlayerId(socket.id);
        const createdGameId = this.playersListManagerService.getGameIdByPlayerId(socket.id);
        await this.roomsManagerService.handleSoloModesDisconnect(room, server);
        const joinable = (_a = this.roomAvailability.get(room === null || room === void 0 ? void 0 : room.clientGame.id)) === null || _a === void 0 ? void 0 : _a.isAvailableToJoin;
        if (room && !room.player2 && joinable && room.clientGame.mode === enums_1.GameModes.ClassicOneVsOne) {
            this.handleDisconnectBeforeStarted(room, socket, server);
        }
        else if (room && room.timer !== 0 && !joinable) {
            await this.roomsManagerService.abandonGame(socket, server);
        }
        else if (!createdGameId) {
            this.handleDisconnectBeforeCreated(socket, server);
        }
        else {
            this.handleGuestDisconnect(createdGameId, socket, server);
        }
    }
    handleDisconnectBeforeCreated(socket, server) {
        const gameId = this.getGameIdByHostId(socket.id);
        this.deleteOneVsOneAvailability(socket, server);
        this.playersListManagerService.deleteJoinedPlayersByGameId(gameId);
    }
    handleDisconnectBeforeStarted(room, socket, server) {
        this.updateRoomOneVsOneAvailability(socket.id, room.clientGame.id, server);
        this.playersListManagerService.cancelAllJoining(room.clientGame.id, server);
        this.roomsManagerService.deleteRoom(room.roomId);
    }
    handleGuestDisconnect(createdGameId, socket, server) {
        const hostId = this.roomsManagerService.getHostIdByGameId(createdGameId);
        this.playersListManagerService.deleteJoinedPlayerByPlayerId(socket.id, createdGameId);
        this.playersListManagerService.getWaitingPlayerNameList(hostId, createdGameId, server);
    }
    async createClassicRoom(socket, playerPayLoad) {
        const classicRoom = await this.roomsManagerService.createRoom(playerPayLoad);
        if (!classicRoom)
            return;
        classicRoom.player1.playerId = socket.id;
        this.roomsManagerService.updateRoom(classicRoom);
        return classicRoom.roomId;
    }
    getGameIdByHostId(playerId) {
        return Array.from(this.roomAvailability.keys()).find((gameId) => {
            const roomAvailability = this.roomAvailability.get(gameId);
            return roomAvailability.hostId === playerId;
        });
    }
};
ClassicModeService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [rooms_manager_service_1.RoomsManagerService,
        history_service_1.HistoryService,
        players_list_manager_service_1.PlayersListManagerService])
], ClassicModeService);
exports.ClassicModeService = ClassicModeService;
//# sourceMappingURL=classic-mode.service.js.map