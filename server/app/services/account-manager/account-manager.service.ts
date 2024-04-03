/* eslint-disable no-unused-expressions */
/* eslint-disable @typescript-eslint/no-unused-expressions */
/* eslint-disable @typescript-eslint/naming-convention */
/* eslint-disable max-params */
/* eslint-disable no-underscore-dangle */
/* eslint-disable max-lines */
import { Account, AccountDocument, Credentials, Sound, Theme } from '@app/model/database/account';
import { ImageManagerService } from '@app/services/image-manager/image-manager.service';
import { CORRECT_SOUND_LIST, ERROR_SOUND_LIST, THEME_PERSONALIZATION } from '@common/constants';
import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';

@Injectable()
export class AccountManagerService implements OnModuleInit {
    users: Map<string, Account> = new Map<string, Account>(); // Key is the id :: ALWAYS USE THIS TO GET - USERS
    connectedUsers: Map<string, Account> = new Map<string, Account>(); // Key is the id :: ALWAYS USE THIS TO GET - CONNECTED USERS

    constructor(
        private readonly logger: Logger,
        @InjectModel(Account.name) public accountModel: Model<AccountDocument>,
        private readonly imageManager: ImageManagerService,
    ) {}

    async onModuleInit() {
        await this.loadAllAvatars();
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
                    stats: {
                        gamesPlayed: 0,
                        gameWon: 0,
                        averageTime: 0,
                        averageDifferences: 0,
                    },
                    friends: [],
                    friendRequests: [],
                    language: 'en',
                    desktopTheme: THEME_PERSONALIZATION[0],
                    mobileTheme: 'light',
                    onCorrectSound: CORRECT_SOUND_LIST[0],
                    onErrorSound: ERROR_SOUND_LIST[0],
                },
            };
            this.imageManager.save(newAccount.id, newAccount.profile.avatar);
            this.imageManager.save(newAccount.credentials.username, newAccount.profile.avatar);
            await this.accountModel.create(newAccount);
            this.logger.verbose(`Account ${creds.username} has registered successfully`);
            this.fetchUsers();
            return Promise.resolve();
        } catch (error) {
            this.logger.error(`Failed to add account --> ${error.message}`);
            return Promise.reject(`${error}`);
        }
    }

    async connection(creds: Credentials): Promise<Account> {
        try {
            this.logger.log(`Received connection request from ${creds.username} has connected with password ${creds.password}`);
            const accountFound = await this.accountModel.findOne({
                $or: [
                    { 'credentials.username': creds.username, 'credentials.password': creds.password },
                    { 'credentials.email': creds.username, 'credentials.password': creds.password },
                ],
            });
            if (!accountFound) throw new Error('Account not found');

            accountFound.id = accountFound._id.toString();
            if (this.connectedUsers.has(accountFound.id)) throw new Error('Account already connected');

            await accountFound.save();
            this.connectedUsers.set(accountFound.id, accountFound);
            this.fetchUsers();
            this.logger.log(`${accountFound.credentials.username} has connected with password ${accountFound.credentials.password}`);
            this.showProfiles();
            return Promise.resolve(accountFound);
        } catch (error) {
            this.logger.error(`Failed to connect account --> ${error.message}`);
            return Promise.reject(`${error}`);
        }
    }

    async updateUsername(oldUsername: string, newUsername: string): Promise<void> {
        try {
            const accountFound = await this.accountModel.findOne({ 'credentials.username': oldUsername });
            const pseudoFound = await this.accountModel.findOne({ 'credentials.username': newUsername });
            if (!accountFound) throw new Error('Account not found');
            if (pseudoFound) throw new Error('Username already taken');

            accountFound.credentials.username = newUsername;

            await accountFound.save();
            this.connectedUsers.set(accountFound.id, accountFound);
            await this.fetchUsers();

            return Promise.resolve();
        } catch (error) {
            this.logger.error(`Failed to change pseudo --> ${error.message}`);
            return Promise.reject(`${error}`);
        }
    }

    async uploadAvatar(username: string, avatar: string): Promise<void> {
        try {
            const accountFound = await this.accountModel.findOne({ 'credentials.username': username });
            if (!accountFound) throw new Error('Account not found');

            accountFound.profile.avatar = avatar;

            this.imageManager.save(accountFound.id, accountFound.profile.avatar);
            this.imageManager.save(accountFound.credentials.username, accountFound.profile.avatar);

            await accountFound.save();
            this.logger.log(`${username} has uploaded his avatar`);
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
            accountFound.profile.avatar = base64;

            this.imageManager.save(accountFound.id, accountFound.profile.avatar);
            this.imageManager.save(accountFound.credentials.username, accountFound.profile.avatar);

            await accountFound.save();
            this.logger.log(`${username} has choose his avatar`);
            return Promise.resolve();
        } catch (error) {
            this.logger.error(`Failed to choose avatar --> ${error.message}`);
            return Promise.reject(`${error}`);
        }
    }

    async updatePassword(username: string, newPassword: string): Promise<void> {
        try {
            const accountFound = await this.accountModel.findOne({ 'credentials.username': username });
            if (!accountFound) throw new Error('Account not found');

            accountFound.credentials.password = newPassword;

            await accountFound.save();
            await this.fetchUsers();

            this.logger.verbose(`${username} has changed his password`);
            return Promise.resolve();
        } catch (error) {
            this.logger.error(`Failed to change pseudo --> ${error.message}`);
            return Promise.reject(`${error}`);
        }
    }

    async updateErrorSound(username: string, newSound: Sound): Promise<void> {
        try {
            const accountFound = await this.accountModel.findOne({ 'credentials.username': username });

            if (!accountFound) throw new Error('Account not found');
            accountFound.profile.onErrorSound = newSound;

            await accountFound.save();
            this.logger.verbose(`${username} has changed his error sound effect`);
            return Promise.resolve();
        } catch (error) {
            this.logger.error(`Failed to change sound --> ${error.message}`);
            return Promise.reject(`${error}`);
        }
    }

    async updateCorrectSound(username: string, newSound: Sound): Promise<void> {
        try {
            const accountFound = await this.accountModel.findOne({ 'credentials.username': username });
            if (!accountFound) throw new Error('Account not found');

            accountFound.profile.onCorrectSound = newSound;

            await accountFound.save();
            this.logger.verbose(`${username} has changed his difference sound effect`);
            return Promise.resolve();
        } catch (error) {
            this.logger.error(`Failed to change sound --> ${error.message}`);
            return Promise.reject(`${error}`);
        }
    }

    async updateDesktopTheme(username: string, newTheme: Theme): Promise<void> {
        try {
            const accountFound = await this.accountModel.findOne({ 'credentials.username': username });

            if (!accountFound) throw new Error('Account not found');

            accountFound.profile.desktopTheme = newTheme;

            await accountFound.save();
            this.logger.verbose('Desktop theme change');
            return Promise.resolve();
        } catch (error) {
            this.logger.error(`Failed to change desktop theme --> ${error.message}`);
            return Promise.reject(`${error}`);
        }
    }

    async updateMobileTheme(username: string, newTheme: string): Promise<void> {
        try {
            const accountFound = await this.accountModel.findOne({ 'credentials.username': username });

            if (!accountFound) throw new Error('Account not found');

            accountFound.profile.mobileTheme = newTheme;

            await accountFound.save();
            this.logger.verbose('Mobile Theme change');
            return Promise.resolve();
        } catch (error) {
            this.logger.error(`Failed to change mobile theme --> ${error.message}`);
            return Promise.reject(`${error}`);
        }
    }

    async modifyLanguage(username: string, newLanguage: string): Promise<void> {
        try {
            const accountFound = await this.accountModel.findOne({ 'credentials.username': username });

            if (!accountFound) throw new Error('Account not found');

            accountFound.profile.language = newLanguage;

            await accountFound.save();
            this.logger.verbose(`${username} has changed his theme`);
            return Promise.resolve();
        } catch (error) {
            this.logger.error(`Failed to change language --> ${error.message}`);
            return Promise.reject(`${error}`);
        }
    }

    async deleteAccount(creds: Credentials) {
        try {
            const accountFound = await this.accountModel.findOne({ 'credentials.username': creds.username });
            if (!accountFound) throw new Error('Account not found');

            if (!this.connectedUsers.delete(accountFound.id)) throw new Error('Account not connected');
            await this.accountModel.deleteOne({ 'credentials.username': creds.username });
            this.fetchUsers();
            this.logger.verbose(`Account ${creds.username} has been deleted`);
            return Promise.resolve();
        } catch (error) {
            this.logger.error(`Failed to delete account --> ${error.message}`);
            return Promise.reject(`${error}`);
        }
    }

    async deleteAccounts() {
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
                this.users.set(account._id.toString(), account);
                this.connectedUsers.get(account.id) ? this.connectedUsers.set(account.id, account) : null;
            });
        });
    }

    async connectionToAdmin(password: string): Promise<boolean> {
        try {
            if (password !== 'admin') throw new Error('Wrong password');
            return Promise.resolve(password === 'admin');
        } catch (error) {
            this.logger.error(`Failed to connect --> ${error.message}`);
            return Promise.reject(`${error}`);
        }
    }

    showProfiles(): void {
        this.logger.verbose('Connected profiles: ');
        this.connectedUsers.forEach((value, key) => {
            this.logger.verbose(`${key}`);
        });
    }

    disconnection(id: string): void {
        this.connectedUsers.delete(id);
        this.logger.log(`Account ${id} has been disconnected`);
        this.showProfiles();
    }

    async logConnection(id: string, isConnection: boolean): Promise<void> {
        const account = await this.accountModel.findOne({ id });
        if (account) {
            account.profile.connections.push({
                timestamp: new Date().toLocaleTimeString('en-US', {
                    timeZone: 'America/Toronto',
                    year: 'numeric',
                    month: 'long',
                    day: '2-digit',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit',
                }),
                isConnection,
            });
            account.save();
        }
    }

    async logSession(id: string, isWinner: boolean, timePlayed: number, count: number): Promise<void> {
        const account = await this.accountModel.findOne({ id });
        account.profile.sessions.push({
            timestamp: new Date().toLocaleTimeString('en-US', {
                timeZone: 'America/Toronto',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit',
            }),
            isWinner,
        });
        account.profile.stats.gamesPlayed++;
        account.profile.stats.gameWon += isWinner ? 1 : 0;
        account.profile.stats.averageTime =
            (account.profile.stats.averageTime * (account.profile.stats.gamesPlayed - 1) + timePlayed) / account.profile.stats.gamesPlayed;
        account.profile.stats.averageDifferences =
            (account.profile.stats.averageDifferences * (account.profile.stats.gamesPlayed - 1) + count) / account.profile.stats.gamesPlayed;
        account.save();
    }

    private async loadAllAvatars(): Promise<void> {
        await this.accountModel.find().then((accounts) => {
            accounts.forEach((account) => {
                this.imageManager.save(account._id, account.profile.avatar);
                this.imageManager.save(account.credentials.username, account.profile.avatar);
            });
        });
    }
}
