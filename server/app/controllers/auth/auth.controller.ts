import { MailService } from '@app/services/mail-service/mail-service';
import { Controller, Get } from '@nestjs/common';

@Controller()
export class AuthController {
    constructor(private readonly mailService: MailService) {}

    @Get()
    sendMail(): void {
        this.mailService.sendUserConfirmation();
    }
}
