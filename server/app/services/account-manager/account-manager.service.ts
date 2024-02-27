/* eslint-disable @typescript-eslint/naming-convention */
import { Account, AccountDocument, Credentials, Statistics } from '@app/model/database/account';
import { ImageManagerService } from '@app/services/image-manager/image-manager.service';
import { Profile } from '@common/game-interfaces';
import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';

@Injectable()
export class AccountManagerService implements OnModuleInit {
    connectedUsers: Map<string, Profile> = new Map<string, Profile>(); // Key is the userName :: ALWAYS USE THIS MAP TO GET THE CONNECTED USERS

    constructor(
        private readonly logger: Logger,
        @InjectModel(Account.name) private readonly accountModel: Model<AccountDocument>,
        private readonly imageManager: ImageManagerService,
    ) {}

    onModuleInit() {
        //
    }

    async register(creds: Credentials) {
        try {
            const userFound = await this.accountModel.findOne({ 'credentials.username': creds.username });
            const emailFound = await this.accountModel.findOne({ 'credentials.email': creds.email });

            if (userFound) throw new Error('Username already taken');
            if (emailFound) throw new Error('Email already taken');

            const newAccount: Account = {
                credentials: creds,
                profile: {
                    avatar: this.imageManager.convert('default.png'),
                    sessions: [],
                    connexions: [],
                    stats: {} as Statistics,
                    friends: [],
                    friendRequests: [],
                },
            };
            await this.accountModel.create(newAccount);
            this.logger.verbose(`Account ${creds.username} has registered successfully`);
            return Promise.resolve();
        } catch (error) {
            this.logger.error(`Failed to add account --> ${error.message}`);
            return Promise.reject(`${error}`);
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

            if (!accountFound) throw new Error('Account not found');

            if (this.connectedUsers.has(accountFound.credentials.username)) throw new Error('Account already connected');

            this.imageManager.save(accountFound.credentials.username, accountFound.profile.avatar);
            this.connectedUsers.set(accountFound.credentials.username, accountFound.profile);
            this.showProfiles();
            return Promise.resolve(accountFound);
        } catch (error) {
            this.logger.error(`Failed to connect account --> ${error.message}`);
            return Promise.reject(`${error}`);
        }
    }

    async changePseudo(oldUsername: string, newUsername: string): Promise<void> {
        try {
            const accountFound = await this.accountModel.findOne({ 'credentials.username': oldUsername });
            const pseudoFound = await this.accountModel.findOne({ 'credentials.username': newUsername });

            if (!accountFound) throw new Error('Account not found');
            if (pseudoFound) throw new Error('Username already taken');

            accountFound.credentials.username = newUsername;
            await accountFound.save();
            this.logger.verbose(`Account ${oldUsername} has changed his username to ${newUsername}`);
            return Promise.resolve();
        } catch (error) {
            this.logger.error(`Failed to change pseudo --> ${error.message}`);
            return Promise.reject(`${error}`);
        }
    }

    async changeAvatar(username: string, avatar: string): Promise<void> {
        try {
            const accountFound = await this.accountModel.findOne({ 'credentials.username': username });
            if (!accountFound) throw new Error('Account not found');

            accountFound.profile.avatar = avatar;
            await accountFound.save();
            this.logger.verbose(`Account ${avatar} has changed his avatar to ${avatar}`);
            return Promise.resolve();
        } catch (error) {
            this.logger.error(`Failed to change avatar --> ${error.message}`);
            return Promise.reject(`${error}`);
        }
    }

    async delete() {
        try {
            await this.accountModel.deleteMany({});
            this.logger.verbose('All accounts have been deleted');
        } catch (error) {
            this.logger.error(`Failed to delete accounts --> ${error.message}`);
            return Promise.reject(`${error}`);
        }
    }

    deconnexion(userName: string): void {
        this.connectedUsers.delete(userName);
        this.showProfiles();
    }

    showProfiles(): void {
        this.logger.verbose('Connected profiles: ');
        this.connectedUsers.forEach((value, key) => {
            this.logger.verbose(`${key}`);
        });
    }
}
