import { ELEMENT_DATA, LANGAGE, THEME_PERSONNALIZATION } from '../../../../../common/constants';
/* eslint-disable @typescript-eslint/no-magic-numbers */
import { AfterViewInit, Component, ViewChild } from '@angular/core';
import { MatPaginator } from '@angular/material/paginator';
import { MatTableDataSource } from '@angular/material/table';
import { Router } from '@angular/router';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { GameManagerService } from '@app/services/game-manager-service/game-manager.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { ConnexionLog } from '@common/game-interfaces';
import { TranslateService } from '@ngx-translate/core';

@Component({
    selector: 'app-profil-page',
    templateUrl: './profil-page.component.html',
    styleUrls: ['./profil-page.component.scss'],
})
export class ProfilPageComponent implements AfterViewInit {
    selectedValue: string;
    langage = LANGAGE;
    showTable = false;
    themePersonnalization = THEME_PERSONNALIZATION;
    displayedColumns: string[] = ['position', 'name', 'weight'];
    dataSource = new MatTableDataSource<ConnexionLog>(ELEMENT_DATA);

    @ViewChild(MatPaginator) paginator: MatPaginator;

    constructor(
        private readonly router: Router,
        public welcomeService: WelcomeService,
        public gameManager: GameManagerService,
        private clientsocket: ClientSocketService,
        private translate: TranslateService,
    ) {}

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
        this.clientsocket.disconnect();
        this.router.navigate(['/login']);
    }

    onSubmitPersonnalization() {
        this.router.navigate(['/personalization']);
    }
}
