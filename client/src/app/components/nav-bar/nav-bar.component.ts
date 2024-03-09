import { Component } from '@angular/core';

@Component({
    selector: 'app-nav-bar',
    templateUrl: './nav-bar.component.html',
    styleUrls: ['./nav-bar.component.scss'],
})
export class NavBarComponent {
    readonly configRoute: string;
    readonly homeRoute: string;
    readonly chatRoute: string;
    readonly profileRoute: string;
    readonly friendsRoute: string;

    constructor() {
        this.configRoute = '/admin';
        this.homeRoute = '/home';
        this.chatRoute = '/chat';
        this.profileRoute = '/profile';
    }
}
