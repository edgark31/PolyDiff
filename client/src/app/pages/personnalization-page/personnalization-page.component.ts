/* eslint-disable max-params */
/* eslint-disable max-len */
/* eslint-disable no-console */
/* eslint-disable @typescript-eslint/no-empty-function */
import { FormControl, FormGroup, Validators } from '@angular/forms';
/* eslint-disable @typescript-eslint/no-magic-numbers */
import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { ImportDialogComponent } from '@app/components/import-dialog-box/import-dialog-box.component';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { GameManagerService } from '@app/services/game-manager-service/game-manager.service';
import { SoundService } from '@app/services/sound-service/sound.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { TranslateService } from '@ngx-translate/core';

@Component({
    selector: 'app-personnalization-page',
    templateUrl: './personnalization-page.component.html',
    styleUrls: ['./personnalization-page.component.scss'],
})
export class PersonalizationPageComponent implements OnInit {
    @ViewChild(ImportDialogComponent) importDialogComponent: ImportDialogComponent;
    loginForm = new FormGroup({
        username: new FormControl('', [Validators.required, Validators.minLength(3), Validators.maxLength(15)]),
    });
    feedback: string;
    constructor(
        private readonly router: Router,
        public welcomeService: WelcomeService,
        public dialog: MatDialog,
        public gameManager: GameManagerService,
        public sound: SoundService,

        private translate: TranslateService,
        private clientSocket: ClientSocketService,
    ) {}

    ngOnInit() {
        this.welcomeService.selectName = this.gameManager.username;
        this.welcomeService.selectAvatar = this.welcomeService.account.profile.avatar;
        this.welcomeService.selectTheme = this.welcomeService.account.profile.desktopTheme;
        this.welcomeService.selectLanguage = this.welcomeService.account.profile.language;
        this.sound.correctSoundEffect = this.welcomeService.account.profile.onCorrectSound;
        this.sound.incorrectSoundEffect = this.welcomeService.account.profile.onErrorSound;
    }

    useLanguage(language: string): void {
        this.translate.use(language);
    }

    onSubmitHome() {
        this.clientSocket.disconnect('auth');
        this.router.navigate(['/login']);
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

    importDialog(choose: boolean): void {
        const dialogRef = this.dialog.open(ImportDialogComponent);
        dialogRef.afterClosed().subscribe(() => {});
        this.welcomeService.chooseImage = choose;
    }
}
