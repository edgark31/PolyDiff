import { Credentials, Theme } from '@app/model/database/account';
import { AccountManagerService } from '@app/services/account-manager/account-manager.service';
import { MailService } from '@app/services/mail-service/mail-service';
import { Song } from '@common/game-interfaces';
import { Body, Controller, Delete, HttpStatus, Post, Put, Res } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { Response } from 'express';

@ApiTags('Accounts')
@Controller('account')
export class AccountController {
    constructor(private readonly accountManager: AccountManagerService, private readonly mailservice: MailService) {}

    @Post('register')
    async register(@Body('creds') creds: Credentials, @Body('id') id: string, @Res() response: Response) {
        try {
            await this.accountManager.register(creds, id);
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

    @Put('password')
    async changePassword(@Body('oldUsername') oldUsername: string, @Body('newPassword') newpassword: string, @Res() response: Response) {
        try {
            await this.accountManager.changePassword(oldUsername, newpassword);
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

    @Post('admin')
    connexionToAdmin(@Body('pass') password: string): { success: boolean } {
        const isValid = this.accountManager.connexionToAdmin(password);
        // response.status(HttpStatus.OK).json({ success: isValid });
        return { success: isValid };
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

    @Put('mail')
    async sendMail(@Body('email') mail: string, @Res() response: Response) {
        try {
            await this.mailservice.signUp(mail);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.NOT_FOUND).json(error);
        }
    }

    @Put('theme')
    async modifyTheme(@Body('oldUsername') oldUsername: string, @Body('newTheme') newtheme: Theme, @Res() response: Response) {
        try {
            await this.accountManager.modifyTheme(oldUsername, newtheme);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.CONFLICT).json(error);
        }
    }

    @Put('langage')
    async modifyLanguage(@Body('oldUsername') oldUsername: string, @Body('newLangage') newLangage: string, @Res() response: Response) {
        try {
            await this.accountManager.modifyLanguage(oldUsername, newLangage);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.CONFLICT).json(error);
        }
    }

    @Put('song/error')
    async modifySongDifference(@Body('oldUsername') oldUsername: string, @Body('newSong') newSongError: Song, @Res() response: Response) {
        try {
            await this.accountManager.modifySongDifference(oldUsername, newSongError);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.CONFLICT).json(error);
        }
    }

    @Put('song/difference')
    async modifySongError(@Body('oldUsername') oldUsername: string, @Body('newSong') newSongDifference: Song, @Res() response: Response) {
        try {
            await this.accountManager.modifySongError(oldUsername, newSongDifference);
            response.status(HttpStatus.OK).send();
        } catch (error) {
            response.status(HttpStatus.CONFLICT).json(error);
        }
    }
}
