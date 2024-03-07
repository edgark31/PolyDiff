import { AccountManagerService } from '@app/services/account-manager/account-manager.service';
import { CardManagerService } from '@app/services/card-manager/card-manager.service';
import { CardEvents } from '@common/enums';
import { GameDetails } from '@common/game-interfaces';
import { Injectable, Logger } from '@nestjs/common';
import {
    ConnectedSocket,
    MessageBody,
    OnGatewayConnection,
    OnGatewayDisconnect,
    OnGatewayInit,
    SubscribeMessage,
    WebSocketGateway,
    WebSocketServer,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { DELAY_BEFORE_EMITTING_TIME } from './game.gateway.constants';

@WebSocketGateway({
    namespace: '/game',
})
@Injectable()
export class GameGateway implements OnGatewayConnection, OnGatewayDisconnect, OnGatewayInit {
    @WebSocketServer() private server: Server;

    // gateway needs to be injected all the services that it needs to use
    // eslint-disable-next-line max-params -- services are needed for the gateway
    constructor(
        private readonly logger: Logger,
        private readonly accountManager: AccountManagerService,
        private readonly cardManager: CardManagerService,
    ) {}

    // -------------------------- --- DÉMARRAGE DE PARTIE + GESTION DES LOBBYS

    // @SubscribeMessage(GameEvents.StartGameByRoomId)
    // startGame(@ConnectedSocket() socket: Socket) {
    //     this.roomsManagerService.startGame(socket, this.server);
    // }

    // @SubscribeMessage(RoomEvents.CreateClassicSoloRoom)
    // async createSoloRoom(@ConnectedSocket() socket: Socket, @MessageBody() playerPayLoad: PlayerData) {
    //     await this.classicModeService.createSoloRoom(socket, playerPayLoad, this.server);
    // }

    // @SubscribeMessage(RoomEvents.CreateOneVsOneRoom)
    // async createOneVsOneRoom(@ConnectedSocket() socket: Socket, @MessageBody() playerPayLoad: PlayerData) {
    //     await this.classicModeService.createOneVsOneRoom(socket, playerPayLoad, this.server);
    // }

    // @SubscribeMessage(RoomEvents.CreateLimitedRoom)
    // async createLimitedRoom(@ConnectedSocket() socket: Socket, @MessageBody() playerPayLoad: PlayerData) {
    //     await this.limitedModeService.createLimitedRoom(socket, playerPayLoad, this.server);
    // }

    // @SubscribeMessage(GameEvents.StartNextGame)
    // async startNextGame(@ConnectedSocket() socket: Socket) {
    //     await this.limitedModeService.startNextGame(socket, this.server);
    // }

    // -------------------------- --- DÉROULEMENT DE PARTIE

    // @SubscribeMessage(GameEvents.RemoveDifference)
    // validateCoords(@ConnectedSocket() socket: Socket, @MessageBody() coords: Coordinate) {
    //     this.roomsManagerService.validateCoords(socket, coords, this.server);
    // }

    // @SubscribeMessage(GameEvents.CheckStatus)
    // async checkStatus(@ConnectedSocket() socket: Socket) {
    //     await this.classicModeService.checkStatus(socket, this.server);
    // }

    // @SubscribeMessage(GameEvents.AbandonGame)
    // async abandonGame(@ConnectedSocket() socket: Socket) {
    //     await this.roomsManagerService.abandonGame(socket, this.server);
    // }

    // -------------------------- --- GESTION DES LOBBYS

    // @SubscribeMessage(RoomEvents.UpdateRoomOneVsOneAvailability)
    // updateRoomOneVsOneAvailability(@ConnectedSocket() socket: Socket, @MessageBody() gameId: string) {
    //     this.classicModeService.updateRoomOneVsOneAvailability(socket.id, gameId, this.server);
    // }

    // @SubscribeMessage(RoomEvents.CheckRoomOneVsOneAvailability)
    // checkRoomOneVsOneAvailability(@ConnectedSocket() socket: Socket, @MessageBody() gameId: string) {
    //     this.classicModeService.checkRoomOneVsOneAvailability(socket.id, gameId, this.server);
    // }

    // @SubscribeMessage(RoomEvents.DeleteCreatedOneVsOneRoom)
    // deleteCreatedOneVsOneRoom(@ConnectedSocket() socket: Socket, @MessageBody() roomId: string) {
    //     const room = this.roomsManagerService.getRoomById(roomId);
    //     if (!room) return;
    //     this.playersListManagerService.cancelAllJoining(room.clientGame.id, this.server);
    //     this.classicModeService.deleteCreatedRoom(socket.id, roomId, this.server);
    // }
    // @SubscribeMessage(RoomEvents.DeleteCreatedCoopRoom)
    // deleteCreatedCoopRoom(@ConnectedSocket() socket: Socket, @MessageBody() roomId: string) {
    //     this.roomsManagerService.deleteRoom(roomId);
    //     this.limitedModeService.deleteAvailableGame(roomId);
    //     socket.leave(roomId);
    // }

    // @SubscribeMessage(PlayerEvents.GetJoinedPlayerNames)
    // getJoinedPlayerNames(@ConnectedSocket() socket: Socket, @MessageBody() gameId: string) {
    //     this.playersListManagerService.getWaitingPlayerNameList(socket.id, gameId, this.server);
    // }

    // @SubscribeMessage(PlayerEvents.UpdateWaitingPlayerNameList)
    // updateWaitingPlayerNameList(@ConnectedSocket() socket: Socket, @MessageBody() playerPayLoad: PlayerData) {
    //     this.playersListManagerService.updateWaitingPlayerNameList(playerPayLoad, socket);
    //     const hostId = this.roomsManagerService.getHostIdByGameId(playerPayLoad.gameId);
    //     this.playersListManagerService.getWaitingPlayerNameList(hostId, playerPayLoad.gameId, this.server);
    // }

    // @SubscribeMessage(PlayerEvents.RefusePlayer)
    // refusePlayer(@ConnectedSocket() socket: Socket, @MessageBody() playerPayLoad: PlayerData) {
    //     this.playersListManagerService.refusePlayer(playerPayLoad, this.server);
    //     this.playersListManagerService.getWaitingPlayerNameList(socket.id, playerPayLoad.gameId, this.server);
    // }

    // @SubscribeMessage(PlayerEvents.AcceptPlayer)
    // acceptPlayer(@ConnectedSocket() socket: Socket, @MessageBody() data: { gameId: string; roomId: string; playerName: string }) {
    //     const acceptedPlayer = this.playersListManagerService.getAcceptPlayer(data.gameId, this.server);
    //     this.classicModeService.acceptPlayer(acceptedPlayer, data.roomId, this.server);
    //     this.classicModeService.updateRoomOneVsOneAvailability(socket.id, data.gameId, this.server);
    //     this.playersListManagerService.deleteJoinedPlayersByGameId(data.gameId);
    // }

    // @SubscribeMessage(PlayerEvents.CancelJoining)
    // cancelJoining(@ConnectedSocket() socket: Socket, @MessageBody() gameId: string) {
    //     this.playersListManagerService.cancelJoiningByPlayerId(socket.id, gameId);
    //     const hostId = this.roomsManagerService.getHostIdByGameId(gameId);
    //     this.playersListManagerService.getWaitingPlayerNameList(hostId, gameId, this.server);
    // }

    // @SubscribeMessage(RoomEvents.CheckIfAnyCoopRoomExists)
    // checkIfAnyCoopRoomExists(@ConnectedSocket() socket: Socket, @MessageBody() playerPayLoad: PlayerData) {
    //     this.limitedModeService.checkIfAnyCoopRoomExists(socket, playerPayLoad, this.server);
    // }

    // @SubscribeMessage(MessageEvents.LocalMessage)
    // sendMessage(@ConnectedSocket() socket: Socket, @MessageBody() data: ChatMessage) {
    //     const roomId = this.roomsManagerService.getRoomIdFromSocket(socket);
    //     socket.broadcast.to(roomId).emit(MessageEvents.LocalMessage, data);
    // }

    // -------------------------- --- GESTION DES FICHES (synchronisation, suppression, ajout)

    @SubscribeMessage(CardEvents.CardCreated)
    handleCardCreation(@ConnectedSocket() socket: Socket, @MessageBody() card: GameDetails) {
        this.cardManager.addGameInDb(card);
        this.server.emit(CardEvents.RequestReload);
    }

    // @SubscribeMessage(GameCardEvents.GameCardDeleted)
    // gameCardDeleted(@MessageBody() gameId: string) {
    //     this.server.emit(GameCardEvents.RequestReload);
    //     this.server.emit(GameCardEvents.GameDeleted, gameId);
    //     this.limitedModeService.handleDeleteGame(gameId);
    // }

    // @SubscribeMessage(GameCardEvents.AllGamesDeleted)
    // allGamesDeleted() {
    //     this.server.emit(GameCardEvents.RequestReload);
    //     this.limitedModeService.handleDeleteAllGames();
    // }

    // -------------------------- --- UNDEFINED

    // @SubscribeMessage(GameCardEvents.ResetTopTime)
    // resetTopTime(@MessageBody() gameId: string) {
    //     this.playersListManagerService.resetTopTime(gameId, this.server);
    // }

    // @SubscribeMessage(GameCardEvents.ResetAllTopTimes)
    // resetAllTopTime() {
    //     this.playersListManagerService.resetAllTopTime(this.server);
    // }

    // @SubscribeMessage(GameCardEvents.GameConstantsUpdated)
    // async gameConstantsUpdated() {
    //     this.server.emit(GameCardEvents.RequestReload);
    //     await this.roomsManagerService.getGameConstants();
    // }

    // @SubscribeMessage(GameCardEvents.GamesHistoryDeleted)
    // gamesHistoryDeleted() {
    //     this.server.emit(GameCardEvents.RequestReload);
    // }

    afterInit() {
        setInterval(() => {
            // this.roomsManagerService.updateTimers(this.server);
        }, DELAY_BEFORE_EMITTING_TIME);
    }

    handleConnection(@ConnectedSocket() socket: Socket) {
        const userName = socket.handshake.query.name as string;
        socket.data.username = userName;
        this.logger.log(`GAME ON de ${userName}`);
    }

    async handleDisconnect(@ConnectedSocket() socket: Socket) {
        this.accountManager.deconnexion(socket.data.username);
        this.logger.log(`GAME OFF de ${socket.data.username}`);
    }
}
