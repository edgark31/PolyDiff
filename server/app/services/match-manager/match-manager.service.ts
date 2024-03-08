// import { RoomManagerService } from './../../../../client/src/app/services/room-manager-service/room-manager.service';
// // Id comes from database to allow _id
// /* eslint-disable no-underscore-dangle */
// import { GameService } from '@app/services/game/game.service';
// import { HistoryService } from '@app/services/history/history.service';
// import { MessageManagerService } from '@app/services/message-manager/message-manager.service';
// import { DEFAULT_GAME_MODES } from '@common/constants';
// import { GameConfigConst, GameRoom, TimerMode } from '@common/game-interfaces';
// import { Injectable, OnModuleInit } from '@nestjs/common';

// @Injectable()
// export class MatchManagerService implements OnModuleInit {
//     private gameConstants: GameConfigConst;
//     private modeTimerMap: { [key: string]: TimerMode };
//     private rooms: Map<string, GameRoom>;
//     matches: { [matchId: string]: RoomManagerService } = {}
//     constructor(
//         private readonly gameService: GameService,
//         private readonly messageManager: MessageManagerService,
//         private readonly historyService: HistoryService,
//     ) {
//         this.rooms = new Map<string, GameRoom>();
//         this.modeTimerMap = DEFAULT_GAME_MODES;
//     }

//     async checkMatchExists(code: string): Lobby {
//         const match = this.matches[code];
//         if (!match) {
//             throw new Error('Account not found');
//              }

//     }

// }
