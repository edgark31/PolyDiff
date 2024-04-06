/* eslint-disable import/no-unresolved */
import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { TranslateService } from '@ngx-translate/core';

@Component({
    selector: 'app-root',
    templateUrl: './app.component.html',
    styleUrls: ['./app.component.scss'],
})
export class AppComponent implements OnInit {
    constructor(private translate: TranslateService, public welcome: WelcomeService, private router: Router) {
        this.welcome.currentLangageTranslate.subscribe((language) => {
            this.translate.setDefaultLang(language);
            this.translate.use(language);
        });
    }

    ngOnInit() {
        this.router.navigate(['/login']);
    }

    changeLang(lang: string) {
        this.translate.use(lang);
    }
}
