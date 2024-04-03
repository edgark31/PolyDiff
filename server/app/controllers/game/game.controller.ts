import { CreateGameDto } from '@app/model/dto/game/create-game.dto';
import { GameConstantsDto } from '@app/model/dto/game/game-constants.dto';
import { GameService } from '@app/services/game/game.service';
import { RecordManagerService } from '@app/services/record-manager/record-manager.service';
import { Body, Controller, Delete, Get, HttpStatus, Param, Post, Put, Query, Res } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { Response } from 'express';

@ApiTags('Games')
@Controller('games')
export class GameController {
    constructor(private readonly gameService: GameService, private readonly recordManagerService: RecordManagerService) {}

    @Get('/constants')
    async getGameConstants(@Res() response: Response) {
        try {
            const gameConfigConstants = await this.gameService.getGameConstants();
            response.status(HttpStatus.OK).json(gameConfigConstants);
        } catch (error) {
            response.status(HttpStatus.NOT_FOUND).send(error.message);
        }
    }

    @Get('/history')
    async getGamesHistory(@Res() response: Response) {
        try {
            const gameHistory = await this.gameService.getGamesHistory();
            response.status(HttpStatus.OK).json(gameHistory);
        } catch (error) {
            response.status(HttpStatus.NOT_FOUND).send(error.message);
        }
    }

    @Get('/records/:date')
    async getGameRecordByDate(@Param('date') date: string, @Res() response: Response) {
        try {
            const gameRecord = await this.recordManagerService.getByDate(date);
            response.status(HttpStatus.OK).json(gameRecord);
        } catch (error) {
            response.status(HttpStatus.NOT_FOUND).send(error.message);
        }
    }

    @Put('/records/:date')
    async addAccountIdToGameRecord(@Param('date') date: string, @Body() accountId: string, @Res() response: Response) {
        try {
            await this.recordManagerService.addAccountId(date, accountId);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.NOT_FOUND).send(error.message);
        }
    }

    @Delete('/records/:date')
    async deleteAccountIdFromGameRecord(@Param('date') date: string, @Body() accountId: string, @Res() response: Response) {
        try {
            await this.recordManagerService.deleteAccountId(date, accountId);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.NOT_FOUND).send(error.message);
        }
    }

    @Get('carousel/:index')
    async getGameCarrousel(@Param('index') index: number, @Res() response: Response) {
        try {
            const gameCarrousel = await this.gameService.getGameCarousel();
            response.status(HttpStatus.OK).json(gameCarrousel[+index]);
        } catch (error) {
            response.status(HttpStatus.NOT_FOUND).send(error.message);
        }
    }

    @Get('/cards')
    async getGameCards(@Res() response: Response) {
        try {
            const cards = await this.gameService.getGamesCards();
            response.status(HttpStatus.OK).json(cards);
        } catch (error) {
            response.status(HttpStatus.INTERNAL_SERVER_ERROR).send(error.message);
        }
    }

    @Get(':id')
    async gameById(@Param('id') id: string, @Res() response: Response) {
        try {
            const game = await this.gameService.getGameById(id);
            response.status(HttpStatus.OK).json(game);
        } catch (error) {
            response.status(HttpStatus.NOT_FOUND).send(error.message);
        }
    }

    @Get()
    async verifyIfGameExists(@Query('name') name: string, @Res() response: Response) {
        const gameExists = await this.gameService.verifyIfGameExists(name);
        response.status(HttpStatus.OK).json(gameExists);
    }

    @Put('/constants')
    async updateGameConstants(@Body() gameConstantsDto: GameConstantsDto, @Res() response: Response) {
        try {
            await this.gameService.updateGameConstants(gameConstantsDto);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.NO_CONTENT).send(error.message);
        }
    }

    @Post()
    async addGame(@Body() gameDto: CreateGameDto, @Res() response: Response) {
        try {
            await this.gameService.addGame(gameDto);
            response.status(HttpStatus.CREATED).send();
        } catch (error) {
            response.status(HttpStatus.BAD_REQUEST).send(error.message);
        }
    }

    @Delete('/history')
    async deleteAllGamesHistory(@Res() response: Response) {
        try {
            await this.gameService.deleteAllGamesHistory();
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.NO_CONTENT).send(error.message);
        }
    }

    @Delete('/records')
    async deleteAllGameRecords(@Res() response: Response) {
        try {
            await this.gameService.deleteAllGameRecords();
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.NO_CONTENT).send(error.message);
        }
    }

    @Delete(':id')
    async deleteGameById(@Param('id') id: string, @Res() response: Response) {
        try {
            await this.gameService.deleteGameById(id);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.NO_CONTENT).send(error.message);
        }
    }

    @Delete()
    async deleteAllGames(@Res() response: Response) {
        try {
            await this.gameService.deleteAllGames();
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.NO_CONTENT).send(error.message);
        }
    }
}
