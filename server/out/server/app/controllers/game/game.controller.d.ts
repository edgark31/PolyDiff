import { CreateGameDto } from '@app/model/dto/game/create-game.dto';
import { GameConstantsDto } from '@app/model/dto/game/game-constants.dto';
import { GameService } from '@app/services/game/game.service';
import { Response } from 'express';
export declare class GameController {
    private readonly gameService;
    constructor(gameService: GameService);
    getGameConstants(response: Response): Promise<void>;
    getGamesHistory(response: Response): Promise<void>;
    getGameCarrousel(index: number, response: Response): Promise<void>;
    gameById(id: string, response: Response): Promise<void>;
    verifyIfGameExists(name: string, response: Response): Promise<void>;
    addGame(gameDto: CreateGameDto, response: Response): Promise<void>;
    deleteAllGamesHistory(response: Response): Promise<void>;
    deleteGameById(id: string, response: Response): Promise<void>;
    deleteAllGames(response: Response): Promise<void>;
    updateGameConstants(gameConstantsDto: GameConstantsDto, response: Response): Promise<void>;
}
