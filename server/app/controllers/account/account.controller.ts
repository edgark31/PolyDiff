import { Credentials } from '@app/model/database/account';
import { AccountManagerService } from '@app/services/account-manager/account-manager.service';
import { Body, Controller, Delete, HttpStatus, Post, Res } from '@nestjs/common';
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

    @Post('pseudo')
    async changePseudo(@Body('oldUsername') oldUsername: string, @Body('newUsername') newUsername: string, @Res() response: Response) {
        try {
            await this.accountManager.changePseudo(oldUsername, newUsername);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.CONFLICT).json(error);
        }
    }

    @Post('avatar')
    async changeAvatar(@Body('username') username: string, @Body('avatar') avatar: string, @Res() response: Response) {
        try {
            await this.accountManager.changeAvatar(username, avatar);
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
