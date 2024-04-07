/* eslint-disable no-console */
/* eslint-disable @typescript-eslint/member-ordering */
/* eslint-disable @typescript-eslint/no-magic-numbers */
import { AfterViewInit, Component, OnDestroy, ViewChild } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { MatPaginator } from '@angular/material/paginator';
import { MatTableDataSource } from '@angular/material/table';
import { Router } from '@angular/router';
import { HistoryLoginComponent } from '@app/components/history-login/history-login.component';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { GameManagerService } from '@app/services/game-manager-service/game-manager.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { ELEMENT_DATA, LANGUAGES, THEME_PERSONALIZATION } from '@common/constants';
import { ConnectionLog } from '@common/game-interfaces';
import { TranslateService } from '@ngx-translate/core';
import { Subscription } from 'rxjs';

@Component({
    selector: 'app-profil-page',
    templateUrl: './profil-page.component.html',
    styleUrls: ['./profil-page.component.scss'],
})
export class ProfilPageComponent implements AfterViewInit, OnDestroy {
    selectedValue: string;
    language = LANGUAGES;
    showTable = false;
    accountSubscription: Subscription;
    themePersonnalization = THEME_PERSONALIZATION;
    displayedColumns: string[] = ['position', 'name', 'weight'];
    dataSource = new MatTableDataSource<ConnectionLog>(ELEMENT_DATA);

    @ViewChild(MatPaginator) paginator: MatPaginator;

    // eslint-disable-next-line max-params
    constructor(
        private readonly router: Router,
        public welcomeService: WelcomeService,
        public gameManager: GameManagerService,
        private clientSocket: ClientSocketService,
        private translate: TranslateService,
        private readonly matDialog: MatDialog,
    ) {}

    // ngOnInit() {
    //     // this.welcomeService.updateAccountObservable();
    //     // this.accountSubscription = this.welcomeService.accountObservable$.subscribe((account: Account) => {
    //     //     this.welcomeService.account = account;
    //     // });
    //     // this.clientSocket.send('auth', AccountEvents.RefreshAccount);
    // }

    ngAfterViewInit() {
        this.dataSource.paginator = this.paginator;
    }

    ngOnDestroy() {
        this.accountSubscription?.unsubscribe();
        this.welcomeService.off();
    }

    toggleTableLogin() {
        this.welcomeService.isHistoryLogin = true;
        this.matDialog.open(HistoryLoginComponent);
    }

    toggleTableSession() {
        this.welcomeService.isHistoryLogin = false;
        this.matDialog.open(HistoryLoginComponent);
    }
    translateCharacter(character: string): string {
        return this.translate.instant(`button.${character}`);
    }
    onSubmitHome() {
        this.clientSocket.disconnect('auth');
        this.router.navigate(['/login']);
    }

    onSubmitPersonalization() {
        this.router.navigate(['/personalization']);
    }
}
