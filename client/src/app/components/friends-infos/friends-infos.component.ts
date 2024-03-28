/* eslint-disable @angular-eslint/no-empty-lifecycle-method */
/* eslint-disable @typescript-eslint/no-magic-numbers */
import { Component, Input } from '@angular/core';
import { Friend } from '@common/game-interfaces';

@Component({
    selector: 'app-friends-infos',
    templateUrl: './friends-infos.component.html',
    styleUrls: ['./friends-infos.component.scss'],
})
export class FriendsInfosComponent {
    @Input() friend: Friend;

    constructor() {}
}
