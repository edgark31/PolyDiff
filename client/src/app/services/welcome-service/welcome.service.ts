import { HttpErrorResponse } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { CORRECT_SOUND_LIST, ERROR_SOUND_LIST, LANGUAGES, THEME_PERSONALIZATION } from '@common/constants';
import { Account, Theme } from '@common/game-interfaces';
// eslint-disable-next-line import/no-unresolved, no-restricted-imports
import { CommunicationService } from '../communication-service/communication.service';
// eslint-disable-next-line import/no-unresolved, no-restricted-imports
// eslint-disable-next-line no-restricted-imports
import { Subject } from 'rxjs';
import { SoundService } from '../sound-service/sound.service';
@Injectable({
    providedIn: 'root',
})
export class WelcomeService {
    onChatGame: boolean = false;
    onChatLobby: boolean = false;
    isLoggedIn = localStorage.getItem('isLogged') === 'true';
    songListDifference = CORRECT_SOUND_LIST;
    songListError = ERROR_SOUND_LIST;
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
    themePersonalization = THEME_PERSONALIZATION;
    currentLangageTranslate: Subject<string>;

    constructor(private communication: CommunicationService, private sound: SoundService) {
        this.currentLangageTranslate = new Subject<string>();
    }

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
    updateLangageTranslate() {
        this.currentLangageTranslate.next(this.account.profile.language);
    }
    setLoginState(state: boolean): void {
        localStorage.setItem('isLogged', String(state));
        this.isLoggedIn = state;
    }

    getLoginState(): boolean {
        return this.isLoggedIn;
    }

    onModifyUser() {
        this.communication.updateUsername(this.account.credentials.username, this.selectName).subscribe({
            next: () => {
                this.account.credentials.username = this.selectName;
            },
            error: (error: HttpErrorResponse) => {
                this.feedback = error.error || 'An unexpected error occurred. Please try again.';
            },
        });
    }

    onUpdateAvatar() {
        this.communication.updateAvatar(this.account.credentials.username, this.selectAvatar).subscribe({
            next: () => {
                this.account.profile.avatar = this.selectAvatar;
            },
            error: (error: HttpErrorResponse) => {
                this.feedback = error.error || 'An unexpected error occurred. Please try again.';
            },
        });
    }

    onChooseAvatar() {
        this.communication.chooseAvatar(this.account.credentials.username, this.selectLocal).subscribe({
            next: () => {
                this.account.profile.avatar = this.selectAvatar;
            },
            error: (error: HttpErrorResponse) => {
                this.feedback = error.error || 'An unexpected error occurred. Please try again.';
            },
        });
    }

    onModifyPassword() {
        this.communication.modifyPassword(this.account.credentials.username, this.selectPassword).subscribe({
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            next: () => {},
            error: (error: HttpErrorResponse) => {
                this.feedback = error.error || 'An unexpected error occurred. Please try again.';
            },
        });
    }

    onModifyTheme() {
        this.communication.modifyTheme(this.account.credentials.username, this.selectTheme).subscribe({
            next: () => {
                this.account.profile.desktopTheme = this.selectTheme;
            },
            error: (error: HttpErrorResponse) => {
                this.feedback = error.error || 'An unexpected error occurred. Please try again.';
            },
        });
    }

    onModifyLanguage() {
        this.communication.modifyLanguage(this.account.credentials.username, this.selectLanguage).subscribe({
            next: () => {
                this.account.profile.language = this.selectLanguage;
            },
            error: (error: HttpErrorResponse) => {
                this.feedback = error.error || 'An unexpected error occurred. Please try again.';
            },
        });
    }

    onUpdateCorrectSound() {
        this.communication.modifySongDifference(this.account.credentials.username, this.sound.correctSoundEffect).subscribe({
            next: () => {
                this.account.profile.onCorrectSound = this.sound.correctSoundEffect;
            },
            error: (error: HttpErrorResponse) => {
                this.feedback = error.error || 'An unexpected error occurred. Please try again.';
            },
        });
    }

    onUpdateErrorSound() {
        this.communication.modifySongError(this.account.credentials.username, this.sound.incorrectSoundEffect).subscribe({
            next: () => {
                this.account.profile.onErrorSound = this.sound.incorrectSoundEffect;
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
