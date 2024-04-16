/* eslint-disable @typescript-eslint/no-magic-numbers */
/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable max-params */
import { AuthGateway } from '@app/gateways/auth/auth.gateway';
import { Credentials, Sound } from '@app/model/database/account';
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
    async register(@Body('creds') creds: Credentials, @Body('defaultId') defaultId: string, @Res() response: Response) {
        try {
            const account = await this.accountManager.register(creds, defaultId);
            response.status(HttpStatus.OK).send(account);
            await this.accountManager.fetchUsers();
            setTimeout(() => {
                this.auth.server.emit(UserEvents.UpdateUsers, this.friendManager.queryUsers());
            }, 1000);
        } catch (error) {
            response.status(HttpStatus.CONFLICT).json(error);
        }
    }

    @Post('login')
    async connection(@Body() creds: Credentials, @Res() response: Response) {
        try {
            const accountFound = await this.accountManager.connection(creds);
            response.status(HttpStatus.OK).json(accountFound);
            await this.accountManager.fetchUsers();
            setTimeout(() => {
                this.auth.server.fetchSockets().then((sockets) => {
                    sockets.forEach((socket) => {
                        this.auth.updateIsOnline(socket as any);
                        if (
                            accountFound.profile.friends.find((friend) => {
                                return friend.accountId === socket.data.accountId;
                            })
                        ) {
                            this.auth.handleOnlineMessage(socket as any, accountFound.credentials.username);
                        }
                    });
                });
            }, 1000);
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
    async updateUsername(@Body('username') accountId: string, @Body('newUsername') newUsername: string, @Res() response: Response) {
        try {
            await this.accountManager.updateUsername(accountId, newUsername);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.CONFLICT).json(error);
        }
    }

    @Put('password')
    async updatePassword(@Body('username') accountId: string, @Body('newPassword') newPassword: string, @Res() response: Response) {
        try {
            await this.accountManager.updatePassword(accountId, newPassword);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.CONFLICT).json(error);
        }
    }

    @Put('avatar/upload')
    async uploadAvatar(@Body('username') accountId: string, @Body('avatar') avatar: string, @Res() response: Response) {
        try {
            await this.accountManager.uploadAvatar(accountId, avatar);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.CONFLICT).json(error);
        }
    }

    @Put('avatar/choose')
    async chooseAvatar(@Body('username') accountId: string, @Body('defaultId') defaultId: string, @Res() response: Response) {
        try {
            await this.accountManager.chooseAvatar(accountId, defaultId);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.CONFLICT).json(error);
        }
    }

    @Put('mobile/theme')
    async updateMobileTheme(@Body('username') accountId: string, @Body('newTheme') newTheme: string, @Res() response: Response) {
        try {
            await this.accountManager.updateMobileTheme(accountId, newTheme);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.CONFLICT).json(error);
        }
    }

    @Put('language')
    async updateLanguage(@Body('username') accountId: string, @Body('newLanguage') newLanguage: string, @Res() response: Response) {
        try {
            await this.accountManager.modifyLanguage(accountId, newLanguage);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.CONFLICT).json(error);
        }
    }

    @Put('sound/correct')
    async updateCorrectSound(@Body('username') accountId: string, @Body('newSound') newSound: Sound, @Res() response: Response) {
        try {
            await this.accountManager.updateCorrectSound(accountId, newSound);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.CONFLICT).json(error);
        }
    }

    @Put('sound/error')
    async updateErrorSound(@Body('username') accountId: string, @Body('newSound') newSound: Sound, @Res() response: Response) {
        try {
            await this.accountManager.updateErrorSound(accountId, newSound);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.CONFLICT).json(error);
        }
    }

    @Put('mail')
    async sendMail(@Body('email') mail: string, @Res() response: Response) {
        try {
            const accountFound = await this.mailService.signUp(mail);
            response.status(HttpStatus.OK).send(accountFound);
        } catch (error) {
            response.status(HttpStatus.NOT_FOUND).json(error);
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
}
