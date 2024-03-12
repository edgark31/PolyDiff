import { Component } from '@angular/core';
import { Router } from '@angular/router';

import { GameModes } from '@common/enums';
import { Chat, ClientSideGame, Player } from '@common/game-interfaces';

@Component({
    selector: 'app-joined-player',
    templateUrl: './joined-player.component.html',
    styleUrls: ['./joined-player.component.scss'],
})
export class JoinedPlayersComponent {
    countdown: number;
    refusedMessage: string;
    messages: Chat[];
    isReplayAvailable: boolean;
    gameMode: typeof GameModes;
    game: ClientSideGame;
    playerss: Player[];

    players: string[] = ['Joueur1', 'joueur2', 'joueur3', 'joueur4'];
    // eslint-disable-next-line max-params
    constructor(public router: Router) {} // private data: { gameId: string; player: string },

    // ngOnInit(): void {
    //     this.handleRefusedPlayer();
    //     this.handleAcceptedPlayer();
    //     this.handleGameCardDelete();
    //     this.handleCreateUndoCreation();
    // }

    // ngAfterViewInit(): void {
    //     this.globalChatService.manage();
    //     this.globalChatService.updateLog();
    //     this.globalChatService.message$.subscribe((message: Chat) => {
    //         this.receiveMessage(message);
    //     });
    // }
    // sendMessage(message: string): void {
    //     this.globalChatService.sendMessage(message);
    // }

    // receiveMessage(chat: Chat): void {
    //     this.messages.push(chat);
    // }

    // ngOnDestroy(): void {
    //     this.globalChatService.off();
    // }

    // // cancelJoining() {
    // //     this.roomManagerService.cancelJoining(this.data.gameId);
    // // }

    // ngOnDestroy(): void {
    //     this.countdownSubscription?.unsubscribe();
    //     this.acceptedPlayerSubscription?.unsubscribe();
    //     this.deletedGameIdSubscription?.unsubscribe();
    //     this.roomAvailabilitySubscription?.unsubscribe();
    // }

    // private handleRefusedPlayer() {
    //     this.roomManagerService.refusedPlayerId$.pipe(filter((playerId) => playerId === this.roomManagerService.getSocketId())).subscribe(() => {
    //         this.countDownBeforeClosing('Vous avez été refusé');
    //     });
    // }

    // private handleAcceptedPlayer() {
    //     this.acceptedPlayerSubscription = this.roomManagerService.isPlayerAccepted$.subscribe((isPlayerAccepted) => {
    //         if (isPlayerAccepted) {
    //             this.router.navigate(['/game']);
    //         }
    //     });
    // }

    // private countDownBeforeClosing(message: string) {
    //     this.countdown = COUNTDOWN_TIME;
    //     const countdown$ = interval(WAITING_TIME).pipe(takeWhile(() => this.countdown > 0));
    //     const countdownObserver = {
    //         next: () => {
    //             this.countdown--;
    //             this.refusedMessage = `${message}. Vous serez redirigé dans ${this.countdown} secondes`;
    //         },
    //         // eslint-disable-next-line @typescript-eslint/no-empty-function
    //         complete: () => {},
    //     };
    //     this.countdownSubscription = countdown$.subscribe(countdownObserver);
    // }

    // private handleGameCardDelete() {
    //     this.deletedGameIdSubscription = this.roomManagerService.deletedGameId$.subscribe(() => {
    //         this.countDownBeforeClosing('La fiche de jeu a été supprimée');
    //     });
    // }

    // private handleCreateUndoCreation() {
    //     this.roomAvailabilitySubscription = this.roomManagerService.oneVsOneRoomsAvailabilityByRoomId$
    //         .pipe(filter((roomAvailability) => roomAvailability.gameId === 'true'))
    //         // && !roomAvailability.isAvailableToJoin
    //         .subscribe(() => {
    //             this.countDownBeforeClosing('Vous avez été refusé');
    //         });
    // }
}
