/* eslint-disable import/no-unresolved */
import { Component } from '@angular/core';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { TranslateService } from '@ngx-translate/core';

@Component({
    selector: 'app-root',
    templateUrl: './app.component.html',
    styleUrls: ['./app.component.scss'],
})
export class AppComponent {
    constructor(private translate: TranslateService, public welcome: WelcomeService) {
        this.welcome.currentLangageTranslate.subscribe((language) => {
            this.translate.setDefaultLang(language);
            this.translate.use(language);
        });
        translate.setDefaultLang('en');
        translate.use('en');
    }

    changeLang(lang: string) {
        this.translate.use(lang);
    }
}
