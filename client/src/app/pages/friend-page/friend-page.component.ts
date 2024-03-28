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
            avatar: 'assets/default-avatar-profile-icon-social-600nw-1677509740.webp',
            friendNames: ["l'ami de mon ami"],
            commonFriendNames: ['mon ami en commun'],
            isFavorite: true,
            isOnline: true,
        },
    ];
    constructor() {}
    // eslint-disable-next-line max-params
}
