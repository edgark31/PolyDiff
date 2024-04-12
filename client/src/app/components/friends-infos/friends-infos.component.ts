/* eslint-disable @angular-eslint/no-empty-lifecycle-method */
/* eslint-disable @typescript-eslint/no-magic-numbers */
import { Component, Inject, OnDestroy, OnInit } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { FriendService } from '@app/services/friend-service/friend.service';
import { Friend, User } from '@common/game-interfaces';
import { TranslateService } from '@ngx-translate/core';
import { Subscription } from 'rxjs';

@Component({
    selector: 'app-friends-infos',
    templateUrl: './friends-infos.component.html',
    styleUrls: ['./friends-infos.component.scss'],
})
export class FriendsInfosComponent implements OnInit, OnDestroy {
    typeFriend: 'commonFriends' | 'allFriends' = 'allFriends';
    friendListSubscription: Subscription;
    friendCommonSubscription: Subscription;
    friends: Friend[] = [];
    friendsCommon: Friend[] = [];
    actualfriends: Friend[] = [];
    // friends: Friend[] = [
    //     // variable temporaire
    //     {
    //         name: 'ami',
    //         accountId: '',
    //         // friends: ["l'ami de mon ami"],
    //         // commonFriends: ['mon ami en commun'],
    //         isFavorite: true,
    //         isOnline: true,
    //     },

    //     {
    //         name: 'ami',
    //         accountId: '',
    //         // friends: ["l'ami de mon ami"],
    //         // commonFriends: ['mon ami en commun'],
    //         isFavorite: true,
    //         isOnline: true,
    //     },
    //     {
    //         name: 'ami',
    //         accountId: '',
    //         // friends: ["l'ami de mon ami"],
    //         // commonFriends: ['mon ami en commun'],
    //         isFavorite: true,
    //         isOnline: true,
    //     },
    // ];
    // eslint-disable-next-line @typescript-eslint/no-useless-constructor, @typescript-eslint/no-empty-function
    // eslint-disable-next-line max-params
    constructor(
        @Inject(MAT_DIALOG_DATA) public data: { friend: Friend; showCommonFriend: boolean; user: User },
        public dialogRef: MatDialogRef<FriendsInfosComponent>,
        public friendService: FriendService,
        public translate: TranslateService,
    ) {}

    onTypeChange(type: 'commonFriends' | 'allFriends') {
        this.typeFriend = type;
        if (type === 'allFriends' && this.data.showCommonFriend) {
            this.friendService.recuperateFriendofFriends(this.data.friend.accountId);
        } else {
            this.friendService.recuperateCommonFriends(this.data.friend.accountId);
        }
    }
    ngOnInit(): void {
        this.friendService.recuperateFriendofFriends(this.data.friend.accountId);

        this.friendListSubscription = this.friendService.friendsoffriendsSubject$.subscribe((friendList: Friend[]) => {
            this.friends = friendList.sort((a, b) => (a.isFavorite === b.isFavorite ? 0 : a.isFavorite ? -1 : 1));
        });

        this.friendCommonSubscription = this.friendService.friendsCommonSubject$.subscribe((friendList: Friend[]) => {
            this.friendsCommon = friendList.sort((a, b) => (a.isFavorite === b.isFavorite ? 0 : a.isFavorite ? -1 : 1));
        });
    }

    ngOnDestroy(): void {
        this.friendListSubscription?.unsubscribe();
        this.friendCommonSubscription?.unsubscribe();
        // this.friendService?.off();
    }
}
