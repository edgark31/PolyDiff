/* eslint-disable @typescript-eslint/no-empty-function */
import { FormControl, FormGroup, Validators } from '@angular/forms';
import { LANGUAGES, THEME_PERSONNALIZATION } from './../../../../../common/constants';
import { Theme } from './../../../../../common/game-interfaces';
/* eslint-disable @typescript-eslint/no-magic-numbers */
import { HttpErrorResponse } from '@angular/common/http';
import { Component, OnInit } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { ImportDialogComponent } from '@app/components/import-dialog/import-dialog.component';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { CommunicationService } from '@app/services/communication-service/communication.service';
import { GameManagerService } from '@app/services/game-manager-service/game-manager.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { marker } from '@biesbjerg/ngx-translate-extract-marker';
import { TranslateService } from '@ngx-translate/core';

@Component({
    selector: 'app-personnalization-page',
    templateUrl: './personnalization-page.component.html',
    styleUrls: ['./personnalization-page.component.scss'],
})
export class PersonnalizationPageComponent implements OnInit {
    selectName: string;
    selectAvatar: string;
    selectTheme: Theme;
    selectPassword: string;
    selectPasswordConfirm: string;
    selectLangage: string;
    langage = LANGUAGES;
    themePersonnalization = THEME_PERSONNALIZATION;
    loginForm = new FormGroup({
        username: new FormControl('', [Validators.required, Validators.minLength(3), Validators.maxLength(15)]),
    });
    messagebox = { t: 'warning' };
    messageBoxContent = marker(this.messagebox.t);

    feedback: string;
    constructor(
        private readonly router: Router,
        public welcomeService: WelcomeService,
        public dialog: MatDialog,
        public gameManager: GameManagerService,
        private readonly communication: CommunicationService,
        private translate: TranslateService,
        private clientsocket: ClientSocketService,
    ) {}

    ngOnInit() {
        this.selectName = this.gameManager.username;
        this.welcomeService.selectAvatar = this.welcomeService.account.profile.avatar;
        this.selectTheme = this.welcomeService.account.profile.theme;
        this.selectLangage = this.welcomeService.account.profile.language;
    }

    useLanguage(language: string): void {
        this.translate.use(language);
        // this.translate.setTranslation('en', {
        //     HELLO: 'hello {{value}}',
        // });
        // this.translate.setTranslation('en', { welcome: 'Hello, world!' });
    }

    onSubmitHome() {
        this.clientsocket.disconnect();
        this.router.navigate(['/login']);
    }

    onModifyUser() {
        this.communication.modifyUser(this.gameManager.username, this.selectName).subscribe({
            // discuter du fait d'envoyer tout le account
            next: () => {
                this.gameManager.username = this.selectName;
            },
            error: (error: HttpErrorResponse) => {
                this.feedback = error.error || 'An unexpected error occurred. Please try again.';
            },
        });
    }

    onUpdateAvatar() {
        this.communication.updateAvatar(this.gameManager.username, this.welcomeService.selectAvatar).subscribe({
            // discuter du fait d'envoyer tout le account
            next: () => {
                this.router.navigate(['/profil']);

                this.welcomeService.account.profile.avatar = this.welcomeService.selectAvatar;
            },
            error: (error: HttpErrorResponse) => {
                this.feedback = error.error || 'An unexpected error occurred. Please try again.';
            },
        });
    }

    onChooseAvatar() {
        this.communication.chooseAvatar(this.gameManager.username, this.welcomeService.selectLocal).subscribe({
            // discuter du fait d'envoyer tout le account
            next: () => {
                this.welcomeService.account.profile.avatar = this.welcomeService.selectAvatar;
            },
            error: (error: HttpErrorResponse) => {
                this.feedback = error.error || 'An unexpected error occurred. Please try again.';
            },
        });
    }

    onModifyPassword() {
        this.communication
            .modifyPassword(this.gameManager.username, this.welcomeService.account.credentials.password, this.selectPassword)
            .subscribe({
                // discuter du fait d'envoyer tout le account
                next: () => {
                    this.welcomeService.account.credentials.password = this.selectPassword;
                },
                error: (error: HttpErrorResponse) => {
                    this.feedback = error.error || 'An unexpected error occurred. Please try again.';
                },
            });
    }

    onModifyTheme() {
        this.communication.modifyTheme(this.gameManager.username, this.welcomeService.account.profile.theme, this.selectTheme).subscribe({
            // discuter du fait d'envoyer tout le account
            next: () => {
                this.welcomeService.account.profile.theme = this.selectTheme;
            },
            error: (error: HttpErrorResponse) => {
                this.feedback = error.error || 'An unexpected error occurred. Please try again.';
            },
        });
    }

    onModifyLangage() {
        this.communication.modifyLangage(this.gameManager.username, this.welcomeService.account.profile.language, this.selectLangage).subscribe({
            // discuter du fait d'envoyer tout le account
            next: () => {
                this.welcomeService.account.profile.language = this.selectLangage;
            },
            error: (error: HttpErrorResponse) => {
                this.feedback = error.error || 'An unexpected error occurred. Please try again.';
            },
        });
    }

    onSubmitProfile() {
        console.log(this.gameManager.username);
        console.log(this.selectName);

        if (this.selectName !== this.gameManager.username) this.onModifyUser();
        if (!this.welcomeService.chooseImage && this.welcomeService.account.profile.avatar !== this.selectAvatar) this.onUpdateAvatar();
        if (this.welcomeService.chooseImage && this.welcomeService.account.profile.avatar !== this.welcomeService.selectLocal) this.onChooseAvatar();
        if (this.selectPassword !== this.welcomeService.account.credentials.password) this.onModifyPassword();
        if (this.selectTheme !== this.welcomeService.account.profile.theme) this.onModifyTheme();
        if (this.selectLangage !== this.welcomeService.account.profile.language) this.onModifyLangage();
        console.log(this.welcomeService.account.profile.avatar + '      yyyyyyyyyyyyppppppppp');

        this.router.navigate(['/profil']);

        // this.oldProfile = {
        //     avatar: this.welcomeService.account.profile.avatar,
        //     name: this.gameManager.username,
        //     theme: this.welcomeService.account.profile.theme,
        //     language: this.welcomeService.account.profile.langage,
        //     password: this.welcomeService.account.credentials.password,
        // };

        // this.modifyProfile = {
        //     avatar: this.welcomeService.selectAvatar,
        //     name: this.selectName,
        //     theme: this.selectTheme,
        //     language: this.selectLangage,
        //     password: this.selectPassword,
        // };
        // this.communication.modifyProfile(this.oldProfile, this.modifyProfile).subscribe({
        //     // discuter du fait d'envoyer tout le account
        //     next: () => {
        //         this.router.navigate(['/profil']);
        //         this.gameManager.username = this.selectName;
        //         this.welcomeService.account.profile.avatar = this.welcomeService.selectAvatar;
        //         this.welcomeService.account.credentials.password = this.selectPassword;
        //         this.welcomeService.account.profile.theme = this.selectTheme;
        //         this.welcomeService.account.profile.langage = this.selectLangage;
        //     },
        //     error: (error: HttpErrorResponse) => {
        //         this.feedback = error.error || 'An unexpected error occurred. Please try again.';
        //     },
        // });
    }

    importDialog(choose: boolean): void {
        const dialogRef = this.dialog.open(ImportDialogComponent);
        dialogRef.afterClosed().subscribe(() => {});
        this.welcomeService.chooseImage = choose;
    }
}
