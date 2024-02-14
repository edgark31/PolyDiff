import { Credentials } from '@app/model/database/account';
import { AccountManagerService } from '@app/services/account-manager/account-manager/account-manager.service';
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
