import { Injectable } from '@nestjs/common';

import { MailService } from '@app/services/mail-service/mail-service';

@Injectable()
export class AuthService {
    constructor(private mailService: MailService) {}

    async signUp() {
        // const token = Math.floor(1000 + Math.random() * 9000).toString();
        // create user in db
        // ...
        // send confirmation mail
        await this.mailService.sendUserConfirmation();
    }
}
