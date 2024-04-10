/* eslint-disable max-len */
/* eslint-disable @angular-eslint/no-empty-lifecycle-method */
import { Component, OnInit } from '@angular/core';
import { CommunicationService } from '@app/services/communication-service/communication.service';
import { WelcomeService } from '@app/services/welcome-service/welcome.service';
import { GameRecord } from '@common/game-interfaces';

@Component({
    selector: 'app-replay-page',
    templateUrl: './replay-page.component.html',
    styleUrls: ['./replay-page.component.scss'],
})
export class ReplayPageComponent implements OnInit {
    records: GameRecord[];

    // gameRecord1: GameRecord = {
    //     accountIds: ['acc123', 'acc456'],
    //     game: {
    //         lobbyId: 'lobby001',
    //         gameId: 'game001',
    //         name: 'Mystery Mansion',
    //         original: '',
    //         modified: '',
    //         difficulty: 'Medium',
    //         differences: [[{ x: 100, y: 200 }], [{ x: 150, y: 250 }]],
    //         nDifferences: 2,
    //         playedGameIds: ['game001'],
    //     },
    //     players: [
    //         { accountId: 'acc123', name: 'Detective', count: 2 },
    //         { accountId: 'acc456', name: 'Sleuth', count: 1 },
    //     ],
    //     date: new Date('2024-04-07T12:00:00Z'),
    //     startTime: 1650000000000,
    //     endTime: 1650000360000,
    //     duration: 360000,
    //     isCheatEnabled: false,
    //     timeLimit: 600,
    //     gameEvents: [
    //         {
    //             accountId: 'acc123',
    //             username: 'Detective',
    //             timestamp: 1650000180000,
    //             gameEvent: 'found_difference',
    //             coordClic: { x: 100, y: 200 },
    //             remainingDifferenceIndex: [1],
    //             isMainCanvas: true,
    //             time: 180,
    //         },
    //     ],
    // };

    constructor(public welcomeService: WelcomeService, public communication: CommunicationService) {
        // const gameRecordSpecial = JSON.parse(JSON.stringify(this.gameRecord1));
        // gameRecordSpecial.game.name = 'Special Game';
        this.records = [];
    }

    ngOnInit(): void {
        this.communication.findAllByAccountId(this.welcomeService.account.id as string).subscribe((records) => {
            this.records = records;
        });
    }

    deleteRecord(recordToRemove: GameRecord): void {
        this.records = this.records.filter((record) => record !== recordToRemove);
        this.communication.deleteAccountId(recordToRemove.date.toString(), this.welcomeService.account.id as string).subscribe();
    }
}
