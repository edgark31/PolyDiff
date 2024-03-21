/* eslint-disable no-console */
/* eslint-disable @typescript-eslint/member-ordering */
/* eslint-disable @typescript-eslint/no-magic-numbers */
import { AfterViewInit, Component, OnInit, ViewChild } from '@angular/core';
import { MatPaginator } from '@angular/material/paginator';
import { MatTableDataSource } from '@angular/material/table';
import { Router } from '@angular/router';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { GameManagerService } from '@app/services/game-manager-service/game-manager.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { ELEMENT_DATA, LANGUAGES, THEME_PERSONALIZATION } from '@common/constants';
import { ConnectionLog } from '@common/game-interfaces';
import { TranslateService } from '@ngx-translate/core';

@Component({
    selector: 'app-profil-page',
    templateUrl: './profil-page.component.html',
    styleUrls: ['./profil-page.component.scss'],
})
export class ProfilPageComponent implements AfterViewInit, OnInit {
    selectedValue: string;
    language = LANGUAGES;
    showTable = false;
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
    ) {}

    ngOnInit() {
        console.log(this.welcomeService.account);
    }

    ngAfterViewInit() {
        this.dataSource.paginator = this.paginator;
    }

    toggleTable() {
        this.showTable = !this.showTable;
    }
    translateCharacter(character: string): string {
        return this.translate.instant(`bouton.${character}`);
    }
    onSubmitHome() {
        this.clientSocket.disconnect('auth');
        this.router.navigate(['/login']);
    }

    onSubmitPersonalization() {
        this.router.navigate(['/personalization']);
    }
}
