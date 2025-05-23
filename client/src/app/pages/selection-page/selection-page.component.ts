import { AfterViewInit, Component, OnDestroy } from '@angular/core';
import { Router } from '@angular/router';
import { CommunicationService } from '@app/services/communication-service/communication.service';
import { RoomManagerService } from '@app/services/room-manager-service/room-manager.service';
import { CarouselPaginator } from '@common/game-interfaces';
import { Subscription } from 'rxjs';

@Component({
    selector: 'app-selection-page',
    templateUrl: './selection-page.component.html',
    styleUrls: ['./selection-page.component.scss'],
})
export class SelectionPageComponent implements AfterViewInit, OnDestroy {
    gameCarrousel: CarouselPaginator;
    homeRoute: string;
    configRoute: string;
    private index: number;
    private reloadSubscription: Subscription;
    constructor(
        private readonly communicationService: CommunicationService,
        public router: Router,
        private readonly roomManagerService: RoomManagerService,
    ) {
        this.gameCarrousel = { hasNext: false, hasPrevious: false, gameCards: [] };
        this.homeRoute = '/home';
        this.configRoute = '/admin';
        this.index = 0;
        // this.roomManagerService.handleRoomEvents();
    }

    ngAfterViewInit(): void {
        this.loadGameCarrousel();
        this.handleGameCardsUpdate();
    }

    nextCarrousel() {
        if (this.gameCarrousel.hasNext) {
            ++this.index;
            this.loadGameCarrousel();
        }
    }

    previousCarrousel() {
        if (this.gameCarrousel.hasPrevious) {
            --this.index;
            this.loadGameCarrousel();
        }
    }

    ngOnDestroy(): void {
        this.reloadSubscription?.unsubscribe();
    }

    private loadGameCarrousel() {
        this.communicationService.loadGameCarrousel(this.index).subscribe((gameCarrousel) => {
            if (gameCarrousel) {
                this.gameCarrousel = gameCarrousel;
            }
        });
    }

    private handleGameCardsUpdate() {
        this.reloadSubscription = this.roomManagerService.isReloadNeeded$.subscribe((isGameCardsNeedToBeReloaded) => {
            if (isGameCardsNeedToBeReloaded) {
                this.index = 0;
                this.loadGameCarrousel();
            }
        });
    }
}
