import { AfterViewInit, Component, ViewChild } from '@angular/core';
import { MatPaginator } from '@angular/material/paginator';
import { MatTableDataSource } from '@angular/material/table';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { ConnectionLog } from '@common/game-interfaces';
@Component({
    selector: 'app-history-login',
    templateUrl: './history-login.component.html',
    styleUrls: ['./history-login.component.scss'],
})
export class HistoryLoginComponent implements AfterViewInit {
    displayedColumns: string[] = ['timestamp', 'connection'];
    dataSource = new MatTableDataSource<ConnectionLog>(this.welcome.account.profile.connections);
    constructor(public welcome: WelcomeService) {}
    @ViewChild(MatPaginator) paginator: MatPaginator;

    ngAfterViewInit() {
        this.dataSource.paginator = this.paginator;
    }
}
