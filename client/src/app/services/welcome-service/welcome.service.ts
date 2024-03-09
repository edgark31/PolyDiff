import { HttpErrorResponse } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { LANGUAGES, THEME_PERSONNALIZATION } from '@common/constants';
import { Account, Theme } from '@common/game-interfaces';
// eslint-disable-next-line import/no-unresolved, no-restricted-imports
import { CommunicationService } from '../communication-service/communication.service';
// eslint-disable-next-line import/no-unresolved, no-restricted-imports
import { GameManagerService } from '../game-manager-service/game-manager.service';
@Injectable({
    providedIn: 'root',
})
export class WelcomeService {
    isLoggedIn = localStorage.getItem('isLoggedIn') === 'true';
    account: Account;
    selectLocal: string;
    selectAvatar: string = 'assets/default-avatar-profile-icon-social-600nw-1677509740.webp'; // A changer
    selectAvatarRegister: string = 'assets/default-avatar-profile-icon-social-600nw-1677509740.webp';
    chooseImage: boolean;
    feedback: string;
    selectName: string;
    selectTheme: Theme;
    selectPassword: string;
    selectPasswordConfirm: string;
    isLinkValid: boolean;
    selectLanguage: string;
    language = LANGUAGES;
    themePersonnalization = THEME_PERSONNALIZATION;
    constructor(private communication: CommunicationService, public gameManager: GameManagerService) {}

    async validate(password: string): Promise<boolean> {
        return new Promise((resolve, reject) => {
            this.communication.getPassword(password).subscribe({
                next: (success) => {
                    const response = success;
                    if (response) {
                        this.setLoginState(true);
                    }
                    resolve(response);
                },
                error: (error: HttpErrorResponse) => {
                    this.feedback = error.error || 'An unexpected error occurred';
                    reject(error);
                },
            });
        });
    }

    async validateAccess(password: string): Promise<boolean> {
        return new Promise((resolve, reject) => {
            this.communication.checkCode(password).subscribe({
                // A modifier
                next: (success) => {
                    const response = success;
                    resolve(response);
                },
                error: (error: HttpErrorResponse) => {
                    this.feedback = error.error || 'An unexpected error occurred';
                    reject(error);
                },
            });
        });
    }

    setLoginState(state: boolean): void {
        localStorage.setItem('isLoggedIn', String(state));
        this.isLoggedIn = state;
    }

    getLoginState(): boolean {
        return this.isLoggedIn;
    }

    onModifyUser() {
        this.communication.modifyUser(this.gameManager.username, this.selectName).subscribe({
            next: () => {
                this.gameManager.username = this.selectName;
            },
            error: (error: HttpErrorResponse) => {
                this.feedback = error.error || 'An unexpected error occurred. Please try again.';
            },
        });
    }

    onUpdateAvatar() {
        this.communication.updateAvatar(this.gameManager.username, this.selectAvatar).subscribe({
            next: () => {
                this.account.profile.avatar = this.selectAvatar;
            },
            error: (error: HttpErrorResponse) => {
                this.feedback = error.error || 'An unexpected error occurred. Please try again.';
            },
        });
    }

    onChooseAvatar() {
        this.communication.chooseAvatar(this.gameManager.username, this.selectLocal).subscribe({
            next: () => {
                this.account.profile.avatar = this.selectAvatar;
            },
            error: (error: HttpErrorResponse) => {
                this.feedback = error.error || 'An unexpected error occurred. Please try again.';
            },
        });
    }

    onModifyPassword() {
        this.communication.modifyPassword(this.gameManager.username, this.selectPassword).subscribe({
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            next: () => {},
            error: (error: HttpErrorResponse) => {
                this.feedback = error.error || 'An unexpected error occurred. Please try again.';
            },
        });
    }

    onModifyTheme() {
        this.communication.modifyTheme(this.gameManager.username, this.selectTheme).subscribe({
            next: () => {
                this.account.profile.theme = this.selectTheme;
            },
            error: (error: HttpErrorResponse) => {
                this.feedback = error.error || 'An unexpected error occurred. Please try again.';
            },
        });
    }

    onModifyLanguage() {
        this.communication.modifyLanguage(this.gameManager.username, this.selectLanguage).subscribe({
            next: () => {
                this.account.profile.language = this.selectLanguage;
            },
            error: (error: HttpErrorResponse) => {
                this.feedback = error.error || 'An unexpected error occurred. Please try again.';
            },
        });
    }

    // getlinkValid(name: string): boolean {
    //     this.isLinkValid = localStorage.getItem(name) === 'true';
    //     return this.isLinkValid;
    // }

    // setlinkValid(name: string, value: boolean) {
    //     localStorage.setItem(name, String(value));
    //     this.isLinkValid = value;
    // }
}
