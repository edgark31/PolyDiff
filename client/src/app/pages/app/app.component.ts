/* eslint-disable import/no-unresolved */
import { Component, OnDestroy, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { ClientSocketService } from '@app/services/client-socket-service/client-socket.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { TranslateService } from '@ngx-translate/core';

@Component({
    selector: 'app-root',
    templateUrl: './app.component.html',
    styleUrls: ['./app.component.scss'],
})
export class AppComponent implements OnInit, OnDestroy {
    constructor(
        private translate: TranslateService,
        public welcome: WelcomeService,
        private router: Router,
        private clientSocketService: ClientSocketService,
    ) {
        this.welcome.currentLangageTranslate.subscribe((language) => {
            this.translate.setDefaultLang(language);
            this.translate.use(language);
        });
    }

    ngOnInit() {
        this.router.navigate(['/login']);
    }

    ngOnDestroy(): void {
        this.clientSocketService.disconnect('auth');
        this.clientSocketService.disconnect('lobby');
        this.clientSocketService.disconnect('game');
    }

    changeLang(lang: string) {
        this.translate.use(lang);
    }
}
