"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.MessageManagerService = void 0;
const constants_1 = require("../../../../common/constants");
const enums_1 = require("../../../../common/enums");
const common_1 = require("@nestjs/common");
let MessageManagerService = class MessageManagerService {
    getQuitMessage(playerName) {
        return this.createMessage(enums_1.MessageTag.Common, `${playerName} a abandonné la partie`);
    }
    getNewRecordMessage(newRecord) {
        const content = `${newRecord.playerName} obtient la ${constants_1.SCORE_POSITION[newRecord.rank]} place` +
            ` dans les meilleurs temps du jeu ${newRecord.gameName} en ${newRecord.gameMode}`;
        return this.createMessage(enums_1.MessageTag.Global, content);
    }
    getLocalMessage(gameMode, isDifferenceFound, playerName) {
        let content = isDifferenceFound ? 'Différence trouvée' : 'Erreur';
        if (gameMode !== enums_1.GameModes.ClassicSolo && gameMode !== enums_1.GameModes.LimitedSolo) {
            content += ` par ${playerName}`;
        }
        return this.createMessage(enums_1.MessageTag.Common, content);
    }
    createMessage(tag, content) {
        const date = new Date();
        const time = `${date.getHours()} : ${date.getMinutes()} : ${date.getSeconds()}`;
        const message = time + ' - ' + content;
        return { tag, message };
    }
};
MessageManagerService = __decorate([
    (0, common_1.Injectable)()
], MessageManagerService);
exports.MessageManagerService = MessageManagerService;
//# sourceMappingURL=message-manager.service.js.map