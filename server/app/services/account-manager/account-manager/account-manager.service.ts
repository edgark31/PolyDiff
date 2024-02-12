import { AccountDocument, AccountSchema } from '@app/model/database/account';
import { Account, Profile } from '@common/game-interfaces';
import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';

@Injectable()
export class AccountManagerService implements OnModuleInit {
    connectedProfiles: Map<string, Profile> = new Map<string, Profile>();

    constructor(private readonly logger: Logger, @InjectModel(AccountSchema.name) private readonly accountModel: Model<AccountDocument>) {}

    onModuleInit() {}

    async register(account: Account) {
        try {
            await this.accountModel.create(account);
            this.logger.warn(`Account ${account.credentials.username} has been added to the database`);
        } catch (error) {
            return Promise.reject(`Failed to add account --> ${error}`);
        }
    }
}
