import { Credentials } from '@app/model/database/account';
import { AccountManagerService } from '@app/services/account-manager/account-manager/account-manager.service';
import { Body, Controller, HttpStatus, Post, Res } from '@nestjs/common';
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
            response.status(HttpStatus.CONFLICT).send(error.message);
        }
    }

    @Post('login')
    async login(@Body() creds: Credentials, @Res() response: Response) {
        try {
            const accountFound = await this.accountManager.connexion(creds);
            response.status(HttpStatus.OK).json(accountFound);
        } catch (error) {
            response.status(HttpStatus.UNAUTHORIZED).send(error.message);
        }
    }
}
