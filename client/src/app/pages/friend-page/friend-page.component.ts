/* eslint-disable no-console */
/* eslint-disable @typescript-eslint/member-ordering */
/* eslint-disable @typescript-eslint/no-magic-numbers */
import { Component, OnDestroy, OnInit, ViewChild } from '@angular/core';
import { MatPaginator } from '@angular/material/paginator';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { FriendService } from '@app/services/friend-service/friend.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { Friend, User } from '@common/game-interfaces';
import { Subscription } from 'rxjs';

@Component({
    selector: 'app-friend-page',
    templateUrl: './friend-page.component.html',
    styleUrls: ['./friend-page.component.scss'],
})
export class FriendPageComponent implements OnInit, OnDestroy {
    @ViewChild(MatPaginator) paginator: MatPaginator;
    pageFriendupdate: string = 'friendUpdate';
    searchQuery: string = '';
    friendSentList: Friend[] = [];
    friendPendingList: Friend[] = [];
    userList: User[] = [];
    userSubscription: Subscription;
    friendListSubscription: Subscription;
    friendSendListSubscription: Subscription;
    friendPendingListSubscription: Subscription;

    friends: Friend[] = [];
    // [
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
    constructor(public clientSocket: ClientSocketService, private friendService: FriendService, private welcome: WelcomeService) {}
    // eslint-disable-next-line max-params
    onSubmit(pageFriend: string): void {
        this.pageFriendupdate = pageFriend;
        if (this.pageFriendupdate === 'friendCommon') {
            this.friendService.recuperateFriendSend();
        } else if (this.pageFriendupdate === 'friendPending') this.friendService.recuperateFriendPending();
        else this.friendService.recuperateFriend();
    }
    ngOnInit(): void {
        this.friendService.manageSocket();
        this.friendService.recuperateFriendSend();
        this.friendService.recuperateFriend();
        this.friendService.recuperateFriendPending();
        this.userSubscription = this.friendService.userList$.subscribe((userList: User[]) => {
            this.userList = userList.filter((user) => user.name.includes(this.searchQuery) && user.accountId !== this.welcome.account.id);
        });

        this.friendSendListSubscription = this.friendService.friendsSendSubject$.subscribe((friendList: Friend[]) => {
            this.friendSentList = friendList;
        });

        this.friendListSubscription = this.friendService.friendsSubject$.subscribe((friendList: Friend[]) => {
            this.friends = friendList.sort((a, b) => (a.isFavorite === b.isFavorite ? 0 : a.isFavorite ? -1 : 1));
        });

        this.friendPendingListSubscription = this.friendService.friendsPendingSubject$.subscribe((friendList: Friend[]) => {
            this.friendPendingList = friendList;
        });
    }

    ngOnDestroy(): void {
        if (this.clientSocket.isSocketAlive('auth')) {
            this.userSubscription?.unsubscribe();
            this.friendListSubscription?.unsubscribe();
            this.friendSendListSubscription?.unsubscribe();
            this.friendPendingListSubscription?.unsubscribe();
        }
    }

    stateUser(name: string): string {
        // return this.pageFriendupdate === 'friendUpdate' || this.pageFriendupdate === 'friendCommon' || this.pageFriendupdate === 'friendPending';
        if (this.friends.some((friend) => Object.values(friend).includes(name))) return 'friendUpdate';
        else if (this.friendSentList.some((friend) => Object.values(friend).includes(name))) return 'friendSentList';
        else if (this.friendPendingList.some((friend) => Object.values(friend).includes(name))) return 'friendPending';
        else return 'accountUser';
    }

    getFriendForUser(accountId: string): Friend {
        const friendFound = this.friends.find((friend) => friend.accountId === accountId);
        return friendFound ? friendFound : ({} as Friend);
    }

    sendSearch(): void {
        this.friendService.sendSearch();
    }

    sendFavoriteFriend(accountId: string): void {
        this.friendService.sendFavorite(accountId, true);
    }

    sendUnfavoriteFriend(accountId: string): void {
        this.friendService.sendFavorite(accountId, false);
    }
    sendFriendRequest(accountId: string): void {
        this.friendService.sendFriendRequest(accountId);
        console.log('yoyoy' + accountId);
    }

    sendFriendPendingAccept(accountId: string): void {
        this.friendService.sendFriendPending(accountId, true);
        console.log('yoyoyo' + accountId);
    }

    sendFriendPendingRefuse(accountId: string): void {
        this.friendService.sendFriendPending(accountId, false);
        console.log('yoyoyooooooooooooooooooo' + accountId);
    }

    sendFriendDelete(accountId: string): void {
        this.friendService.sendFriendDelete(accountId);
    }

    sendFriendCancel(accountId: string): void {
        this.friendService.sendFriendCancel(accountId);
    }
}
