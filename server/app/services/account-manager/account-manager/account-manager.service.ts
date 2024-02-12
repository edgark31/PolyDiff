/* eslint-disable @typescript-eslint/naming-convention */
import { Account, AccountDocument, Credentials } from '@app/model/database/account';
import { Profile } from '@common/game-interfaces';
import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';

@Injectable()
export class AccountManagerService implements OnModuleInit {
    connectedProfiles: Map<string, Profile> = new Map<string, Profile>();

    constructor(private readonly logger: Logger, @InjectModel(Account.name) private readonly accountModel: Model<AccountDocument>) {}

    onModuleInit() {
        // this.accountModel.find().then((accounts) => {
        //     accounts.forEach((account) => {
        //         this.connectedProfiles.set(account.credentials.username, account.profile);
        //     });
        //     this.logger.warn(`Connected profiles: ${this.connectedProfiles}`);
        // });
    }

    async register(account: Account) {
        try {
            const accountFound = await this.accountModel.findOne({
                'credentials.username': account.credentials.username,
            });
            if (accountFound) {
                this.logger.error('Username already taken');
                throw new Error('Username already taken');
            } else {
                await this.accountModel.create(account);
                this.logger.warn(`Account ${account.credentials.username} has been added to the database`);
            }
        } catch (error) {
            return Promise.reject(`Failed to add account --> ${error}`);
        }
    }

    async connexion(creds: Credentials): Promise<Account> {
        try {
            const accountFound = await this.accountModel.findOne({
                'credentials.username': creds.username,
                'credentials.password': creds.password,
            });
            if (accountFound) {
                if (!this.connectedProfiles.has(accountFound.credentials.username)) {
                    this.connectedProfiles.set(accountFound.credentials.username, accountFound.profile);
                    this.showProfiles();
                    return Promise.resolve(accountFound);
                } else {
                    this.logger.warn('Account already connected');
                    throw new Error('Account already connected');
                }
            } else {
                this.logger.error('Account not found');
                throw new Error('Account not found');
            }
        } catch (error) {
            return Promise.reject(`Failed to connect account --> ${error}`);
        }
    }

    deconnexion(name: string): void {
        this.connectedProfiles.delete(name);
        this.showProfiles();
    }

    showProfiles(): void {
        this.logger.warn('Connected profiles: ');
        this.connectedProfiles.forEach((value, key) => {
            this.logger.warn(`${key}`);
        });
    }
}
