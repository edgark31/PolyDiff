/* eslint-disable no-console */
/* eslint-disable @typescript-eslint/member-ordering */
/* eslint-disable @typescript-eslint/no-magic-numbers */
import { Component, ViewChild } from '@angular/core';
import { MatPaginator } from '@angular/material/paginator';

@Component({
    selector: 'app-friend-page',
    templateUrl: './friend-page.component.html',
    styleUrls: ['./friend-page.component.scss'],
})
export class FriendPageComponent {
    @ViewChild(MatPaginator) paginator: MatPaginator;

    // eslint-disable-next-line max-params
}
