/* eslint-disable no-console */
/* eslint-disable @typescript-eslint/member-ordering */
/* eslint-disable @typescript-eslint/no-magic-numbers */
import { Component, DoCheck, OnDestroy, OnInit, ViewChild } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { MatPaginator } from '@angular/material/paginator';
import { AccountDialogComponent } from '@app/components/account-dialog/account-dialog.component';
import { FriendsInfosComponent } from '@app/components/friends-infos/friends-infos.component';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { FriendService } from '@app/services/friend-service/friend.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { Account, Friend, User } from '@common/game-interfaces';
import { TranslateService } from '@ngx-translate/core';
import { Subscription } from 'rxjs';

@Component({
    selector: 'app-friend-page',
    templateUrl: './friend-page.component.html',
    styleUrls: ['./friend-page.component.scss'],
})
export class FriendPageComponent implements OnInit, OnDestroy, DoCheck {
    @ViewChild(MatPaginator) paginator: MatPaginator;
    accountSubscription: Subscription;
    pageFriendupdate: string = 'friendUpdate';
    searchQuery: string = '';
    previousSearchQuery: string = '';
    friendSentList: Friend[] = [];
    friendPendingList: Friend[] = [];
    userList: User[] = [];
    isRequestPending: boolean = false;
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
    constructor(
        public clientSocket: ClientSocketService,
        private friendService: FriendService,
        public welcome: WelcomeService,
        private readonly matDialog: MatDialog,
        public translate: TranslateService,
        public dialog: MatDialog,
    ) {}
    // eslint-disable-next-line max-params
    onSubmit(pageFriend: string): void {
        this.pageFriendupdate = pageFriend;
        if (this.pageFriendupdate === 'friendWait') {
            this.friendService.recuperateFriendSend();
            this.friendService.recuperateFriendPending();
        } else this.friendService.recuperateFriend();
    }

    ngDoCheck(): void {
        if (this.previousSearchQuery !== this.searchQuery) {
            this.previousSearchQuery = this.searchQuery;
            this.friendService.sendSearch();
        }
    }

    ngOnInit(): void {
        this.friendService.manageSocket();
        this.welcome.updateAccountObservable();
        this.accountSubscription = this.welcome.accountObservable$.subscribe((account: Account) => {
            this.welcome.account = account;
        });
        this.friendService.recuperateFriendSend();
        this.friendService.recuperateFriend();
        this.friendService.recuperateFriendPending();
        this.userSubscription = this.friendService.userList$.subscribe((userList: User[]) => {
            if (this.searchQuery)
                this.userList = userList
                    .filter((user) => user.name.includes(this.searchQuery) && user.accountId !== this.welcome.account.id)
                    .sort((a, b) => a.name.localeCompare(b.name));
        });

        this.friendSendListSubscription = this.friendService.friendsSendSubject$.subscribe((friendList: Friend[]) => {
            this.friendSentList = friendList.sort((a, b) => a.name.localeCompare(b.name));
        });

        this.friendListSubscription = this.friendService.friendsSubject$.subscribe((friendList: Friend[]) => {
            this.friends = friendList.sort((a, b) => (a.isFavorite === b.isFavorite ? a.name.localeCompare(b.name) : a.isFavorite ? -1 : 1));
        });

        this.friendPendingListSubscription = this.friendService.friendsPendingSubject$.subscribe((friendList: Friend[]) => {
            this.friendPendingList = friendList.sort((a, b) => a.name.localeCompare(b.name));
        });
    }

    ngOnDestroy(): void {
        if (this.clientSocket.isSocketAlive('auth')) {
            this.accountSubscription?.unsubscribe();
            this.userSubscription?.unsubscribe();
            this.friendListSubscription?.unsubscribe();
            this.friendSendListSubscription?.unsubscribe();
            this.friendPendingListSubscription?.unsubscribe();
            // this.welcome.off();
            this.friendService.off();
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
        console.log('bbbbbbbbbbbbbbbbbbbbb' + friendFound?.accountId);
        return friendFound ? friendFound : ({} as Friend);
    }

    showFriendsOfFriends(friendOfFriend: Friend, showCommonFriend: boolean): void {
        console.log('aaaaaaaaaaaa' + friendOfFriend.accountId);
        this.matDialog.open(FriendsInfosComponent, {
            data: { friend: friendOfFriend, showCommonFriend, user: null },
        });
    }

    showFriendsOfUser(user: User, showCommonFriend: boolean): void {
        this.matDialog.open(FriendsInfosComponent, {
            data: { friend: null, showCommonFriend, user },
        });
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
        this.isRequestPending = true;
        setTimeout(() => {
            this.friendService.sendFriendRequest(accountId);
            this.isRequestPending = false;
            console.log('yoyoy' + accountId);
        }, 1000);
    }

    sendFriendPendingAccept(accountId: string): void {
        this.isRequestPending = true;
        setTimeout(() => {
            this.friendService.sendFriendPending(accountId, true);
            this.isRequestPending = false;
            console.log('yoyoy' + accountId);
        }, 3000);

        console.log('yoyoyo' + accountId);
    }

    sendFriendPendingRefuse(accountId: string): void {
        this.isRequestPending = true;
        setTimeout(() => {
            this.friendService.sendFriendPending(accountId, false);
            this.isRequestPending = false;
            console.log('yoyoy' + accountId);
        }, 3000);

        console.log('yoyoyooooooooooooooooooo' + accountId);
    }

    sendFriendDelete(accountId: string): void {
        console.log('delete' + accountId);
        this.dialog.open(AccountDialogComponent, {
            data: { mode: true, accountId },
            disableClose: true,
            panelClass: 'dialog',
        });

        // this.friendService.sendFriendDelete(accountId);
        // en attendant de régler l'erreur du double clique
    }

    sendFriendCancel(accountId: string): void {
        this.isRequestPending = true;
        setTimeout(() => {
            this.friendService.sendFriendCancel(accountId);
            this.isRequestPending = false;
            console.log('yoyoy' + accountId);
        }, 500);
    }
}
