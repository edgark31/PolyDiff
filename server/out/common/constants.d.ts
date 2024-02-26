import { PlayerTime } from '@common/game-interfaces';
export declare const DEFAULT_COUNTDOWN_VALUE = 30;
export declare const DEFAULT_HINT_PENALTY = 5;
export declare const DEFAULT_BONUS_TIME = 5;
export declare const MAX_BONUS_TIME_ALLOWED = 120;
export declare const GAME_CARROUSEL_SIZE = 4;
export declare const DEFAULT_BEST_TIMES: PlayerTime[];
export declare const KEY_SIZE = 36;
export declare const CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
export declare const MAX_TIMES_INDEX = 2;
export declare const PADDING_N_DIGITS = 2;
export declare const NOT_FOUND = -1;
export declare const SCORE_POSITION: {
    1: string;
    2: string;
    3: string;
};
export declare const DEFAULT_GAME_MODES: {
    "Classic->Solo": {
        isCountdown: boolean;
    };
    "Classic->OneVsOne": {
        isCountdown: boolean;
        requiresPlayer2: boolean;
    };
    "Limited->Solo": {
        isCountdown: boolean;
    };
    "Limited->Coop": {
        isCountdown: boolean;
        requiresPlayer2: boolean;
    };
};
