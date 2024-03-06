/* eslint-disable no-console */
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
    }

    onSubmitHome() {
        this.clientsocket.disconnect();
        this.router.navigate(['/login']);
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
        this.communication.updateAvatar(this.gameManager.username, this.welcomeService.selectAvatar).subscribe({
            next: () => {
                this.welcomeService.account.profile.avatar = this.welcomeService.selectAvatar;
            },
            error: (error: HttpErrorResponse) => {
                this.feedback = error.error || 'An unexpected error occurred. Please try again.';
            },
        });
    }

    onChooseAvatar() {
        this.communication.chooseAvatar(this.gameManager.username, this.welcomeService.selectLocal).subscribe({
            next: () => {
                this.welcomeService.account.profile.avatar = this.welcomeService.selectAvatar;
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
        this.communication.modifyTheme(this.gameManager.username, this.welcomeService.account.profile.theme, this.selectTheme).subscribe({
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
            next: () => {
                this.welcomeService.account.profile.language = this.selectLangage;
            },
            error: (error: HttpErrorResponse) => {
                this.feedback = error.error || 'An unexpected error occurred. Please try again.';
            },
        });
    }

    // onModifySongError() {
    //     this.communication.modifySongError(this.gameManager.username, this.welcomeService.account.profile.songError, this.selectSongError).subscribe({
    //         next: () => {
    //         },
    //         error: (error: HttpErrorResponse) => {
    //             this.feedback = error.error || 'An unexpected error occurred. Please try again.';
    //         },
    //     });
    // }

    // onModifySongDifference() {
    //     this.communication.modifySongDifference(this.gameManager.username, this.welcomeService.account.profile.songDifference, this.songDifference).subscribe({
    //         next: () => {
    //         },
    //         error: (error: HttpErrorResponse) => {
    //             this.feedback = error.error || 'An unexpected error occurred. Please try again.';
    //         },
    //     });
    // }

    onSubmitProfile() {
        console.log(this.gameManager.username);
        console.log(this.selectName);

        if (this.selectName !== this.gameManager.username) this.onModifyUser();
        if (!this.welcomeService.chooseImage && this.welcomeService.account.profile.avatar !== this.selectAvatar) this.onUpdateAvatar();
        if (this.welcomeService.chooseImage && this.welcomeService.account.profile.avatar !== this.welcomeService.selectLocal) this.onChooseAvatar();
        if (this.selectPassword !== this.welcomeService.account.credentials.password) this.onModifyPassword();
        if (this.selectTheme !== this.welcomeService.account.profile.theme) this.onModifyTheme();
        if (this.selectLangage !== this.welcomeService.account.profile.language) this.onModifyLangage();

        this.router.navigate(['/profil']);
    }

    importDialog(choose: boolean): void {
        const dialogRef = this.dialog.open(ImportDialogComponent);
        dialogRef.afterClosed().subscribe(() => {});
        this.welcomeService.chooseImage = choose;
    }
}
