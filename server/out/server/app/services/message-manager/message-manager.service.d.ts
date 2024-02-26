import { MessageTag } from '@common/enums';
import { ChatMessage, NewRecord } from '@common/game-interfaces';
export declare class MessageManagerService {
    getQuitMessage(playerName: string): ChatMessage;
    getNewRecordMessage(newRecord: NewRecord): ChatMessage;
    getLocalMessage(gameMode: string, isDifferenceFound: boolean, playerName: string): ChatMessage;
    createMessage(tag: MessageTag, content: string): ChatMessage;
}
