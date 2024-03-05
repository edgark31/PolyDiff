import { MailerService } from '@nestjs-modules/mailer';
import { Injectable } from '@nestjs/common';

@Injectable()
export class MailService {
    constructor(private mailerService: MailerService) {}

    async sendUserConfirmation() {
        // const url = `example.com/auth/confirm?token=${token}`;

        await this.mailerService.sendMail({
            // to: user.credentials.email,
            to: 'gningmohamedlamine@gmail.com',
            subject: 'Welcome to Nice App! Confirm your Email',
            template: './confirmation',
            // context: {
            //     name: user.credentials.username,
            //     url,
            // },
        });
    }
}
