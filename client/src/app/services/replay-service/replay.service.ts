import { Injectable, OnDestroy } from '@angular/core';
import { REPLAY_LIMITER, SPEED_X1 } from '@app/constants/replay';
import { ReplayActions } from '@app/enum/replay-actions';
// import { ClickErrorData, ReplayEvent, ReplayPayload } from '@app/interfaces/replay-actions';
import { ReplayInterval } from '@app/interfaces/replay-interval';
import { GameAreaService } from '@app/services/game-area-service/game-area.service';
import { GameManagerService } from '@app/services/game-manager-service/game-manager.service';
import { ImageService } from '@app/services/image-service/image.service';
import { SoundService } from '@app/services/sound-service/sound.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { Coordinate, GameEventData, GameRecord, Player } from '@common/game-interfaces';
import { Subject, Subscription } from 'rxjs';

@Injectable({
    providedIn: 'root',
})
export class ReplayService implements OnDestroy {
    isReplaying: boolean;
    record: GameRecord;
    private replayEvents: GameEventData[];
    private replaySpeed: number;
    private currentCoords: Coordinate[];
    private isCheatMode: boolean;
    private isDifferenceFound: boolean;
    private replayInterval: ReplayInterval;
    private currentReplayIndex: number;
    private replayTimer: number;
    private nDifferencesFound: number;
    private replayTimerSubject: Subject<number>;
    private replayPlayerCount: Subject<Player>;
    private replayDifferenceFound: Subject<number>;
    private replayEventsSubjectSubscription: Subscription;

    // Replay needs to communicate with all services
    // eslint-disable-next-line max-params
    constructor(
        private readonly gameAreaService: GameAreaService,
        private readonly gameManager: GameManagerService,
        private readonly soundService: SoundService,
        private readonly imageService: ImageService,
        private readonly welcome: WelcomeService,
    ) {
        this.isReplaying = false;
        this.replayTimer = 0;
        this.replayEvents = [];
        this.replaySpeed = SPEED_X1;
        this.currentCoords = [];
        this.isCheatMode = false;
        this.isDifferenceFound = false;
        this.currentReplayIndex = 0;
        this.replayTimerSubject = new Subject<number>();
        this.replayPlayerCount = new Subject<Player>();
        this.replayDifferenceFound = new Subject<number>();
        this.nDifferencesFound = 0;
        this.record = {} as GameRecord;
        this.record.timeLimit = 0;
    }

    get nDifferencesFound$() {
        return this.nDifferencesFound;
    }

    get replayTimer$() {
        return this.replayTimer;
    }

    get replayTimerSubject$() {
        return this.replayTimerSubject.asObservable();
    }

    get replayPlayerCount$() {
        return this.replayPlayerCount.asObservable();
    }

    get replayDifferenceFound$() {
        return this.replayDifferenceFound.asObservable();
    }

    setReplay(record: GameRecord): void {
        this.record = record;
    }

    startReplay(): void {
        this.replayEvents = this.record.gameEvents;
        this.isReplaying = true;
        this.currentReplayIndex = 0;
        this.replayInterval = this.createReplayInterval(
            () => this.replaySwitcher(this.replayEvents[this.currentReplayIndex]),
            () => this.getNextInterval(),
        );
        this.replayInterval.start();
    }

    restartReplay(): void {
        this.currentReplayIndex = 0;
        this.replayInterval.resume();
    }

    pauseReplay(): void {
        this.toggleFlashing(true);
        this.replayInterval.pause();
    }

    resumeReplay(): void {
        this.toggleFlashing(false);
        this.replayInterval.resume();
    }

    upSpeed(speed: number): void {
        this.replaySpeed = speed;
        if (this.isCheatMode) {
            this.gameAreaService.toggleCheatMode(this.currentCoords, this.replaySpeed);
            this.gameAreaService.toggleCheatMode(this.currentCoords, this.replaySpeed);
        }
    }

    restartTimer(): void {
        this.replayTimer = 0;
        this.nDifferencesFound = 0;
        this.replayTimerSubject.next(0);
        for (const player of this.record.players) {
            player.count = 0;
            this.replayPlayerCount.next(player);
        }
        this.replayDifferenceFound.next(this.nDifferencesFound);
    }

    resetReplay(): void {
        this.replaySpeed = SPEED_X1;
        this.replayEvents = [];
        this.currentReplayIndex = 0;
        this.isReplaying = false;
    }

    ngOnDestroy(): void {
        this.replayEventsSubjectSubscription?.unsubscribe();
    }

    private toggleFlashing(isPaused: boolean): void {
        if (this.isCheatMode) {
            this.gameAreaService.toggleCheatMode(this.currentCoords, this.replaySpeed);
        }
        if (this.isDifferenceFound) {
            this.gameAreaService.flashPixels(this.currentCoords, this.replaySpeed, isPaused);
        }
    }

    private replaySwitcher(replayData: GameEventData): void {
        switch (replayData.gameEvent) {
            case ReplayActions.StartGame:
                this.replayGameStart();
                break;
            case ReplayActions.Found:
                this.replayClickFound(replayData);
                break;
            case ReplayActions.NotFound:
                this.replayClickError(replayData);
                break;
            case ReplayActions.CheatActivated:
                this.replayActivateCheat(replayData);
                break;
            case ReplayActions.CheatDeactivated:
                this.replayDeactivateCheat(replayData);
                break;
            case ReplayActions.TimerUpdate:
                this.replayTimerUpdate(replayData);
                break;
        }
        this.currentReplayIndex++;
    }

    private createReplayInterval(callback: () => void, getNextInterval: () => number): ReplayInterval {
        let timeoutId: ReturnType<typeof setTimeout> | null = null;
        let remainingTime: number;
        let startTime: number;

        const start = (delay: number = 0) => {
            if (this.currentReplayIndex < this.replayEvents.length) {
                startTime = Date.now();
                remainingTime = !delay ? getNextInterval() : delay;

                if (!delay) {
                    callback();
                }

                timeoutId = setTimeout(() => {
                    start();
                }, remainingTime);
            } else {
                this.cancelReplay();
            }
        };

        const pause = () => {
            if (timeoutId) {
                clearTimeout(timeoutId);
                remainingTime -= Date.now() - startTime;
                timeoutId = null;
            }
        };

        const resume = () => {
            if (!timeoutId) {
                start(remainingTime);
            }
        };

        const cancel = () => {
            if (timeoutId) {
                clearTimeout(timeoutId);
                timeoutId = null;
            }
            this.isReplaying = false;
        };

        return { start, pause, resume, cancel };
    }

    private cancelReplay(): void {
        this.replayInterval.cancel();
        this.currentReplayIndex = 0;
    }

    private getNextInterval(): number {
        const nextActionIndex = this.currentReplayIndex + 1;
        this.isDifferenceFound = false;
        let nextInterval = REPLAY_LIMITER;
        if (nextActionIndex < this.replayEvents.length) {
            const nextAction = this.replayEvents[nextActionIndex];
            const currentAction = this.replayEvents[this.currentReplayIndex];
            if (nextAction && currentAction) {
                nextInterval = ((nextAction.timestamp ?? 0) - (currentAction.timestamp ?? 0)) / this.replaySpeed;
            }
        }
        return nextInterval;
    }

    private replayGameStart(): void {
        this.gameManager.differences = this.record.game.differences as Coordinate[][];
        this.imageService.loadImage(this.gameAreaService.getOriginalContext(), this.record.game.original);
        this.imageService.loadImage(this.gameAreaService.getModifiedContext(), this.record.game.modified);
        this.gameAreaService.setAllData();
    }

    private replayClickFound(replayData: GameEventData): void {
        if (this.record.game.differences) {
            const currentIndex: number = this.record.game.differences.findIndex((difference) =>
                difference.some((coord: Coordinate) => coord.x === replayData.coordClic?.x && coord.y === replayData.coordClic?.y),
            );
            this.currentCoords = (this.record.game.differences as Coordinate[][])[currentIndex];
        }
        this.isDifferenceFound = true;
        this.soundService.playCorrectSoundDifference(this.welcome.account.profile.onCorrectSound);
        // if (replayData) {
        //     const commonMessage = `${replayData.username} a trouvé une différence !`;
        //     const commonChat: Chat = { raw: commonMessage, tag: MessageTag.Common };
        //     this.gameManager.setMessage(commonChat);
        // } snif snif mes messages zabi les gars
        if (replayData.players) {
            for (const player of replayData.players) {
                if (player.name === replayData.username) {
                    this.replayPlayerCount.next(player);
                    this.nDifferencesFound++;
                    this.replayDifferenceFound.next(this.nDifferencesFound);
                }
            }
        }
        this.gameAreaService.setAllData();
        this.gameAreaService.replaceDifference(this.currentCoords, '', this.replaySpeed);
    }

    private replayClickError(replayData: GameEventData): void {
        this.soundService.playIncorrectSound(this.welcome.account.profile.onErrorSound);
        // if (replayData) {
        //     const commonMessage = `${replayData.username} s'est trompé !`;
        //     const commonChat: Chat = { raw: commonMessage, tag: MessageTag.Common };
        //     this.gameManager.setMessage(commonChat);
        // } snif snif mes messages zabi les gars
        this.gameAreaService.showError(replayData.isMainCanvas as boolean, replayData.coordClic as Coordinate, this.replaySpeed);
    }

    private replayActivateCheat(replayData: GameEventData): void {
        this.isCheatMode = true;
        this.currentCoords = [];
        if (replayData.remainingDifferenceIndex) {
            this.currentCoords = this.currentCoords.concat(
                replayData.remainingDifferenceIndex.reduce((acc, index) => {
                    return acc.concat(this.record.game.differences?.[index] as Coordinate[]);
                }, [] as Coordinate[]),
            );
            this.gameAreaService.toggleCheatMode(this.currentCoords, this.replaySpeed);
        }
    }

    private replayDeactivateCheat(replayData: GameEventData): void {
        this.isCheatMode = false;
        this.currentCoords = [];
        if (replayData.remainingDifferenceIndex) {
            this.currentCoords = this.currentCoords.concat(
                replayData.remainingDifferenceIndex.reduce((acc, index) => {
                    return acc.concat(this.record.game.differences?.[index] as Coordinate[]);
                }, [] as Coordinate[]),
            );
            this.gameAreaService.toggleCheatMode(this.currentCoords, this.replaySpeed);
        }
    }

    private replayTimerUpdate(replayData: GameEventData): void {
        this.replayTimer = replayData.time as number;
        this.replayTimerSubject.next(this.replayTimer);
    }
}
