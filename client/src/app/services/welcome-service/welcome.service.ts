import { HttpErrorResponse } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { LANGUAGES, THEME_PERSONNALIZATION } from '@common/constants';
import { Account, Theme } from '@common/game-interfaces';
import { CommunicationService } from '../communication-service/communication.service';
import { GameManagerService } from '../game-manager-service/game-manager.service';
@Injectable({
    providedIn: 'root',
})
export class WelcomeService {
    isLoggedIn = localStorage.getItem('isLoggedIn') === 'true';
    account: Account;
    selectLocal: string;
    selectAvatar: string = 'assets/default-avatar-profile-icon-social-600nw-1677509740.webp'; // A changer
    chooseImage: boolean;
    feedback: string;
    selectName: string;
    selectTheme: Theme;
    selectPassword: string;
    selectPasswordConfirm: string;
    isLinkValid = localStorage.getItem('linkValid') === 'true';
    selectLangage: string;
    langage = LANGUAGES;
    themePersonnalization = THEME_PERSONNALIZATION;
    constructor(private communication: CommunicationService, public gameManager: GameManagerService) {}

    async validate(password: string): Promise<boolean> {
        return new Promise((resolve, reject) => {
            this.communication.recuperatePassword(password).subscribe({
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

    onModifyLangage() {
        this.communication.modifyLangage(this.gameManager.username, this.selectLangage).subscribe({
            next: () => {
                this.account.profile.language = this.selectLangage;
            },
            error: (error: HttpErrorResponse) => {
                this.feedback = error.error || 'An unexpected error occurred. Please try again.';
            },
        });
    }

    getlinkValid(): boolean {
        return this.isLinkValid;
    }

    setlinkValid(value: boolean) {
        localStorage.setItem('linkValid', String(value));
        this.isLinkValid = value;
    }
}
