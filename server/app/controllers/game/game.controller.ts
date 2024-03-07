import { CreateGameDto } from '@app/model/dto/game/create-game.dto';
import { GameConstantsDto } from '@app/model/dto/game/game-constants.dto';
import { CardManagerService } from '@app/services/card-manager/card-manager.service';
import { Body, Controller, Delete, Get, HttpStatus, Param, Post, Put, Query, Res } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { Response } from 'express';

@ApiTags('Games')
@Controller('games')
export class GameController {
    constructor(private readonly cardManager: CardManagerService) {}

    @Get('carousel/:index')
    async getGameCarrousel(@Param('index') index: number, @Res() response: Response) {
        try {
            const gameCarrousel = await this.cardManager.getGamesCarrousel();
            response.status(HttpStatus.OK).json(gameCarrousel[+index]);
        } catch (error) {
            response.status(HttpStatus.NOT_FOUND).send(error.message);
        }
    }

    @Get('/constants')
    async getGameConstants(@Res() response: Response) {
        try {
            const gameConfigConstants = await this.cardManager.getGameConstants();
            response.status(HttpStatus.OK).json(gameConfigConstants);
        } catch (error) {
            response.status(HttpStatus.NOT_FOUND).send(error.message);
        }
    }

    @Get('/history')
    async getGamesHistory(@Res() response: Response) {
        try {
            const gameHistory = await this.cardManager.getGamesHistory();
            response.status(HttpStatus.OK).json(gameHistory);
        } catch (error) {
            response.status(HttpStatus.NOT_FOUND).send(error.message);
        }
    }

    @Get(':id')
    async gameById(@Param('id') id: string, @Res() response: Response) {
        try {
            const game = await this.cardManager.getGameById(id);
            response.status(HttpStatus.OK).json(game);
        } catch (error) {
            response.status(HttpStatus.NOT_FOUND).send(error.message);
        }
    }

    @Get()
    async verifyIfGameExists(@Query('name') name: string, @Res() response: Response) {
        const gameExists = await this.cardManager.verifyIfGameExists(name);
        response.status(HttpStatus.OK).json(gameExists);
    }

    @Delete('/history')
    async deleteAllGamesHistory(@Res() response: Response) {
        try {
            await this.cardManager.deleteAllGamesHistory();
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.NO_CONTENT).send(error.message);
        }
    }

    @Post()
    async addGame(@Body() gameDto: CreateGameDto, @Res() response: Response) {
        try {
            await this.cardManager.addGameInDb(gameDto);
            response.status(HttpStatus.CREATED).send();
        } catch (error) {
            response.status(HttpStatus.BAD_REQUEST).send(error.message);
        }
    }

    @Delete(':id')
    async deleteGameById(@Param('id') id: string, @Res() response: Response) {
        try {
            await this.cardManager.deleteGameById(id);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.NO_CONTENT).send(error.message);
        }
    }

    @Delete()
    async deleteAllGames(@Res() response: Response) {
        try {
            await this.cardManager.deleteAllGames();
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.NO_CONTENT).send(error.message);
        }
    }

    @Put('/constants')
    async updateGameConstants(@Body() gameConstantsDto: GameConstantsDto, @Res() response: Response) {
        try {
            await this.cardManager.updateGameConstants(gameConstantsDto);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.NO_CONTENT).send(error.message);
        }
    }
}
