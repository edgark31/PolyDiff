/* eslint-disable max-lines */
/* eslint-disable complexity */
/* eslint-disable no-case-declarations */
/* eslint-disable @typescript-eslint/no-unused-expressions */
/* eslint-disable no-unused-expressions */
/* eslint-disable no-underscore-dangle */
/* eslint-disable max-params */
import { AccountManagerService } from '@app/services/account-manager/account-manager.service';
import { GameService } from '@app/services/game/game.service';
import { ImageManagerService } from '@app/services/image-manager/image-manager.service';
import { MessageManagerService } from '@app/services/message-manager/message-manager.service';
import { RecordManagerService } from '@app/services/record-manager/record-manager.service';
import { RoomsManagerService } from '@app/services/rooms-manager/rooms-manager.service';
import { NOT_FOUND } from '@common/constants';
import { ChannelEvents, GameEvents, GameModes, GameState, MessageTag } from '@common/enums';
import { Chat, Coordinate, Game, GameEventData } from '@common/game-interfaces';
import { Injectable, Logger } from '@nestjs/common';
import { ConnectedSocket, MessageBody, OnGatewayConnection, SubscribeMessage, WebSocketGateway, WebSocketServer } from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { DELAY_BEFORE_EMITTING_TIME } from './game.gateway.constants';

@WebSocketGateway({
    namespace: '/game',
})
@Injectable()
export class GameGateway implements OnGatewayConnection {
    @WebSocketServer() private server: Server;
    games = new Map<string, Game>();
    timers = new Map<string, NodeJS.Timeout>();

    constructor(
        private readonly logger: Logger,
        private readonly accountManager: AccountManagerService,
        private readonly gameService: GameService,
        private readonly roomsManager: RoomsManagerService,
        private readonly messageManager: MessageManagerService,
        private readonly imageManager: ImageManagerService,
        private readonly recordManager: RecordManagerService,
    ) {}

    // ------------------ CLASSIC MODE && LIMITED MODE ------------------
    @SubscribeMessage(GameEvents.StartGame)
    async startGame(@ConnectedSocket() socket: Socket, @MessageBody() lobbyId: string) {
        socket.join(lobbyId);
        // To start the game at the same time for each player
        if (Array.from(await this.server.in(lobbyId).fetchSockets()).length === this.roomsManager.lobbies.get(lobbyId).players.length) {
            if (
                this.roomsManager.lobbies.get(lobbyId).mode === GameModes.Classic ||
                this.roomsManager.lobbies.get(lobbyId).mode === GameModes.Practice
            ) {
                const lobby = this.roomsManager.lobbies.get(lobbyId);
                const gameId = lobby.gameId;
                await this.gameService.getGameById(gameId).then((game) => {
                    // Mettre une copie de game(db) vers game(game) et l'identifier par le lobbyId
                    const clonedGame: Game = structuredClone({
                        lobbyId,
                        name: game.name,
                        original: game.originalImage,
                        modified: game.modifiedImage,
                        gameId: game._id.toString(),
                        differences: JSON.parse(game.differences) as Coordinate[][],
                        nDifferences: JSON.parse(game.differences).length,
                    });
                    this.games.set(lobbyId, clonedGame);
                    if (this.roomsManager.lobbies.get(lobbyId).mode === GameModes.Classic) {
                        const players = this.roomsManager.lobbies.get(lobbyId).players;

                        /* --------- Create Game Record on StartGame Event -------- */
                        this.recordManager.createEntry(clonedGame, players, lobby.isCheatEnabled, this.roomsManager.lobbies.get(lobbyId).timeLimit);
                        this.logger.verbose(`Game Gateway : Game Event StartGame, Game ${clonedGame.name} created`);
                    }
                });
                this.server.to(lobbyId).emit(GameEvents.StartGame, this.games.get(lobbyId));
                this.logger.log(`Game started in lobby -> ${lobbyId}`);
            } else if (this.roomsManager.lobbies.get(lobbyId).mode === GameModes.Limited) {
                await this.nextGame(lobbyId, []);
                this.server.to(lobbyId).emit(GameEvents.StartGame, this.games.get(lobbyId));
                this.logger.log(`Game started in lobby -> ${lobbyId}`);
            }
            if (this.roomsManager.lobbies.get(lobbyId).mode === GameModes.Practice) return;
            // Set timer individually for each lobby
            const timerId = setInterval(() => {
                if (!this.roomsManager.lobbies.get(lobbyId)) {
                    clearInterval(timerId);
                    this.timers.delete(lobbyId);
                    return;
                }
                if (this.roomsManager.lobbies.get(lobbyId).time <= 0) {
                    this.server.to(lobbyId).emit(GameEvents.EndGame, 'Temps écoulé !');
                    this.logDraw(lobbyId);
                    clearInterval(timerId);
                    this.deleteLobby(lobbyId);
                    return;
                }
                this.roomsManager.lobbies.get(lobbyId).time -= 1;
                this.roomsManager.lobbies.get(lobbyId).timePlayed += 1;
                this.server.to(lobbyId).emit(GameEvents.TimerUpdate, this.roomsManager.lobbies.get(lobbyId).time);
            }, DELAY_BEFORE_EMITTING_TIME);
            this.timers.set(lobbyId, timerId);
        }
    }

    @SubscribeMessage(GameEvents.Spectate)
    async spectate(@ConnectedSocket() socket: Socket, @MessageBody() lobbyId: string) {
        if (this.roomsManager.lobbies.get(lobbyId).isAvailable) return;
        socket.data.state = GameState.Spectate;
        socket.join(lobbyId);
        if (this.roomsManager.lobbies.get(lobbyId).mode === GameModes.Classic) {
            const game: Game = structuredClone(this.games.get(lobbyId));
            await this.imageManager.observerImage(game).then((image) => {
                game.modified = 'data:image/png;base64,' + image;
            });
            socket.emit(GameEvents.Spectate, {
                lobby: this.roomsManager.lobbies.get(lobbyId),
                game,
            });
            return;
        }
        socket.emit(GameEvents.Spectate, {
            lobby: this.roomsManager.lobbies.get(lobbyId),
            game: this.games.get(lobbyId),
        });
    }

    @SubscribeMessage(GameEvents.Clic)
    async clic(
        @ConnectedSocket() socket: Socket,
        @MessageBody('lobbyId') lobbyId: string,
        @MessageBody('coordClic') coordClic: Coordinate,
        @MessageBody('isMainCanvas') isMainCanvas: boolean,
    ) {
        this.logger.log(`Click event received from ${socket.data.accountId} in lobby ${lobbyId}`);

        const index: number = this.games
            .get(lobbyId)
            .differences.findIndex((difference) => difference.some((coord: Coordinate) => coord.x === coordClic.x && coord.y === coordClic.y));
        const commonMessage =
            index !== NOT_FOUND
                ? `${this.accountManager.connectedUsers.get(socket.data.accountId).credentials.username} a trouvé une différence !`
                : `${this.accountManager.connectedUsers.get(socket.data.accountId).credentials.username} s'est trompé !`;
        const commonChat: Chat = { raw: commonMessage, tag: MessageTag.Common };
        // ------------------ CLASSIC MODE ------------------
        if (this.roomsManager.lobbies.get(lobbyId).mode === GameModes.Classic) {
            // Difference found, update state of game
            if (index !== NOT_FOUND) {
                this.logger.log(`Found event received from ${socket.data.accountId.name} in lobby ${lobbyId}`);

                /* --------- Record Difference Found Event -------- */
                this.recordManager.addGameEvent(lobbyId, {
                    accountId: socket.data.accountId,
                    gameEvent: GameEvents.Found,
                    players: this.roomsManager.lobbies.get(lobbyId).players,
                    coordClic,
                    isMainCanvas,
                } as GameEventData);

                this.roomsManager.lobbies.get(lobbyId).players.find((player) => player.accountId === socket.data.accountId).count++;
                const difference = this.games.get(lobbyId).differences[index];
                this.games.get(lobbyId).differences.splice(index, 1);
                const remainingDifferences: Coordinate[][] = this.games.get(lobbyId).differences;
                this.server.to(lobbyId).emit(GameEvents.Found, {
                    lobby: this.roomsManager.lobbies.get(lobbyId),
                    difference,
                });

                this.roomsManager.lobbies.get(lobbyId).isCheatEnabled ? this.server.to(lobbyId).emit(GameEvents.Cheat, remainingDifferences) : null;
                this.roomsManager.lobbies.get(lobbyId).chatLog.chat.push(commonChat);
                this.server.to(lobbyId).emit(ChannelEvents.GameMessage, commonChat);
                // Vérifier si un seuil est atteint pour un joueur
                const { isGameFinished, potentialWinner } = this.thresholdCheck(lobbyId);

                if (isGameFinished && potentialWinner) {
                    /* --------- Record EndGame Event -------- */
                    this.recordManager.closeEntry(lobbyId);
                    const record = this.recordManager.getPendingGameRecord(lobbyId);

                    /* --------- Send Record on End Game -------- */
                    this.server.to(lobbyId).emit(GameEvents.GameRecord, record);
                    this.server.to(lobbyId).emit(GameEvents.EndGame, 'Fin de la partie');
                    this.logOneWinner(lobbyId, potentialWinner.accountId);
                    const winChat: Chat = {
                        raw: `${this.accountManager.connectedUsers.get(potentialWinner.accountId).credentials.username} a gagné !`,
                        tag: MessageTag.Common,
                    };
                    this.roomsManager.lobbies.get(lobbyId).chatLog.chat.push(winChat);
                    this.server.to(lobbyId).emit(ChannelEvents.GameMessage, winChat);
                    this.recordManager.pushToDatabase(lobbyId);
                    clearInterval(this.timers.get(lobbyId));
                    this.deleteLobby(lobbyId);
                    return;
                }
                // Vérifier s'il reste des differences
                if (this.games.get(lobbyId).differences.length <= 0) {
                    /* --------- Record EndGame Event -------- */
                    this.recordManager.closeEntry(lobbyId);
                    const record = this.recordManager.getPendingGameRecord(lobbyId);

                    this.server.to(lobbyId).emit(GameEvents.EndGame, 'Fin de la partie');
                    /* --------- Send Record on End Game -------- */
                    this.server.to(lobbyId).emit(GameEvents.GameRecord, record);
                    this.recordManager.pushToDatabase(lobbyId);

                    this.logDraw(lobbyId);
                    const drawChat: Chat = { raw: 'MATCH NUL', tag: MessageTag.Common };
                    this.roomsManager.lobbies.get(lobbyId).chatLog.chat.push(drawChat);
                    this.server.to(lobbyId).emit(ChannelEvents.GameMessage, drawChat);
                    clearInterval(this.timers.get(lobbyId));
                    this.deleteLobby(lobbyId);
                }
                return;
            }
            // If user did not click on a difference
            /* --------- Record Not Found Event -------- */
            this.recordManager.addGameEvent(lobbyId, {
                accountId: socket.data.accountId,
                username: this.accountManager.connectedUsers.get(socket.data.accountId).credentials.username,
                gameEvent: GameEvents.NotFound,
                players: this.roomsManager.lobbies.get(lobbyId).players,
                coordClic,
                isMainCanvas,
            });

            this.roomsManager.lobbies.get(lobbyId).chatLog.chat.push(commonChat);
            this.server.to(lobbyId).emit(ChannelEvents.GameMessage, commonChat);
            socket.emit(GameEvents.NotFound, coordClic);

            // ------------------ LIMITED MODE ------------------
        } else if (this.roomsManager.lobbies.get(lobbyId).mode === GameModes.Limited) {
            // Si trouvé
            if (index !== NOT_FOUND) {
                // Update tout correctement
                this.roomsManager.lobbies.get(lobbyId).players.find((player) => player.accountId === socket.data.accountId).count++;
                // Update le time
                this.roomsManager.lobbies.get(lobbyId).time + this.roomsManager.lobbies.get(lobbyId).bonusTime >=
                this.roomsManager.lobbies.get(lobbyId).timeLimit
                    ? (this.roomsManager.lobbies.get(lobbyId).time = this.roomsManager.lobbies.get(lobbyId).timeLimit)
                    : (this.roomsManager.lobbies.get(lobbyId).time += this.roomsManager.lobbies.get(lobbyId).bonusTime);
                const difference = this.games.get(lobbyId).differences[index];
                this.server.to(lobbyId).emit(GameEvents.Found, {
                    lobby: this.roomsManager.lobbies.get(lobbyId),
                    difference,
                });
                // eslint-disable-next-line @typescript-eslint/no-unused-expressions, no-unused-expressions
                this.roomsManager.lobbies.get(lobbyId).chatLog.chat.push(commonChat);
                this.server.to(lobbyId).emit(ChannelEvents.GameMessage, commonChat);
                // Load la next game
                const game = await this.nextGame(lobbyId, this.games.get(lobbyId).playedGameIds);
                if (!game) {
                    const { winningPlayers, message } = this.limitedEndCheck(lobbyId);
                    this.logger.log(`Game ${lobbyId} ended with ${winningPlayers.length} winner(s)`);
                    this.server.to(lobbyId).emit(GameEvents.EndGame, 'Fin de la partie');
                    winningPlayers.length === 1 ? this.logOneWinner(lobbyId, winningPlayers[0].accountId) : this.logDraw(lobbyId);
                    const endLimitedChat: Chat = { raw: message, tag: MessageTag.Common };
                    this.roomsManager.lobbies.get(lobbyId).chatLog.chat.push(endLimitedChat);
                    this.server.to(lobbyId).emit(ChannelEvents.GameMessage, endLimitedChat);
                    clearInterval(this.timers.get(lobbyId));
                    this.deleteLobby(lobbyId);
                    return;
                } else {
                    this.server.to(lobbyId).emit(GameEvents.NextGame, this.games.get(lobbyId));
                }
                this.roomsManager.lobbies.get(lobbyId).isCheatEnabled
                    ? this.server.to(lobbyId).emit(GameEvents.Cheat, this.games.get(lobbyId).differences)
                    : null;
                return;
            }
            // Si pas trouvé
            this.roomsManager.lobbies.get(lobbyId).chatLog.chat.push(commonChat);
            this.server.to(lobbyId).emit(ChannelEvents.GameMessage, commonChat);
            socket.emit(GameEvents.NotFound, coordClic);
        } else if (this.roomsManager.lobbies.get(lobbyId).mode === GameModes.Practice) {
            // Si trouvé
            if (index !== NOT_FOUND) {
                // Update tout correctement
                this.roomsManager.lobbies.get(lobbyId).players.find((player) => player.accountId === socket.data.accountId).count++;
                const difference = this.games.get(lobbyId).differences[index];
                this.games.get(lobbyId).differences.splice(index, 1);
                this.server.to(lobbyId).emit(GameEvents.Found, {
                    lobby: this.roomsManager.lobbies.get(lobbyId),
                    difference,
                });
                // Vérifier s'il reste des differences
                if (this.games.get(lobbyId).differences.length <= 0) {
                    this.server.to(lobbyId).emit(GameEvents.EndGame, 'Fin de la pratique');
                    this.roomsManager.lobbies.delete(lobbyId);
                    this.games.delete(lobbyId);
                    socket.leave(lobbyId);
                }
                return;
            }
            // Si pas trouvé
            socket.emit(GameEvents.NotFound, coordClic);
        }
    }

    @SubscribeMessage(GameEvents.AbandonGame)
    abandonGame(@ConnectedSocket() socket: Socket, @MessageBody() lobbyId: string) {
        const username = this.accountManager.connectedUsers.get(socket.data.accountId).credentials.username;
        const accountId = socket.data.accountId;
        const players = this.roomsManager.lobbies.get(lobbyId).players;
        socket.data.state = GameState.Abandoned;

        this.roomsManager.lobbies.get(lobbyId).players = this.roomsManager.lobbies
            .get(lobbyId)
            .players.filter((player) => player.accountId !== socket.data.accountId);
        this.roomsManager.lobbies.get(lobbyId).observers = this.roomsManager.lobbies
            .get(lobbyId)
            .observers.filter((observer) => observer.accountId !== socket.data.accountId);
        socket.leave(lobbyId);

        /* ------------------ Record Abandon Event ------------------ */
        this.recordManager.addGameEvent(lobbyId, { gameEvent: GameEvents.AbandonGame, username, accountId } as GameEventData);

        this.logger.log(`${socket.data.accountId} abandoned game ${lobbyId}`);
        const abandonMessage = `${this.accountManager.connectedUsers.get(socket.data.accountId).credentials.username} a abandonné la partie !`;
        const abandonChat: Chat = { raw: abandonMessage, tag: MessageTag.Common };
        this.roomsManager.lobbies.get(lobbyId).chatLog.chat.push(abandonChat);
        this.server.to(lobbyId).emit(ChannelEvents.GameMessage, abandonChat);
        if (this.roomsManager.lobbies.get(lobbyId).players.length <= 1) {
            this.server.to(lobbyId).emit(GameEvents.EndGame, 'Abandon');

            /* ------------------ Record Event ------------------ */
            this.recordManager.addGameEvent(lobbyId, { gameEvent: GameEvents.EndGame, players } as GameEventData);
            this.recordManager.closeEntry(lobbyId);

            clearInterval(this.timers.get(lobbyId));
            this.recordManager.pushToDatabase(lobbyId);
            this.deleteLobby(lobbyId);
            this.logger.log(`Game ${lobbyId} ended because of not enough players`);
            return;
        }
        socket.emit(GameEvents.AbandonGame, this.roomsManager.lobbies.get(lobbyId));
    }

    @SubscribeMessage(GameEvents.CheatActivated)
    cheatActivated(@ConnectedSocket() socket: Socket, @MessageBody('lobbyId') lobbyId: string) {
        const username = this.accountManager.connectedUsers.get(socket.data.accountId).credentials.username;
        const accountId = socket.data.accountId;
        const players = this.roomsManager.lobbies.get(lobbyId).players;

        /* ------------------ Record Event ------------------ */
        this.recordManager.addGameEvent(lobbyId, { gameEvent: GameEvents.CheatActivated, username, accountId, players } as GameEventData);
        this.logger.log(`${username}(${socket.data.accountId}) activated cheat in ${lobbyId}`);
    }

    @SubscribeMessage(GameEvents.CheatDeactivated)
    cheatDeactivated(@ConnectedSocket() socket: Socket, @MessageBody() lobbyId: string) {
        const username = this.accountManager.connectedUsers.get(socket.data.accountId).credentials.username;
        const accountId = socket.data.accountId;

        /* ------------------ Record Event ------------------ */
        this.recordManager.addGameEvent(lobbyId, { gameEvent: GameEvents.CheatDeactivated, username, accountId } as GameEventData);
        this.logger.log(`${username}(${socket.data.accountId}) deactivated cheat in ${lobbyId}`);
    }

    // TODO : check if async function slows down the sending
    // sends back the recorded game when user wants to watch it
    @SubscribeMessage(GameEvents.WatchRecordedGame)
    async handleGameReplay(@ConnectedSocket() socket: Socket, @MessageBody() lobbyId: string) {
        const record = await this.recordManager.getById(lobbyId);
        socket.emit(GameEvents.WatchRecordedGame, record);
    }

    // after replay recorded game, player can save it in his account
    @SubscribeMessage(GameEvents.SaveGameRecord)
    addAccountIdToGameRecord(@ConnectedSocket() socket: Socket, @MessageBody() lobbyId: string) {
        this.recordManager.updateAccountIds(lobbyId, socket.data.accountId);
    }

    @SubscribeMessage(ChannelEvents.SendGameMessage)
    handleGameMessage(@ConnectedSocket() socket: Socket, @MessageBody() lobbyId: string, @MessageBody('message') message: string) {
        const chat: Chat = this.messageManager.createMessage(
            this.accountManager.connectedUsers.get(socket.data.accountId).credentials.username,
            message,
            socket.data.accountId,
        );

        this.roomsManager.lobbies.get(lobbyId).chatLog.chat.push(chat);

        socket.emit(ChannelEvents.GameMessage, { ...chat, tag: MessageTag.Sent });
        socket.broadcast.to(lobbyId).emit(ChannelEvents.GameMessage, { ...chat, tag: MessageTag.Received });
    }

    handleConnection(@ConnectedSocket() socket: Socket) {
        socket.data.accountId = socket.handshake.query.id as string;
        socket.data.state = GameState.InGame;

        socket.on('disconnecting', () => {
            switch (socket.data.state) {
                case GameState.InGame:
                    break;
                case GameState.Abandoned:
                    break;
                case GameState.Spectate:
                    break;
                default:
                    break;
            }
            this.logger.log(`GAME OUT de ${socket.data.accountId}`);
        });
        this.logger.log(`GAME ON de ${socket.data.accountId}`);
    }

    // ------------------ CLASSIC MODE ------------------
    private thresholdCheck(lobbyId: string) {
        const leftDifferences = this.games.get(lobbyId).differences.length;
        let potentialWinner = null;
        let isGameFinished = false;

        const highestCurrentScore = Math.max(...this.roomsManager.lobbies.get(lobbyId).players.map((p) => p.count));

        for (const player of this.roomsManager.lobbies.get(lobbyId).players) {
            const maxPossibleScoreForOtherPlayers: number[] = this.roomsManager.lobbies
                .get(lobbyId)
                .players.filter((p) => p.accountId !== player.accountId)
                .map((p) => p.count + leftDifferences);

            const canAnyOtherPlayerCatchUp: boolean = maxPossibleScoreForOtherPlayers.some((score) => score >= player.count);

            if (!canAnyOtherPlayerCatchUp && player.count === highestCurrentScore) {
                potentialWinner = player;
                isGameFinished = true;
                break;
            }
        }
        return { isGameFinished, potentialWinner };
    }
    // ------------------ LIMITED MODE ------------------
    private limitedEndCheck(lobbyId: string) {
        const players = this.roomsManager.lobbies.get(lobbyId).players;
        const highestScore = Math.max(...players.map((player) => player.count));
        const winningPlayers = players.filter((player) => player.count === highestScore);
        let message: string;

        if (winningPlayers.length === 1) {
            message = `${winningPlayers[0].name} a gagné avec ${highestScore} points !`;
        } else {
            const names = winningPlayers.map((player) => player.name).join(', ');
            message = `Match nul entre ${names} avec ${highestScore} points chacun !`;
        }

        return { winningPlayers, message };
    }

    private async nextGame(lobbyId: string, gamesPlayed: string[]) {
        // Picking one game randomly
        const game = await this.gameService.getRandomGame(gamesPlayed);
        if (!game) return false;
        const clonedGame: Game = structuredClone({
            lobbyId,
            name: game.name,
            original: game.originalImage,
            modified: game.modifiedImage,
            gameId: game._id.toString(),
            differences: JSON.parse(game.differences) as Coordinate[][],
            playedGameIds: [...gamesPlayed, game._id.toString()],
        });
        // Randomly picking one difference to keep
        const keepIndex: number = Math.floor(Math.random() * clonedGame.differences.length);
        const gameCopy = structuredClone(clonedGame);
        clonedGame.modified = 'data:image/png;base64,' + (await this.imageManager.limitedImage(gameCopy, keepIndex));
        clonedGame.differences = clonedGame.differences.filter((_, index) => index === keepIndex);
        this.games.set(lobbyId, clonedGame);
        return game;
    }

    // ------------------ CALCULATE SESSION LOG ------------------

    // "winner" veut dire que tout le monde lose sauf le winner
    private logOneWinner(lobbyId: string, accountId: string) {
        const winner = this.roomsManager.lobbies.get(lobbyId).players.find((player) => player.accountId === accountId);
        this.accountManager.logSession(winner.accountId, true, this.roomsManager.lobbies.get(lobbyId).timePlayed, winner.count);
        const losers = this.roomsManager.lobbies.get(lobbyId).players.filter((player) => player.accountId !== accountId);
        losers.forEach((player) => {
            this.accountManager.logSession(player.accountId, false, this.roomsManager.lobbies.get(lobbyId).timePlayed, player.count);
        });
    }

    // "draw" veut dire que tout le monde lose
    private logDraw(lobbyId: string) {
        this.roomsManager.lobbies.get(lobbyId).players.forEach((player) => {
            this.accountManager.logSession(player.accountId, false, this.roomsManager.lobbies.get(lobbyId).timePlayed, player.count);
        });
    }

    // ------------------ DELETE ROOM/LOBBY/GAME ------------------
    private deleteLobby(lobbyId: string) {
        this.roomsManager.lobbies.delete(lobbyId);
        this.games.delete(lobbyId);
        clearInterval(this.timers.get(lobbyId));
        this.timers.delete(lobbyId);
        this.server
            .in(lobbyId)
            .fetchSockets()
            .then((sockets) => {
                sockets.forEach((socket) => {
                    socket.leave(lobbyId);
                });
            });
        this.accountManager.fetchUsers();
    }
}
