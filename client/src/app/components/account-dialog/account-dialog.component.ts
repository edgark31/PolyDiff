import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { FriendService } from '@app/services/friend-service/friend.service';
import { GameManagerService } from '@app/services/game-manager-service/game-manager.service';
import { SoundService } from '@app/services/sound-service/sound.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
@Component({
    selector: 'app-account-dialog',
    templateUrl: './account-dialog.component.html',
    styleUrls: ['./account-dialog.component.scss'],
})
export class AccountDialogComponent {
    isReplayPaused: boolean;
    // eslint-disable-next-line max-params
    constructor(
        @Inject(MAT_DIALOG_DATA) public data: { mode: boolean; accountId: string },
        public welcomeService: WelcomeService,
        public gameManager: GameManagerService,
        public sound: SoundService,
        private router: Router,
        private friendService: FriendService,
    ) {
        this.isReplayPaused = false;
    }

    onSubmitProfile() {
        if (this.welcomeService.selectName !== this.gameManager.username) this.welcomeService.onModifyUser();
        if (!this.welcomeService.chooseImage && this.welcomeService.account.profile.avatar !== this.welcomeService.selectAvatar)
            this.welcomeService.onUpdateAvatar();
        if (this.welcomeService.chooseImage && this.welcomeService.account.profile.avatar !== this.welcomeService.selectLocal)
            this.welcomeService.onChooseAvatar();
        if (this.welcomeService.selectPassword !== this.welcomeService.account.credentials.password && this.welcomeService.selectPassword)
            this.welcomeService.onModifyPassword();
        if (this.welcomeService.selectTheme !== this.welcomeService.account.profile.desktopTheme) this.welcomeService.onModifyTheme();
        if (this.welcomeService.selectLanguage !== this.welcomeService.account.profile.language) this.welcomeService.onModifyLanguage();
        if (this.sound.correctSoundEffect !== this.welcomeService.account.profile.onCorrectSound) this.welcomeService.onUpdateCorrectSound();
        if (this.sound.incorrectSoundEffect !== this.welcomeService.account.profile.onErrorSound) this.welcomeService.onUpdateErrorSound();

        this.router.navigate(['/profil']);
    }

    onSubmitDeleteFriend() {
        this.friendService.sendFriendDelete(this.data.accountId);
    }
}
