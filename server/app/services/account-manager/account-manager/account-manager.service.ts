/* eslint-disable @typescript-eslint/naming-convention */
import { Account, AccountDocument } from '@app/model/database/account';
import { Profile } from '@common/game-interfaces';
import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';

@Injectable()
export class AccountManagerService implements OnModuleInit {
    connectedProfiles: Map<string, Profile> = new Map<string, Profile>();

    constructor(private readonly logger: Logger, @InjectModel(Account.name) private readonly accountModel: Model<AccountDocument>) {}

    onModuleInit() {
        // Put all the account.profile in the database in the connectedProfiles map
        this.accountModel.find().then((accounts) => {
            accounts.forEach((account) => {
                this.connectedProfiles.set(account.credentials.username, account.profile);
            });
            this.logger.warn(`Connected profiles: ${this.connectedProfiles}`);
        });
    }

    async register(account: Account) {
        try {
            await this.accountModel.create(account);
            this.logger.warn(`Account ${account.credentials.username} has been added to the database`);
        } catch (error) {
            return Promise.reject(`Failed to add account --> ${error}`);
        }
    }

    async connexion(account: Account): Promise<Profile> {
        try {
            const accountFound = await this.accountModel.findOne({
                'credentials.username': account.credentials.username,
                'credentials.password': account.credentials.password,
            });
            if (accountFound) {
                this.connectedProfiles.set(accountFound.credentials.username, accountFound.profile);
                this.logger.warn(`Account ${accountFound.credentials.username} has been connected`);
                this.logger.warn(`Connected profiles: ${this.connectedProfiles}`);
                return Promise.resolve(accountFound.profile);
            } else {
                return Promise.reject('Account not found');
            }
        } catch (error) {
            return Promise.reject(`Failed to connect account --> ${error}`);
        }
    }
}
