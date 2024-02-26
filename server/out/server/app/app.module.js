"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const mongoose_1 = require("@nestjs/mongoose");
const game_controller_1 = require("./controllers/game/game.controller");
const game_gateway_1 = require("./gateways/game/game.gateway");
const game_1 = require("./model/database/game");
const game_card_1 = require("./model/database/game-card");
const game_config_constants_1 = require("./model/database/game-config-constants");
const game_history_1 = require("./model/database/game-history");
const classic_mode_service_1 = require("./services/classic-mode/classic-mode.service");
const database_service_1 = require("./services/database/database.service");
const game_lists_manager_service_1 = require("./services/game-lists-manager/game-lists-manager.service");
const game_service_1 = require("./services/game/game.service");
const history_service_1 = require("./services/history/history.service");
const limited_mode_service_1 = require("./services/limited-mode/limited-mode.service");
const message_manager_service_1 = require("./services/message-manager/message-manager.service");
const players_list_manager_service_1 = require("./services/players-list-manager/players-list-manager.service");
const rooms_manager_service_1 = require("./services/rooms-manager/rooms-manager.service");
let AppModule = class AppModule {
};
AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            config_1.ConfigModule.forRoot({ isGlobal: true }),
            mongoose_1.MongooseModule.forRootAsync({
                imports: [config_1.ConfigModule],
                inject: [config_1.ConfigService],
                useFactory: async (config) => ({
                    useNewUrlParser: true,
                    uri: config.get('DATABASE_CONNECTION_STRING'),
                }),
            }),
            mongoose_1.MongooseModule.forFeature([
                { name: game_1.Game.name, schema: game_1.gameSchema },
                { name: game_card_1.GameCard.name, schema: game_card_1.gameCardSchema },
                { name: game_config_constants_1.GameConstants.name, schema: game_config_constants_1.gameConstantsSchema },
                { name: game_history_1.GameHistory.name, schema: game_history_1.gameHistorySchema },
            ]),
        ],
        controllers: [game_controller_1.GameController],
        providers: [
            common_1.Logger,
            game_service_1.GameService,
            database_service_1.DatabaseService,
            config_1.ConfigService,
            game_gateway_1.GameGateway,
            classic_mode_service_1.ClassicModeService,
            game_lists_manager_service_1.GameListsManagerService,
            message_manager_service_1.MessageManagerService,
            history_service_1.HistoryService,
            players_list_manager_service_1.PlayersListManagerService,
            rooms_manager_service_1.RoomsManagerService,
            limited_mode_service_1.LimitedModeService,
        ],
    })
], AppModule);
exports.AppModule = AppModule;
//# sourceMappingURL=app.module.js.map