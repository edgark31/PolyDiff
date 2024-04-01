/* eslint-disable @angular-eslint/no-empty-lifecycle-method */
/* eslint-disable @typescript-eslint/no-magic-numbers */
import { Component, Inject, OnDestroy, OnInit } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { FriendService } from '@app/services/friend-service/friend.service';
import { Friend } from '@common/game-interfaces';
import { Subscription } from 'rxjs';

@Component({
    selector: 'app-friends-infos',
    templateUrl: './friends-infos.component.html',
    styleUrls: ['./friends-infos.component.scss'],
})
export class FriendsInfosComponent implements OnInit, OnDestroy {
    typeFriend: 'commonFriends' | 'allFriends' = 'allFriends';
    friendListSubscription: Subscription;
    // friends: Friend[] = [];
    friends: Friend[] = [
        // variable temporaire
        {
            name: 'ami',
            accountId: '',
            // friends: ["l'ami de mon ami"],
            // commonFriends: ['mon ami en commun'],
            isFavorite: true,
            isOnline: true,
        },

        {
            name: 'ami',
            accountId: '',
            // friends: ["l'ami de mon ami"],
            // commonFriends: ['mon ami en commun'],
            isFavorite: true,
            isOnline: true,
        },
        {
            name: 'ami',
            accountId: '',
            // friends: ["l'ami de mon ami"],
            // commonFriends: ['mon ami en commun'],
            isFavorite: true,
            isOnline: true,
        },
    ];
    // eslint-disable-next-line @typescript-eslint/no-useless-constructor, @typescript-eslint/no-empty-function
    constructor(
        @Inject(MAT_DIALOG_DATA) public data: { friend: Friend; showCommonFriend: boolean },
        public dialogRef: MatDialogRef<FriendsInfosComponent>,
        public friendService: FriendService,
    ) {}

    onTypeChange(type: 'commonFriends' | 'allFriends') {
        this.typeFriend = type;
        if (type === 'allFriends') {
            console.log('aie aie' + this.data.friend.friends);
            // this.friends = this.data.friend.friends ?? [];
            // en attendant de l'envoi des amis à partir de l'ami actuelle au serveur
        } else {
            // this.friends = this.data.friend.commonFriends ?? [];
            // en attendant de l'envoi des amis en commun du serveur
        }
    }
    ngOnInit(): void {
        this.friendService.manageSocket();

        // this.friendService.recuperateFriend();

        // this.friendListSubscription = this.friendService.friendsSubject$.subscribe((friendList: Friend[]) => {
        //     this.friends = friendList.sort((a, b) => (a.isFavorite === b.isFavorite ? 0 : a.isFavorite ? -1 : 1));
        // });
    }

    ngOnDestroy(): void {
        this.friendListSubscription?.unsubscribe();
    }
}
