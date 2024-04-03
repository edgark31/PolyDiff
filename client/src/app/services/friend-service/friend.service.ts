import { Injectable } from '@angular/core';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { FriendEvents, UserEvents } from '@common/enums';
import { Friend, User } from '@common/game-interfaces';
import { Subject } from 'rxjs';

@Injectable({
    providedIn: 'root',
})
export class FriendService {
    private friendsSubject: Subject<Friend[]>;
    private friendsoffriendsSubject: Subject<Friend[]>;
    private friendsCommonSubject: Subject<Friend[]>;
    private friendsSendSubject: Subject<Friend[]>;
    private friendsPendingSubject: Subject<Friend[]>;
    private userList: Subject<User[]>;
    constructor(public clientSocket: ClientSocketService) {
        this.friendsSubject = new Subject<Friend[]>();
        this.friendsSendSubject = new Subject<Friend[]>();
        this.friendsPendingSubject = new Subject<Friend[]>();
        this.userList = new Subject<User[]>();
    }

    get friendsSubject$() {
        return this.friendsSubject.asObservable();
    }

    get friendsCommonSubject$() {
        return this.friendsCommonSubject.asObservable();
    }

    get friendsoffriendsSubject$() {
        return this.friendsoffriendsSubject.asObservable();
    }

    get friendsSendSubject$() {
        return this.friendsSendSubject.asObservable();
    }

    get friendsPendingSubject$() {
        return this.friendsPendingSubject.asObservable();
    }
    get userList$() {
        return this.userList.asObservable();
    }

    sendSearch(): void {
        this.clientSocket.send('auth', UserEvents.UpdateUsers);
    }

    recuperateFriend(): void {
        this.clientSocket.send('auth', FriendEvents.UpdateFriends);
    }
    recuperateFriendSend(): void {
        this.clientSocket.send('auth', FriendEvents.UpdateSentFriends);
    }

    recuperateFriendPending(): void {
        this.clientSocket.send('auth', FriendEvents.UpdatePendingFriends);
    }
    sendFriendRequest(accountId: string): void {
        this.clientSocket.send('auth', FriendEvents.SendRequest, { potentialFriendId: accountId });
    }

    sendFavorite(accountId: string, isFavorite: boolean): void {
        console.log('yooooooooooooooooooo' + accountId + isFavorite);
        this.clientSocket.send('auth', FriendEvents.OptFavorite, { friendId: accountId, isFavorite });
    }

    sendFriendPending(accountId: string, isOpt: boolean): void {
        console.log('yooooooooooooooooooo' + accountId);
        this.clientSocket.send('auth', FriendEvents.OptRequest, { senderFriendId: accountId, isOpt });
    }

    sendFriendCancel(accountId: string): void {
        this.clientSocket.send('auth', FriendEvents.CancelRequest, { potentialFriendId: accountId });
    }
    recuperateFriendofFriends(accountId: string): void {
        console.log(accountId);
        this.clientSocket.send('auth', FriendEvents.UpdateFoFs, { friendId: accountId });
    }

    recuperateCommonFriends(accountId: string): void {
        console.log(accountId);
        this.clientSocket.send('auth', FriendEvents.UpdateCommonFriends, { friendId: accountId });
    }

    sendFriendDelete(accountId: string): void {
        console.log('delete' + accountId);
        this.clientSocket.send('auth', FriendEvents.DeleteFriend, { friendId: accountId });
    }
    manageSocket(): void {
        this.friendsSubject = new Subject<Friend[]>();
        this.friendsSendSubject = new Subject<Friend[]>();
        this.friendsoffriendsSubject = new Subject<Friend[]>();
        this.friendsCommonSubject = new Subject<Friend[]>();
        this.friendsPendingSubject = new Subject<Friend[]>();
        this.userList = new Subject<User[]>();

        this.clientSocket.on('auth', FriendEvents.UpdateFriends, (friends: Friend[]) => {
            this.friendsSubject.next(friends);
        });

        this.clientSocket.on('auth', FriendEvents.UpdateFoFs, (friends: Friend[]) => {
            this.friendsoffriendsSubject.next(friends);
        });

        this.clientSocket.on('auth', FriendEvents.UpdateCommonFriends, (friends: Friend[]) => {
            this.friendsCommonSubject.next(friends);
        });

        this.clientSocket.on('auth', FriendEvents.UpdateSentFriends, (friends: Friend[]) => {
            console.log('allez' + friends.length);
            this.friendsSendSubject.next(friends);
        });

        this.clientSocket.on('auth', FriendEvents.UpdatePendingFriends, (friends: Friend[]) => {
            this.friendsPendingSubject.next(friends);
        });

        this.clientSocket.on('auth', UserEvents.UpdateUsers, (users: User[]) => {
            this.userList.next(users);
        });
    }

    off(): void {
        if (this.friendsSubject && !this.friendsSubject.closed) this.friendsSubject?.unsubscribe();
        if (this.friendsSendSubject && !this.friendsSendSubject.closed) this.friendsSendSubject?.unsubscribe();
        if (this.friendsPendingSubject && !this.friendsPendingSubject.closed) this.friendsPendingSubject?.unsubscribe();
        if (this.userList && !this.userList.closed) this.userList?.unsubscribe();
        if (this.friendsoffriendsSubject && !this.friendsoffriendsSubject.closed) this.friendsoffriendsSubject?.unsubscribe();
        if (this.friendsCommonSubject && !this.friendsCommonSubject.closed) this.friendsCommonSubject?.unsubscribe();
    }
}
