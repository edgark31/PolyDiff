import { Injectable } from '@angular/core';

@Injectable({
    providedIn: 'root',
})
export class NavigationService {
    private previousUrl: string;
    private gameId: string;
    private nDifferences: number;

    setNDifferences(nDifferences: number): void {
        this.nDifferences = nDifferences;
    }

    getNDifferences(): number {
        return this.nDifferences;
    }

    setGameId(gameId: string): void {
        this.gameId = gameId;
    }

    getGameId(): string {
        return this.gameId;
    }

    setPreviousUrl(url: string): void {
        this.previousUrl = url;
    }

    getPreviousUrl(): string {
        return this.previousUrl;
    }
}
