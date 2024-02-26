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
exports.RoomsManagerService = void 0;
const game_service_1 = require("../game/game.service");
const history_service_1 = require("../history/history.service");
const message_manager_service_1 = require("../message-manager/message-manager.service");
const constants_1 = require("../../../../common/constants");
const enums_1 = require("../../../../common/enums");
const common_1 = require("@nestjs/common");
const fs = require("fs");
let RoomsManagerService = class RoomsManagerService {
    constructor(gameService, messageManager, historyService) {
        this.gameService = gameService;
        this.messageManager = messageManager;
        this.historyService = historyService;
        this.rooms = new Map();
        this.modeTimerMap = constants_1.DEFAULT_GAME_MODES;
    }
    async onModuleInit() {
        await this.getGameConstants();
    }
    async createRoom(playerPayLoad) {
        const game = !playerPayLoad.gameId ? await this.gameService.getRandomGame([]) : await this.gameService.getGameById(playerPayLoad.gameId);
        if (!game)
            return;
        return this.buildGameRoom(game, playerPayLoad);
    }
    async getGameConstants() {
        this.gameConstants = await this.gameService.getGameConstants();
    }
    getRoomById(roomId) {
        if (this.rooms.has(roomId))
            return this.rooms.get(roomId);
    }
    getRoomIdFromSocket(socket) {
        return Array.from(socket.rooms.values())[1];
    }
    getRoomByPlayerId(playerId) {
        return Array.from(this.rooms.values()).find((room) => { var _a; return room.player1.playerId === playerId || ((_a = room.player2) === null || _a === void 0 ? void 0 : _a.playerId) === playerId; });
    }
    getHostIdByGameId(gameId) {
        const roomTarget = Array.from(this.rooms.values()).find((room) => room.clientGame.id === gameId && room.clientGame.mode === enums_1.GameModes.ClassicOneVsOne && !room.player2);
        return roomTarget === null || roomTarget === void 0 ? void 0 : roomTarget.player1.playerId;
    }
    getCreatedCoopRoom() {
        return Array.from(this.rooms.values()).find((room) => room.clientGame.mode === enums_1.GameModes.LimitedCoop && !room.player2);
    }
    addAcceptedPlayer(room, player) {
        room.player2 = player;
        this.updateRoom(room);
    }
    updateRoom(room) {
        this.rooms.set(room.roomId, room);
    }
    deleteRoom(roomId) {
        this.rooms.delete(roomId);
    }
    startGame(socket, server) {
        var _a;
        const room = this.getRoomByPlayerId(socket.id);
        if (!room || ![room.player1.playerId, (_a = room.player2) === null || _a === void 0 ? void 0 : _a.playerId].includes(socket.id)) {
            this.handleGamePageRefresh(socket, server);
            return;
        }
        this.historyService.createEntry(room);
        socket.join(room.roomId);
        this.updateRoom(room);
        server.to(room.roomId).emit(enums_1.GameEvents.GameStarted, room);
    }
    async loadNextGame(room, playedGameIds) {
        const game = await this.gameService.getRandomGame(playedGameIds);
        if (!game)
            return;
        const gameMode = room.clientGame.mode;
        room.clientGame = this.buildClientGameVersion(game);
        room.clientGame.mode = gameMode;
        room.originalDifferences = structuredClone(JSON.parse(fs.readFileSync(`assets/${game.name}/differences.json`, 'utf-8')));
        this.updateRoom(room);
        return game._id.toString();
    }
    validateCoords(socket, coords, server) {
        const roomId = this.getRoomIdFromSocket(socket);
        const room = this.rooms.get(roomId);
        if (!room)
            return;
        const player = room.player1.playerId === socket.id ? room.player1 : room.player2;
        const index = room.originalDifferences.findIndex((difference) => difference.some((coord) => coord.x === coords.x && coord.y === coords.y));
        const localMessage = index !== constants_1.NOT_FOUND ? this.differenceFound(room, player, index) : this.differenceNotFound(room, player);
        const differencesData = {
            currentDifference: player.differenceData.currentDifference,
            differencesFound: player.differenceData.differencesFound,
        };
        server.to(room.roomId).emit(enums_1.MessageEvents.LocalMessage, localMessage);
        server
            .to(room.roomId)
            .emit(enums_1.GameEvents.RemoveDifference, { differencesData, playerId: socket.id, cheatDifferences: room.originalDifferences });
    }
    updateTimers(server) {
        var _a;
        for (const room of this.rooms.values()) {
            const modeInfo = this.modeTimerMap[(_a = room === null || room === void 0 ? void 0 : room.clientGame) === null || _a === void 0 ? void 0 : _a.mode];
            if (!modeInfo || (modeInfo.requiresPlayer2 && !room.player2))
                continue;
            this.updateTimer(room, server, modeInfo.isCountdown);
        }
    }
    async addHintPenalty(socket, server) {
        const roomId = this.getRoomIdFromSocket(socket);
        const room = this.getRoomById(roomId);
        if (!room)
            return;
        const { clientGame, gameConstants, timer } = room;
        let penaltyTime = gameConstants.penaltyTime;
        if (this.isLimitedModeGame(clientGame))
            penaltyTime = -penaltyTime;
        if (timer + penaltyTime < 0) {
            await this.countdownOver(room, server);
        }
        else {
            const hintMessage = this.messageManager.createMessage(enums_1.MessageTag.Common, 'Indice utilisé');
            room.timer += penaltyTime;
            this.rooms.set(room.roomId, room);
            server.to(room.roomId).emit(enums_1.MessageEvents.LocalMessage, hintMessage);
            server.to(room.roomId).emit(enums_1.GameEvents.TimerUpdate, room.timer);
        }
    }
    leaveRoom(room, server) {
        [room.player1, room.player2].forEach((player) => {
            const socket = server.sockets.sockets.get(player === null || player === void 0 ? void 0 : player.playerId);
            if (socket)
                socket.rooms.delete(room.roomId);
        });
    }
    async abandonGame(socket, server) {
        const room = this.getRoomByPlayerId(socket.id);
        if (!room)
            return;
        const player = room.player1.playerId === socket.id ? room.player1 : room.player2;
        const opponent = room.player1.playerId === socket.id ? room.player2 : room.player1;
        this.historyService.markPlayer(room.roomId, player.name, enums_1.PlayerStatus.Quitter);
        if (this.isMultiplayerGame(room.clientGame) && opponent) {
            const localMessage = room.clientGame.mode === enums_1.GameModes.ClassicOneVsOne
                ? await this.handleOneVsOneAbandon(player, room, server)
                : this.handleCoopAbandon(player, room, server);
            server.to(room.roomId).emit(enums_1.MessageEvents.LocalMessage, localMessage);
        }
        else {
            await this.historyService.closeEntry(room.roomId, server);
            this.deleteRoom(room.roomId);
        }
        socket.leave(room.roomId);
    }
    async handleSoloModesDisconnect(room, server) {
        if (room && !room.player2) {
            this.historyService.markPlayer(room.roomId, room.player1.name, enums_1.PlayerStatus.Quitter);
            await this.historyService.closeEntry(room.roomId, server);
            this.deleteRoom(room.roomId);
        }
    }
    differenceFound(room, player, index) {
        this.addBonusTime(room);
        player.differenceData.differencesFound++;
        player.differenceData.currentDifference = room.originalDifferences[index];
        room.originalDifferences.splice(index, 1);
        this.updateRoom(room);
        return this.messageManager.getLocalMessage(room.clientGame.mode, true, player.name);
    }
    differenceNotFound(room, player) {
        player.differenceData.currentDifference = [];
        this.updateRoom(room);
        return this.messageManager.getLocalMessage(room.clientGame.mode, false, player.name);
    }
    handleCoopAbandon(player, room, server) {
        const opponent = this.getOpponent(room, player);
        server.to(opponent.playerId).emit(enums_1.GameEvents.GameModeChanged);
        room.clientGame.mode = enums_1.GameModes.LimitedSolo;
        this.updateRoom(room);
        return this.messageManager.getQuitMessage(player.name);
    }
    addBonusTime(room) {
        if (!this.isLimitedModeGame(room.clientGame))
            return;
        room.timer += room.gameConstants.bonusTime;
        if (room.timer > constants_1.MAX_BONUS_TIME_ALLOWED) {
            room.timer = constants_1.MAX_BONUS_TIME_ALLOWED;
        }
        this.updateRoom(room);
    }
    async updateTimer(room, server, isCountdown) {
        if (isCountdown)
            room.timer--;
        else
            room.timer++;
        this.updateRoom(room);
        server.to(room.roomId).emit(enums_1.GameEvents.TimerUpdate, room.timer);
        if (room.timer === 0)
            await this.countdownOver(room, server);
    }
    async countdownOver(room, server) {
        room.endMessage = 'Temps écoulé !';
        server.to(room.roomId).emit(enums_1.GameEvents.EndGame, room.endMessage);
        await this.historyService.closeEntry(room.roomId, server);
        this.deleteRoom(room.roomId);
        this.leaveRoom(room, server);
    }
    generateRoomId() {
        let id = '';
        for (let i = 0; i < constants_1.KEY_SIZE; i++)
            id += constants_1.CHARACTERS.charAt(Math.floor(Math.random() * constants_1.CHARACTERS.length));
        return id;
    }
    handleGamePageRefresh(socket, server) {
        server.to(socket.id).emit(enums_1.GameEvents.GamePageRefreshed);
    }
    async handleOneVsOneAbandon(player, room, server) {
        const opponent = this.getOpponent(room, player);
        this.historyService.markPlayer(room.roomId, opponent === null || opponent === void 0 ? void 0 : opponent.name, enums_1.PlayerStatus.Winner);
        room.endMessage = "L'adversaire a abandonné la partie!";
        server.to(room.roomId).emit(enums_1.GameEvents.EndGame, room.endMessage);
        this.leaveRoom(room, server);
        await this.historyService.closeEntry(room.roomId, server);
        this.deleteRoom(room.roomId);
        return this.messageManager.getQuitMessage(player === null || player === void 0 ? void 0 : player.name);
    }
    getOpponent(room, player) {
        return room.player1.playerId === player.playerId ? room.player2 : room.player1;
    }
    buildClientGameVersion(game) {
        const clientGame = {
            id: game._id.toString(),
            name: game.name,
            mode: '',
            original: 'data:image/png;base64,'.concat(fs.readFileSync(`assets/${game.name}/original.bmp`, 'base64')),
            modified: 'data:image/png;base64,'.concat(fs.readFileSync(`assets/${game.name}/modified.bmp`, 'base64')),
            isHard: game.isHard,
            differencesCount: game.nDifference,
        };
        return clientGame;
    }
    buildGameRoom(game, playerPayLoad) {
        const gameConstants = this.gameConstants;
        const differenceData = { currentDifference: [], differencesFound: 0 };
        const player = { name: playerPayLoad.playerName, differenceData };
        const room = {
            roomId: this.generateRoomId(),
            clientGame: this.buildClientGameVersion(game),
            timer: 0,
            endMessage: '',
            originalDifferences: structuredClone(JSON.parse(fs.readFileSync(`assets/${game.name}/differences.json`, 'utf-8'))),
            player1: player,
            gameConstants,
        };
        room.clientGame.mode = playerPayLoad.gameMode;
        return room;
    }
    isMultiplayerGame(clientGame) {
        return clientGame.mode === enums_1.GameModes.ClassicOneVsOne || clientGame.mode === enums_1.GameModes.LimitedCoop;
    }
    isLimitedModeGame(clientGame) {
        return clientGame.mode === enums_1.GameModes.LimitedSolo || clientGame.mode === enums_1.GameModes.LimitedCoop;
    }
};
RoomsManagerService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [game_service_1.GameService,
        message_manager_service_1.MessageManagerService,
        history_service_1.HistoryService])
], RoomsManagerService);
exports.RoomsManagerService = RoomsManagerService;
//# sourceMappingURL=rooms-manager.service.js.map