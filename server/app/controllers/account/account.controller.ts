/* eslint-disable max-params */
import { AuthGateway } from '@app/gateways/auth/auth.gateway';
import { Credentials, Sound, Theme } from '@app/model/database/account';
import { AccountManagerService } from '@app/services/account-manager/account-manager.service';
import { FriendManagerService } from '@app/services/friend-manager/friend-manager.service';
import { MailService } from '@app/services/mail-service/mail-service';
import { UserEvents } from '@common/enums';
import { Body, Controller, Delete, HttpStatus, Post, Put, Res } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { Response } from 'express';

@ApiTags('Accounts')
@Controller('account')
export class AccountController {
    constructor(
        private readonly accountManager: AccountManagerService,
        private readonly friendManager: FriendManagerService,
        private readonly mailService: MailService,
        private readonly auth: AuthGateway,
    ) {}

    @Post('register')
    async register(@Body('creds') creds: Credentials, @Body('id') id: string, @Res() response: Response) {
        try {
            await this.accountManager.register(creds, id);
            response.status(HttpStatus.OK).send();
            this.auth.server.emit(UserEvents.UpdateUsers, this.friendManager.queryUsers());
        } catch (error) {
            response.status(HttpStatus.CONFLICT).json(error);
        }
    }

    @Post('login')
    async connection(@Body() creds: Credentials, @Res() response: Response) {
        try {
            const accountFound = await this.accountManager.connection(creds);
            response.status(HttpStatus.OK).json(accountFound);
        } catch (error) {
            response.status(HttpStatus.UNAUTHORIZED).json(error);
        }
    }

    @Post('admin')
    async connectionToAdmin(@Body('password') password: string, @Res() response: Response) {
        try {
            const accountFound = await this.accountManager.connectionToAdmin(password);
            response.status(HttpStatus.OK).json(accountFound);
        } catch (error) {
            response.status(HttpStatus.UNAUTHORIZED).json(error);
        }
    }

    @Put('username')
    async updateUsername(@Body('oldUsername') oldUsername: string, @Body('newUsername') newUsername: string, @Res() response: Response) {
        try {
            await this.accountManager.updateUsername(oldUsername, newUsername);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.CONFLICT).json(error);
        }
    }

    @Put('password')
    async updatePassword(@Body('username') username: string, @Body('newPassword') newPassword: string, @Res() response: Response) {
        try {
            await this.accountManager.updatePassword(username, newPassword);
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
    async delete(@Body() creds: Credentials, @Res() response: Response) {
        try {
            await this.accountManager.deleteAccount(creds);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.NOT_FOUND).json(error);
        }
    }

    @Delete('erase')
    async scratch(@Res() response: Response) {
        try {
            await this.accountManager.deleteAccounts();
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.NOT_FOUND).json(error);
        }
    }

    @Put('mail')
    async sendMail(@Body('email') mail: string, @Res() response: Response) {
        try {
            await this.mailService.signUp(mail);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.NOT_FOUND).json(error);
        }
    }

    @Put('desktop/theme')
    async updateDesktopTheme(@Body('username') username: string, @Body('newTheme') newTheme: Theme, @Res() response: Response) {
        try {
            await this.accountManager.updateDesktopTheme(username, newTheme);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.CONFLICT).json(error);
        }
    }

    @Put('mobile/theme')
    async updateMobileTheme(@Body('username') username: string, @Body('newTheme') newTheme: string, @Res() response: Response) {
        try {
            await this.accountManager.updateMobileTheme(username, newTheme);
        } catch (error) {
            response.status(HttpStatus.CONFLICT).json(error);
        }
    }

    @Put('language')
    async updateLanguage(@Body('username') username: string, @Body('newLanguage') newLanguage: string, @Res() response: Response) {
        try {
            await this.accountManager.modifyLanguage(username, newLanguage);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.CONFLICT).json(error);
        }
    }

    @Put('sound/correct')
    async updateCorrectSound(@Body('username') username: string, @Body('newSound') newSound: Sound, @Res() response: Response) {
        try {
            await this.accountManager.updateCorrectSound(username, newSound);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.CONFLICT).json(error);
        }
    }

    @Put('sound/error')
    async updateErrorSound(@Body('username') username: string, @Body('newSound') newSound: Sound, @Res() response: Response) {
        try {
            await this.accountManager.updateErrorSound(username, newSound);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.CONFLICT).json(error);
        }
    }
}
