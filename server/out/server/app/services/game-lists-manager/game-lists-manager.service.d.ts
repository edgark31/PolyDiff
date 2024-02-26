import { Game } from '@app/model/database/game';
import { CarouselPaginator, GameCard } from '@common/game-interfaces';
export declare class GameListsManagerService {
    private carouselGames;
    constructor();
    buildGameCardFromGame(game: Game): GameCard;
    addGameCarousel(gameCard: GameCard): void;
    buildGameCarousel(gameCards: GameCard[]): void;
    getCarouselGames(): CarouselPaginator[];
}
