/* eslint-disable max-len */
import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material/dialog';
import { FriendService } from '@app/services/friend-service/friend.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { Player } from '@common/game-interfaces';

@Component({
    selector: 'app-share-modal',
    templateUrl: './share-modal.component.html',
    styleUrls: ['./share-modal.component.scss'],
})
export class ShareModalComponent {
    // Services are needed for the dialog and dialog needs to talk to the parent component
    // eslint-disable-next-line max-params
    constructor(
        @Inject(MAT_DIALOG_DATA) public data: { showShareFriend: boolean; players: Player[] },
        public welcome: WelcomeService,
        public friendService: FriendService,
    ) {}

    onShare(friendId: string): void {
        console.log('tu cliques');
        const playerAccount = this.data.players.find((player) => player.accountId === this.welcome.account.id);
        this.friendService.shareScore(friendId, playerAccount?.count ?? 0);
    }
}
