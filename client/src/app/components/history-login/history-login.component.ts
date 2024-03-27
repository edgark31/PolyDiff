import { AfterViewInit, Component, OnInit, ViewChild } from '@angular/core';
import { MatDialogRef } from '@angular/material/dialog';
import { MatPaginator } from '@angular/material/paginator';
import { MatSort } from '@angular/material/sort';
import { MatTableDataSource } from '@angular/material/table';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { ConnectionLog, SessionLog } from '@common/game-interfaces';
import { ImportDialogComponent } from '../import-dialog-box/import-dialog-box.component';
@Component({
    selector: 'app-history-login',
    templateUrl: './history-login.component.html',
    styleUrls: ['./history-login.component.scss'],
})
export class HistoryLoginComponent implements AfterViewInit, OnInit {
    @ViewChild(MatPaginator) paginator: MatPaginator;
    @ViewChild(MatSort) sort: MatSort;
    paginatedConnection: ConnectionLog[] = [];
    displayedColumnsLogin: string[] = ['timestamp', 'connection'];
    displayedColumnsGame: string[] = ['timestamp', 'Session'];
    dataSourceLogin: MatTableDataSource<ConnectionLog>;
    dataSourceGame: MatTableDataSource<SessionLog>;
    constructor(public welcome: WelcomeService, private dialogRef: MatDialogRef<ImportDialogComponent>) {
        this.dataSourceLogin = new MatTableDataSource<ConnectionLog>(this.welcome.account.profile.connections);
        this.dataSourceGame = new MatTableDataSource<SessionLog>(this.welcome.account.profile.sessions);
    }

    ngAfterViewInit() {
        if (this.welcome.isHistoryLogin) this.dataSourceLogin.paginator = this.paginator;
        else this.dataSourceGame.paginator = this.paginator;
    }

    ngOnInit(): void {
        if (this.welcome.isHistoryLogin) {
            this.dataSourceLogin = new MatTableDataSource<ConnectionLog>(this.welcome.account.profile.connections);
            this.dataSourceLogin.paginator = this.paginator;
            // this.setupDataSource();
        } else {
            this.dataSourceGame = new MatTableDataSource<SessionLog>(this.welcome.account.profile.sessions);
            this.dataSourceGame.paginator = this.paginator;
            // this.setupDataSource();
        }
    }

    closeDialog() {
        this.dialogRef.close();
    }

    setupDataSource(): void {
        this.dataSourceLogin.paginator = this.paginator;
        this.dataSourceLogin.sort = this.sort;
        this.dataSourceLogin.sortingDataAccessor = (item, property: string) => {
            switch (property) {
                case 'timestamp':
                    return item.timestamp;
                case 'connection':
                    return item.isConnection;
                default:
                    return Object.values(item).find((value) => value[property]);
            }
        };
    }
}
