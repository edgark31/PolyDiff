/* eslint-disable max-len */
/* eslint-disable @angular-eslint/no-empty-lifecycle-method */
import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { CommunicationService } from '@app/services/communication-service/communication.service';
import { ReplayService } from '@app/services/replay-service/replay.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { GameRecord } from '@common/game-interfaces';

@Component({
    selector: 'app-replay-page',
    templateUrl: './replay-page.component.html',
    styleUrls: ['./replay-page.component.scss'],
})
export class ReplayPageComponent implements OnInit {
    records: GameRecord[];

    constructor(
        public welcomeService: WelcomeService,
        public communicationService: CommunicationService,
        public replayService: ReplayService,
        public router: Router,
    ) {
        this.records = [];
    }

    ngOnInit(): void {
        this.communicationService.findAllByAccountId(this.welcomeService.account.id as string).subscribe((records) => {
            this.records = records;
        });
    }

    playRecord(recordToPlay: GameRecord): void {
        this.replayService.setReplay(recordToPlay);
        this.router.navigate(['/game']);
        this.replayService.startReplay();
        this.replayService.restartTimer();
    }

    deleteRecord(recordToRemove: GameRecord): void {
        this.records = this.records.filter((record) => record !== recordToRemove);
        this.communicationService.deleteAccountId(recordToRemove.date.toString(), this.welcomeService.account.id as string).subscribe();
    }
}
