import { SCORE_POSITION } from '@common/constants';
import { GameModes } from '@common/enums';
import { Chat, NewRecord } from '@common/game-interfaces';
import { Injectable } from '@nestjs/common';

@Injectable()
export class MessageManagerService {
    getQuitMessage(playerName: string): Chat {
        return this.createMessage(playerName, 'a abandonné la partie');
    }

    getNewRecordMessage(newRecord: NewRecord): Chat {
        const content =
            `${newRecord.playerName} obtient la ${SCORE_POSITION[newRecord.rank]} place` +
            ` dans les meilleurs temps du jeu ${newRecord.gameName} en ${newRecord.gameMode}`;
        return this.createMessage(newRecord.playerName, content);
    }

    getLocalMessage(gameMode: string, isDifferenceFound: boolean, playerName: string): Chat {
        let content = isDifferenceFound ? 'Différence trouvée' : 'Erreur';
        if (gameMode !== GameModes.ClassicSolo && gameMode !== GameModes.LimitedSolo) {
            content += ` par ${playerName}`;
        }
        return this.createMessage(playerName, content);
    }

    createMessage(name: string, content: string, accountId: string = null): Chat {
        const timestamp = new Date().toLocaleTimeString('en-US', {
            timeZone: 'America/Toronto',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
        });
        const raw = content;
        return { raw, accountId, name, timestamp };
    }
}
