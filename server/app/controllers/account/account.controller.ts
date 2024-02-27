import { Credentials } from '@app/model/database/account';
import { AccountManagerService } from '@app/services/account-manager/account-manager.service';
import { Body, Controller, Delete, HttpStatus, Param, Post, Put, Res } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { Response } from 'express';

@ApiTags('Accounts')
@Controller('account')
export class AccountController {
    constructor(private readonly accountManager: AccountManagerService) {}

    @Post('register')
    async register(@Body() creds: Credentials, @Res() response: Response) {
        try {
            await this.accountManager.register(creds);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.CONFLICT).json(error);
        }
    }

    @Post('login')
    async connexion(@Body() creds: Credentials, @Res() response: Response) {
        try {
            const accountFound = await this.accountManager.connexion(creds);
            response.status(HttpStatus.OK).json(accountFound);
        } catch (error) {
            response.status(HttpStatus.UNAUTHORIZED).json(error);
        }
    }

    @Put('pseudo')
    async changePseudo(@Body('oldUsername') oldUsername: string, @Body('newUsername') newUsername: string, @Res() response: Response) {
        try {
            await this.accountManager.changePseudo(oldUsername, newUsername);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.CONFLICT).json(error);
        }
    }

    @Put('avatar/upload')
    async uploadAvatar(@Body('username') username: string, @Body('avatar') avatar: string, @Res() response: Response) {
        try {
            await this.accountManager.uploadAvatar(username, avatar);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.CONFLICT).json(error);
        }
    }

    @Put('avatar/choose')
    async chooseAvatar(@Body('username') username: string, @Body('id') id: string, @Res() response: Response) {
        try {
            await this.accountManager.chooseAvatar(username, id);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.CONFLICT).json(error);
        }
    }

    @Delete('delete')
    async delete(@Res() response: Response) {
        try {
            await this.accountManager.delete();
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.NOT_FOUND).json(error);
        }
    }
}
