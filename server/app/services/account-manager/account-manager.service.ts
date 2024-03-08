import { Song, Theme } from './../../model/database/account';
/* eslint-disable @typescript-eslint/naming-convention */
import { Account, AccountDocument, Credentials, Statistics } from '@app/model/database/account';
import { ImageManagerService } from '@app/services/image-manager/image-manager.service';
import { SONG_LIST_DIFFERENCE, SONG_LIST_ERROR, THEME_PERSONNALIZATION } from '@common/constants';
import { Profile } from '@common/game-interfaces';
import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';

@Injectable()
export class AccountManagerService implements OnModuleInit {
    users: Map<string, Account> = new Map<string, Account>();
    connectedUsers: Map<string, Profile> = new Map<string, Profile>(); // Key is the userName :: ALWAYS USE THIS MAP TO GET THE CONNECTED USERS
    password: string = 'y';
    constructor(
        private readonly logger: Logger,
        @InjectModel(Account.name) private readonly accountModel: Model<AccountDocument>,
        private readonly imageManager: ImageManagerService,
    ) {}

    onModuleInit() {
        this.fetchUsers();
    }

    async register(creds: Credentials, id: string) {
        try {
            const userFound = await this.accountModel.findOne({ 'credentials.username': creds.username });
            const emailFound = await this.accountModel.findOne({ 'credentials.email': creds.email });

            if (userFound) throw new Error('Username already taken');
            if (emailFound) throw new Error('Email already taken');

            const newAccount: Account = {
                credentials: creds,
                profile: {
                    avatar: this.imageManager.convert(`default${id}.png`),
                    sessions: [],
                    connections: [],
                    stats: {} as Statistics,
                    friends: [],
                    friendRequests: [],
                    language: 'en',
                    theme: THEME_PERSONNALIZATION[0],
                    songDifference: SONG_LIST_DIFFERENCE[0],
                    songError: SONG_LIST_ERROR[0],
                },
            };
            await this.accountModel.create(newAccount);
            this.logger.verbose(`Account ${creds.username} has registered successfully`);
            await this.fetchUsers();
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

    async changePassword(oldUsername: string, newPasword: string): Promise<void> {
        try {
            const accountFound = await this.accountModel.findOne({ 'credentials.username': oldUsername });
            if (!accountFound) throw new Error('Account not found');

            accountFound.credentials.password = newPasword;

            await accountFound.save();
            this.logger.verbose('Password change');
            return Promise.resolve();
        } catch (error) {
            this.logger.error(`Failed to change pseudo --> ${error.message}`);
            return Promise.reject(`${error}`);
        }
    }

    async modifyTheme(oldUsername: string, newTheme: Theme): Promise<void> {
        try {
            const accountFound = await this.accountModel.findOne({ 'credentials.username': oldUsername });

            if (!accountFound) throw new Error('Account not found');

            accountFound.profile.theme = newTheme;

            await accountFound.save();
            this.logger.verbose('Theme change');
            return Promise.resolve();
        } catch (error) {
            this.logger.error(`Failed to change theme --> ${error.message}`);
            return Promise.reject(`${error}`);
        }
    }

    async modifyLanguage(oldUsername: string, newLanguage: string): Promise<void> {
        try {
            const accountFound = await this.accountModel.findOne({ 'credentials.username': oldUsername });

            if (!accountFound) throw new Error('Account not found');

            accountFound.profile.language = newLanguage;

            await accountFound.save();
            this.logger.verbose('language change');
            return Promise.resolve();
        } catch (error) {
            this.logger.error(`Failed to change language --> ${error.message}`);
            return Promise.reject(`${error}`);
        }
    }

    async modifySongError(oldUsername: string, newSong: Song): Promise<void> {
        try {
            const accountFound = await this.accountModel.findOne({ 'credentials.username': oldUsername });

            if (!accountFound) throw new Error('Account not found');
            console.log(newSong);
            accountFound.profile.songDifference = newSong;

            await accountFound.save();
            this.logger.verbose('language change');
            return Promise.resolve();
        } catch (error) {
            this.logger.error(`Failed to change language --> ${error.message}`);
            return Promise.reject(`${error}`);
        }
    }

    async modifySongDifference(oldUsername: string, newSong: Song): Promise<void> {
        try {
            const accountFound = await this.accountModel.findOne({ 'credentials.username': oldUsername });

            if (!accountFound) throw new Error('Account not found');

            accountFound.profile.songError = newSong;

            await accountFound.save();
            this.logger.verbose('language change');
            return Promise.resolve();
        } catch (error) {
            this.logger.error(`Failed to change language --> ${error.message}`);
            return Promise.reject(`${error}`);
        }
    }

    async uploadAvatar(username: string, avatar: string): Promise<void> {
        try {
            const accountFound = await this.accountModel.findOne({ 'credentials.username': username });
            if (!accountFound) throw new Error('Account not found');

            this.imageManager.save(username, avatar);
            accountFound.profile.avatar = avatar;

            await accountFound.save();
            this.logger.log(`${username} has changed his avatar`);
            return Promise.resolve();
        } catch (error) {
            this.logger.error(`Failed to upload avatar --> ${error.message}`);
            return Promise.reject(`${error}`);
        }
    }

    async chooseAvatar(username: string, id: string): Promise<void> {
        try {
            const accountFound = await this.accountModel.findOne({ 'credentials.username': username });
            if (!accountFound) throw new Error('Account not found');

            const base64 = this.imageManager.convert(`default${id}.png`);
            this.imageManager.save(username, base64);

            accountFound.profile.avatar = base64;
            await accountFound.save();
            this.logger.log(`${username} has changed his avatar`);
            return Promise.resolve();
        } catch (error) {
            this.logger.error(`Failed to choose avatar --> ${error.message}`);
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

    async fetchUsers() {
        await this.accountModel.find().then((accounts) => {
            accounts.forEach((account) => {
                this.users.set(account.credentials.username, account);
            });
        });
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

    // async connexionToAdmin(password: string): Promise<boolean> {
    //     try {
    //         console.log(password + 'qdsdss');
    //         if (password !== 'admin') throw new Error('Wrong password');
    //         return Promise.resolve(password === 'admin');
    //     } catch (error) {
    //         this.logger.error(`Failed to connect --> ${error.message}`);
    //         return Promise.reject(`${error}`);
    //     }
    // }

    connexionToAdmin(password: string): boolean {
        return password === 'admin';
    }
}

//
