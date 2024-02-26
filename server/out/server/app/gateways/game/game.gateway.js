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
exports.GameGateway = void 0;
const classic_mode_service_1 = require("../../services/classic-mode/classic-mode.service");
const limited_mode_service_1 = require("../../services/limited-mode/limited-mode.service");
const players_list_manager_service_1 = require("../../services/players-list-manager/players-list-manager.service");
const rooms_manager_service_1 = require("../../services/rooms-manager/rooms-manager.service");
const enums_1 = require("../../../../common/enums");
const common_1 = require("@nestjs/common");
const websockets_1 = require("@nestjs/websockets");
const socket_io_1 = require("socket.io");
const game_gateway_constants_1 = require("./game.gateway.constants");
let GameGateway = class GameGateway {
    constructor(logger, classicModeService, playersListManagerService, roomsManagerService, limitedModeService) {
        this.logger = logger;
        this.classicModeService = classicModeService;
        this.playersListManagerService = playersListManagerService;
        this.roomsManagerService = roomsManagerService;
        this.limitedModeService = limitedModeService;
        this.mapSocketWithName = new Map();
    }
    startGame(socket) {
        this.roomsManagerService.startGame(socket, this.server);
    }
    async createSoloRoom(socket, playerPayLoad) {
        await this.classicModeService.createSoloRoom(socket, playerPayLoad, this.server);
    }
    async createOneVsOneRoom(socket, playerPayLoad) {
        await this.classicModeService.createOneVsOneRoom(socket, playerPayLoad, this.server);
    }
    async createLimitedRoom(socket, playerPayLoad) {
        await this.limitedModeService.createLimitedRoom(socket, playerPayLoad, this.server);
    }
    async startNextGame(socket) {
        await this.limitedModeService.startNextGame(socket, this.server);
    }
    validateCoords(socket, coords) {
        this.roomsManagerService.validateCoords(socket, coords, this.server);
    }
    async checkStatus(socket) {
        await this.classicModeService.checkStatus(socket, this.server);
    }
    updateRoomOneVsOneAvailability(socket, gameId) {
        this.classicModeService.updateRoomOneVsOneAvailability(socket.id, gameId, this.server);
    }
    checkRoomOneVsOneAvailability(socket, gameId) {
        this.classicModeService.checkRoomOneVsOneAvailability(socket.id, gameId, this.server);
    }
    deleteCreatedOneVsOneRoom(socket, roomId) {
        const room = this.roomsManagerService.getRoomById(roomId);
        if (!room)
            return;
        this.playersListManagerService.cancelAllJoining(room.clientGame.id, this.server);
        this.classicModeService.deleteCreatedRoom(socket.id, roomId, this.server);
    }
    deleteCreatedCoopRoom(socket, roomId) {
        this.roomsManagerService.deleteRoom(roomId);
        this.limitedModeService.deleteAvailableGame(roomId);
        socket.leave(roomId);
    }
    getJoinedPlayerNames(socket, gameId) {
        this.playersListManagerService.getWaitingPlayerNameList(socket.id, gameId, this.server);
    }
    updateWaitingPlayerNameList(socket, playerPayLoad) {
        this.playersListManagerService.updateWaitingPlayerNameList(playerPayLoad, socket);
        const hostId = this.roomsManagerService.getHostIdByGameId(playerPayLoad.gameId);
        this.playersListManagerService.getWaitingPlayerNameList(hostId, playerPayLoad.gameId, this.server);
    }
    refusePlayer(socket, playerPayLoad) {
        this.playersListManagerService.refusePlayer(playerPayLoad, this.server);
        this.playersListManagerService.getWaitingPlayerNameList(socket.id, playerPayLoad.gameId, this.server);
    }
    acceptPlayer(socket, data) {
        const acceptedPlayer = this.playersListManagerService.getAcceptPlayer(data.gameId, this.server);
        this.classicModeService.acceptPlayer(acceptedPlayer, data.roomId, this.server);
        this.classicModeService.updateRoomOneVsOneAvailability(socket.id, data.gameId, this.server);
        this.playersListManagerService.deleteJoinedPlayersByGameId(data.gameId);
    }
    checkIfPlayerNameIsAvailable(playerPayLoad) {
        this.playersListManagerService.checkIfPlayerNameIsAvailable(playerPayLoad, this.server);
    }
    cancelJoining(socket, gameId) {
        this.playersListManagerService.cancelJoiningByPlayerId(socket.id, gameId);
        const hostId = this.roomsManagerService.getHostIdByGameId(gameId);
        this.playersListManagerService.getWaitingPlayerNameList(hostId, gameId, this.server);
    }
    async abandonGame(socket) {
        await this.roomsManagerService.abandonGame(socket, this.server);
    }
    checkIfAnyCoopRoomExists(socket, playerPayLoad) {
        this.limitedModeService.checkIfAnyCoopRoomExists(socket, playerPayLoad, this.server);
    }
    sendMessage(socket, data) {
        const roomId = this.roomsManagerService.getRoomIdFromSocket(socket);
        socket.broadcast.to(roomId).emit(enums_1.MessageEvents.LocalMessage, data);
    }
    gameCardDeleted(gameId) {
        this.server.emit(enums_1.GameCardEvents.RequestReload);
        this.server.emit(enums_1.GameCardEvents.GameDeleted, gameId);
        this.limitedModeService.handleDeleteGame(gameId);
    }
    gameCardCreated() {
        this.server.emit(enums_1.GameCardEvents.RequestReload);
    }
    resetTopTime(gameId) {
        this.playersListManagerService.resetTopTime(gameId, this.server);
    }
    allGamesDeleted() {
        this.server.emit(enums_1.GameCardEvents.RequestReload);
        this.limitedModeService.handleDeleteAllGames();
    }
    resetAllTopTime() {
        this.playersListManagerService.resetAllTopTime(this.server);
    }
    async gameConstantsUpdated() {
        this.server.emit(enums_1.GameCardEvents.RequestReload);
        await this.roomsManagerService.getGameConstants();
    }
    gamesHistoryDeleted() {
        this.server.emit(enums_1.GameCardEvents.RequestReload);
    }
    async requestHint(socket) {
        await this.roomsManagerService.addHintPenalty(socket, this.server);
    }
    processConnection(socket, name) {
        const canConnect = !Array.from(this.mapSocketWithName.values()).some((value) => value === name);
        socket.emit(enums_1.ConnectionEvents.UserConnectionRequest, canConnect);
        if (canConnect) {
            this.logger.log(`Connexion au chat acceptée pour ${name} avec id : ${socket.id}`);
            this.mapSocketWithName.set(socket.id, name);
        }
        else {
            this.logger.log(`Connexion au chat refusée pour ${name} avec id : ${socket.id}`);
        }
    }
    processMessage(dataMessage) {
        this.logger.log(`Message reçu : ${dataMessage.message} de la part de ${dataMessage.userName}`);
        dataMessage.timestamp = new Date().toLocaleTimeString();
        this.server.emit(enums_1.MessageEvents.GlobalMessage, dataMessage);
    }
    afterInit() {
        setInterval(() => {
            this.roomsManagerService.updateTimers(this.server);
        }, game_gateway_constants_1.DELAY_BEFORE_EMITTING_TIME);
    }
    handleConnection(socket) {
        this.logger.log(`Connexion par l'utilisateur avec id : ${socket.id}`);
    }
    async handleDisconnect(socket) {
        this.logger.log(`Déconnexion par l'utilisateur avec id : ${socket.id}`);
        this.mapSocketWithName.delete(socket.id);
    }
};
__decorate([
    (0, websockets_1.WebSocketServer)(),
    __metadata("design:type", socket_io_1.Server)
], GameGateway.prototype, "server", void 0);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.GameEvents.StartGameByRoomId),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket]),
    __metadata("design:returntype", void 0)
], GameGateway.prototype, "startGame", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.RoomEvents.CreateClassicSoloRoom),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, Object]),
    __metadata("design:returntype", Promise)
], GameGateway.prototype, "createSoloRoom", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.RoomEvents.CreateOneVsOneRoom),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, Object]),
    __metadata("design:returntype", Promise)
], GameGateway.prototype, "createOneVsOneRoom", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.RoomEvents.CreateLimitedRoom),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, Object]),
    __metadata("design:returntype", Promise)
], GameGateway.prototype, "createLimitedRoom", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.GameEvents.StartNextGame),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket]),
    __metadata("design:returntype", Promise)
], GameGateway.prototype, "startNextGame", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.GameEvents.RemoveDifference),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, Object]),
    __metadata("design:returntype", void 0)
], GameGateway.prototype, "validateCoords", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.GameEvents.CheckStatus),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket]),
    __metadata("design:returntype", Promise)
], GameGateway.prototype, "checkStatus", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.RoomEvents.UpdateRoomOneVsOneAvailability),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, String]),
    __metadata("design:returntype", void 0)
], GameGateway.prototype, "updateRoomOneVsOneAvailability", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.RoomEvents.CheckRoomOneVsOneAvailability),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, String]),
    __metadata("design:returntype", void 0)
], GameGateway.prototype, "checkRoomOneVsOneAvailability", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.RoomEvents.DeleteCreatedOneVsOneRoom),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, String]),
    __metadata("design:returntype", void 0)
], GameGateway.prototype, "deleteCreatedOneVsOneRoom", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.RoomEvents.DeleteCreatedCoopRoom),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, String]),
    __metadata("design:returntype", void 0)
], GameGateway.prototype, "deleteCreatedCoopRoom", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.PlayerEvents.GetJoinedPlayerNames),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, String]),
    __metadata("design:returntype", void 0)
], GameGateway.prototype, "getJoinedPlayerNames", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.PlayerEvents.UpdateWaitingPlayerNameList),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, Object]),
    __metadata("design:returntype", void 0)
], GameGateway.prototype, "updateWaitingPlayerNameList", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.PlayerEvents.RefusePlayer),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, Object]),
    __metadata("design:returntype", void 0)
], GameGateway.prototype, "refusePlayer", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.PlayerEvents.AcceptPlayer),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, Object]),
    __metadata("design:returntype", void 0)
], GameGateway.prototype, "acceptPlayer", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.PlayerEvents.CheckIfPlayerNameIsAvailable),
    __param(0, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], GameGateway.prototype, "checkIfPlayerNameIsAvailable", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.PlayerEvents.CancelJoining),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, String]),
    __metadata("design:returntype", void 0)
], GameGateway.prototype, "cancelJoining", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.GameEvents.AbandonGame),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket]),
    __metadata("design:returntype", Promise)
], GameGateway.prototype, "abandonGame", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.RoomEvents.CheckIfAnyCoopRoomExists),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, Object]),
    __metadata("design:returntype", void 0)
], GameGateway.prototype, "checkIfAnyCoopRoomExists", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.MessageEvents.LocalMessage),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, Object]),
    __metadata("design:returntype", void 0)
], GameGateway.prototype, "sendMessage", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.GameCardEvents.GameCardDeleted),
    __param(0, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], GameGateway.prototype, "gameCardDeleted", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.GameCardEvents.GameCardCreated),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], GameGateway.prototype, "gameCardCreated", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.GameCardEvents.ResetTopTime),
    __param(0, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], GameGateway.prototype, "resetTopTime", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.GameCardEvents.AllGamesDeleted),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], GameGateway.prototype, "allGamesDeleted", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.GameCardEvents.ResetAllTopTimes),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], GameGateway.prototype, "resetAllTopTime", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.GameCardEvents.GameConstantsUpdated),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], GameGateway.prototype, "gameConstantsUpdated", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.GameCardEvents.GamesHistoryDeleted),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], GameGateway.prototype, "gamesHistoryDeleted", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.GameEvents.RequestHint),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket]),
    __metadata("design:returntype", Promise)
], GameGateway.prototype, "requestHint", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.ConnectionEvents.UserConnectionRequest),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)('name')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, String]),
    __metadata("design:returntype", void 0)
], GameGateway.prototype, "processConnection", null);
__decorate([
    (0, websockets_1.SubscribeMessage)(enums_1.MessageEvents.GlobalMessage),
    __param(0, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], GameGateway.prototype, "processMessage", null);
__decorate([
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket]),
    __metadata("design:returntype", void 0)
], GameGateway.prototype, "handleConnection", null);
__decorate([
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket]),
    __metadata("design:returntype", Promise)
], GameGateway.prototype, "handleDisconnect", null);
GameGateway = __decorate([
    (0, websockets_1.WebSocketGateway)((0, websockets_1.WebSocketGateway)({
        cors: {
            origin: '*',
        },
    })),
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [common_1.Logger,
        classic_mode_service_1.ClassicModeService,
        players_list_manager_service_1.PlayersListManagerService,
        rooms_manager_service_1.RoomsManagerService,
        limited_mode_service_1.LimitedModeService])
], GameGateway);
exports.GameGateway = GameGateway;
//# sourceMappingURL=game.gateway.js.map