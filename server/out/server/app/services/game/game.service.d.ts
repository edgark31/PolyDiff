import { Game } from '@app/model/database/game';
import { GameHistory } from '@app/model/database/game-history';
import { CreateGameDto } from '@app/model/dto/game/create-game.dto';
import { GameConstantsDto } from '@app/model/dto/game/game-constants.dto';
import { DatabaseService } from '@app/services/database/database.service';
import { CarouselPaginator, GameConfigConst, PlayerTime } from '@common/game-interfaces';
export declare class GameService {
    private readonly databaseService;
    constructor(databaseService: DatabaseService);
    getGameConstants(): Promise<GameConfigConst>;
    getGameCarousel(): Promise<CarouselPaginator[]>;
    verifyIfGameExists(gameName: string): Promise<boolean>;
    getGameById(gameId: string): Promise<Game>;
    deleteGameById(gameId: string): Promise<void>;
    deleteAllGames(): Promise<void>;
    addGame(newGame: CreateGameDto): Promise<void>;
    getTopTimesGameById(gameId: string, gameMode: string): Promise<PlayerTime[]>;
    updateTopTimesGameById(gameId: string, gameMode: string, topTimes: PlayerTime[]): Promise<void>;
    updateGameConstants(gameConstantsDto: GameConstantsDto): Promise<void>;
    resetTopTimesGameById(gameId: string): Promise<void>;
    resetAllTopTimes(): Promise<void>;
    getRandomGame(selectedId: string[]): Promise<Game>;
    getGamesHistory(): Promise<GameHistory[]>;
    saveGameHistory(gameHistory: GameHistory): Promise<void>;
    deleteAllGamesHistory(): Promise<void>;
}
