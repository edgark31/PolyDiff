/* eslint-disable import/no-unresolved */
import { Component } from '@angular/core';
import { TranslateService } from '@ngx-translate/core';

@Component({
    selector: 'app-root',
    templateUrl: './app.component.html',
    styleUrls: ['./app.component.scss'],
})
export class AppComponent {
    constructor(private translate: TranslateService) {
        translate.setDefaultLang('en');
        translate.use('en');
    }

    changeLang(lang: string) {
        this.translate.use(lang);
    }
}
