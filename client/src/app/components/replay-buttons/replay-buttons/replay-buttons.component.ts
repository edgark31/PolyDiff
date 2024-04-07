/* eslint-disable @typescript-eslint/no-magic-numbers */
import { Component, Input, OnDestroy, OnInit } from '@angular/core';
import { MatSliderChange } from '@angular/material/slider';
import { WAITING_TIME } from '@app/constants/constants';
import { REPLAY_SPEEDS, SPEED_X1 } from '@app/constants/replay';
import { ReplayService } from '@app/services/replay-service/replay.service';
import { TranslateService } from '@ngx-translate/core';
import { Subject, Subscription } from 'rxjs';
@Component({
    selector: 'app-replay-buttons',
    templateUrl: './replay-buttons.component.html',
    styleUrls: ['./replay-buttons.component.scss'],
})
export class ReplayButtonsComponent implements OnInit, OnDestroy {
    @Input() isReplayAvailable: boolean;
    timer: number;
    isReplayButtonDisabled: boolean;
    isReplayPaused: boolean;
    replaySpeeds: number[];
    replaySpeed: number;
    replayTimerSubscription: Subscription;
    private onDestroy$: Subject<void>;
    constructor(private readonly replayService: ReplayService, public translate: TranslateService) {
        this.timer = 0;
        this.isReplayAvailable = false;
        this.isReplayPaused = false;
        this.replaySpeeds = REPLAY_SPEEDS;
        this.onDestroy$ = new Subject();
    }

    ngOnInit() {
        this.replayTimerSubscription = this.replayService.replayTimerSubject$.subscribe((replayTimer: number) => {
            this.timer = this.replayService.record.timeLimit - replayTimer;
            this.formatThumbLabel(this.timer);
        });
        this.replaySpeed = SPEED_X1;
    }

    getTimeLimit(): number {
        return Math.floor(this.replayService.record.duration / 1000);
    }

    setTimer(event: MatSliderChange): void {
        if (!this.isReplayButtonDisabled) {
            this.timer = event.value as number;
            this.replayService.fallBackReplay(this.timer);
            setTimeout(() => {
                this.isReplayButtonDisabled = false;
            }, WAITING_TIME);
        }
        this.isReplayButtonDisabled = true;
    }

    formatThumbLabel(value: number): string {
        return `${value}`;
    }

    replay(isMidReplay: boolean) {
        if (isMidReplay) {
            this.replayService.restartReplay();
        } else {
            this.replayService.startReplay();
        }
        this.replayService.restartTimer();
        this.isReplayPaused = false;
        this.isReplayButtonDisabled = true;
        setTimeout(() => {
            this.isReplayButtonDisabled = false;
        }, WAITING_TIME);
    }

    pause() {
        this.isReplayPaused = !this.isReplayPaused;
        this.replayService.pauseReplay();
    }

    resume() {
        this.isReplayPaused = !this.isReplayPaused;
        this.replayService.resumeReplay();
    }

    quit() {
        this.replayService.resetReplay();
    }

    isReplaying(): boolean {
        return this.replayService.isReplaying;
    }

    setSpeed(speed: number) {
        this.replayService.upSpeed(speed);
    }

    ngOnDestroy() {
        this.onDestroy$?.unsubscribe();
        this.replayService.resetReplay();
    }
}
