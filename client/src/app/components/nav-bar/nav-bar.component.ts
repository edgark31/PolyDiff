import { Component } from '@angular/core';

@Component({
    selector: 'app-nav-bar',
    templateUrl: './nav-bar.component.html',
    styleUrls: ['./nav-bar.component.scss'],
})
export class NavBarComponent {
    readonly selectionRoute: string;
    readonly configRoute: string;
    readonly homeRoute: string;
    readonly chatRoute: string;

    constructor() {
        this.selectionRoute = '/selection';
        this.configRoute = '/admin';
        this.homeRoute = '/home';
        this.chatRoute = '/chat';
    }
}
