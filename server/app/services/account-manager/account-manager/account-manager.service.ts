/* eslint-disable @typescript-eslint/naming-convention */
import { Account, AccountDocument, Credentials, Statistics } from '@app/model/database/account';
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

    async register(creds: Credentials) {
        try {
            const userFound = await this.accountModel.findOne({
                'credentials.username': creds.username,
            });

            const emailFound = await this.accountModel.findOne({
                'credentials.email': creds.email,
            });

            if (userFound) {
                throw new Error('Username already taken');
            }
            if (emailFound) {
                throw new Error('Email already taken');
            } else {
                const newAccount: Account = {
                    credentials: creds,
                    profile: {
                        avatar: 'url',
                        sessions: [],
                        connexions: [],
                        stats: {} as Statistics,
                        friends: [],
                        friendRequests: [],
                    },
                };
                await this.accountModel.create(newAccount);
                this.logger.verbose(`Account ${creds.username} has registered successfully`);
            }
        } catch (error) {
            this.logger.error(`Failed to add account --> ${error.message}`);
            return Promise.reject(`Failed to add account --> ${error}`);
        }
    }

    async connexion(creds: Credentials): Promise<Account> {
        try {
            const accountFound = await this.accountModel.findOne({
                $or: [
                    { 'credentials.username': creds.username, 'credentials.password': creds.password },
                    { 'credentials.email': creds.username, 'credentials.password': creds.password },
                ],
            });

            if (accountFound) {
                if (!this.connectedProfiles.has(accountFound.credentials.username)) {
                    this.connectedProfiles.set(accountFound.credentials.username, accountFound.profile);
                    this.showProfiles();
                    return Promise.resolve(accountFound);
                } else {
                    throw new Error('Account already connected');
                }
            } else {
                throw new Error('Account not found');
            }
        } catch (error) {
            this.logger.error(`Failed to connect account --> ${error.message}`);
            return Promise.reject(`Failed to connect account --> ${error}`);
        }
    }

    deconnexion(name: string): void {
        this.connectedProfiles.delete(name);
        this.showProfiles();
    }

    showProfiles(): void {
        this.logger.verbose('Connected profiles: ');
        this.connectedProfiles.forEach((value, key) => {
            this.logger.verbose(`${key}`);
        });
    }
}
