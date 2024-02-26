"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DEFAULT_GAME_MODES = exports.SCORE_POSITION = exports.NOT_FOUND = exports.PADDING_N_DIGITS = exports.MAX_TIMES_INDEX = exports.CHARACTERS = exports.KEY_SIZE = exports.DEFAULT_BEST_TIMES = exports.GAME_CARROUSEL_SIZE = exports.MAX_BONUS_TIME_ALLOWED = exports.DEFAULT_BONUS_TIME = exports.DEFAULT_HINT_PENALTY = exports.DEFAULT_COUNTDOWN_VALUE = void 0;
const enums_1 = require("./enums");
exports.DEFAULT_COUNTDOWN_VALUE = 30;
exports.DEFAULT_HINT_PENALTY = 5;
exports.DEFAULT_BONUS_TIME = 5;
exports.MAX_BONUS_TIME_ALLOWED = 120;
exports.GAME_CARROUSEL_SIZE = 4;
exports.DEFAULT_BEST_TIMES = [
    { name: 'John Doe', time: 100 },
    { name: 'Jane Doe', time: 200 },
    { name: 'the scream', time: 250 },
];
exports.KEY_SIZE = 36;
exports.CHARACTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
exports.MAX_TIMES_INDEX = 2;
exports.PADDING_N_DIGITS = 2;
exports.NOT_FOUND = -1;
exports.SCORE_POSITION = { 1: 'première', 2: 'deuxième', 3: 'troisième' };
exports.DEFAULT_GAME_MODES = {
    [enums_1.GameModes.ClassicSolo]: { isCountdown: false },
    [enums_1.GameModes.ClassicOneVsOne]: { isCountdown: false, requiresPlayer2: true },
    [enums_1.GameModes.LimitedSolo]: { isCountdown: true },
    [enums_1.GameModes.LimitedCoop]: { isCountdown: true, requiresPlayer2: true },
};
//# sourceMappingURL=constants.js.map