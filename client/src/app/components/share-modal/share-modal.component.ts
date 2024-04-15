/* eslint-disable max-len */
import { Component, Inject, OnDestroy, OnInit } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material/dialog';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { FriendService } from '@app/services/friend-service/friend.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { Account, Friend, Player } from '@common/game-interfaces';
import { TranslateService } from '@ngx-translate/core';
import { Subscription } from 'rxjs';

@Component({
    selector: 'app-share-modal',
    templateUrl: './share-modal.component.html',
    styleUrls: ['./share-modal.component.scss'],
})
export class ShareModalComponent implements OnInit, OnDestroy {
    // Services are needed for the dialog and dialog needs to talk to the parent component
    // eslint-disable-next-line max-params
    accountSubscription: Subscription;
    friends: Friend[];
    friendListSubscription: Subscription;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    intervalId: any;
    // eslint-disable-next-line max-params
    constructor(
        @Inject(MAT_DIALOG_DATA) public data: { showShareFriend: boolean; players: Player[] },
        public welcome: WelcomeService,
        public friendService: FriendService,
        public translate: TranslateService,
        private clientSocket: ClientSocketService,
    ) {}

    ngOnInit(): void {
        this.friendService.manageSocket();
        this.welcome.updateAccountObservable();
        this.accountSubscription = this.welcome.accountObservable$.subscribe((account: Account) => {
            this.welcome.account.profile.friends = account.profile.friends;
        });
        this.friendService.recuperateFriend();

        this.friendListSubscription = this.friendService.friendsSubject$.subscribe((friendList: Friend[]) => {
            this.friends = friendList.sort((a, b) => a.name.localeCompare(b.name));
        });

        this.intervalId = setInterval(() => {
            this.friendService.recuperateFriend();
            // eslint-disable-next-line @typescript-eslint/no-magic-numbers
        }, 10000);
    }

    ngOnDestroy(): void {
        if (this.clientSocket.isSocketAlive('auth')) {
            this.accountSubscription?.unsubscribe();
            this.friendListSubscription?.unsubscribe();
            this.friendService.off();
            clearInterval(this.intervalId);
        }
    }
    onShare(friendId: string): void {
        const playerAccount = this.data.players.find((player) => player.accountId === this.welcome.account.id);
        this.friendService.shareScore(friendId, playerAccount?.count ?? 0);
    }
}
