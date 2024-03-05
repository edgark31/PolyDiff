import { HttpErrorResponse } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Account } from '@common/game-interfaces';
import { CommunicationService } from '../communication-service/communication.service';
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
    constructor(private communicationservice: CommunicationService) {}

    async validate(password: string): Promise<boolean> {
        return new Promise((resolve, reject) => {
            this.communicationservice.recuperatePassword(password).subscribe({
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
}
