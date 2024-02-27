import { Injectable } from '@angular/core';
import { Account } from '@common/game-interfaces';
@Injectable({
    providedIn: 'root',
})
export class WelcomeService {
    account: Account;
    selectLocal: string;
    selectAvatar: string = 'assets/default-avatar-profile-icon-social-600nw-1677509740.webp'; // A changer
    chooseImage: boolean;
    constructor() {}
}
