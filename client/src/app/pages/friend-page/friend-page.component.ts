/* eslint-disable no-console */
/* eslint-disable @typescript-eslint/member-ordering */
/* eslint-disable @typescript-eslint/no-magic-numbers */
import { Component, ViewChild } from '@angular/core';
import { MatPaginator } from '@angular/material/paginator';
import { Friend } from '@common/game-interfaces';

@Component({
    selector: 'app-friend-page',
    templateUrl: './friend-page.component.html',
    styleUrls: ['./friend-page.component.scss'],
})
export class FriendPageComponent {
    @ViewChild(MatPaginator) paginator: MatPaginator;
    friends: Friend[] = [
        // variable temporaire
        {
            name: 'ami',
            accountId: '1',
            friends: [
                {
                    name: 'ami de mon ami',
                    accountId: '2',
                    friends: [
                        {
                            name: 'mon ami en commun',
                            accountId: '3',
                        },
                    ],
                },
            ],
            commonFriends: [
                {
                    name: 'mon ami en commun',
                    accountId: '3',
                },
            ],
            isFavorite: true,
            isOnline: true,
        },
    ];
    // eslint-disable-next-line @typescript-eslint/no-useless-constructor, @typescript-eslint/no-empty-function
    constructor() {}
    // eslint-disable-next-line max-params
}
