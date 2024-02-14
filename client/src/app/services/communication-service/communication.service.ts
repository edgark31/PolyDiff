import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { GameDetails } from '@app/interfaces/game-interfaces';
import { Account, CarouselPaginator, Credentials, GameConfigConst, GameHistory } from '@common/game-interfaces';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { environment } from 'src/environments/environment';

@Injectable({
    providedIn: 'root',
})
export class CommunicationService {
    private readonly gameUrl: string;
    private readonly accountUrl: string;

    constructor(private readonly http: HttpClient) {
        this.gameUrl = environment.serverUrl + '/games';
        this.accountUrl = environment.serverUrl + '/account';
    }

    loadGameCarrousel(index: number): Observable<CarouselPaginator> {
        return this.http.get<CarouselPaginator>(`${this.gameUrl}/carousel/${index}`);
    }

    postGame(gameData: GameDetails): Observable<void> {
        return this.http.post<void>(`${this.gameUrl}`, gameData);
    }

    createUser(creds: Credentials): Observable<void> {
        return this.http.post<void>(`${this.accountUrl}/register`, creds).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('User created');
            }),
        );
    }

    login(creds: Credentials): Observable<Account> {
        return this.http.post<Account>(`${this.accountUrl}/login`, creds).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('logged in');
            }),
        );
    }

    loadConfigConstants(): Observable<GameConfigConst> {
        return this.http.get<GameConfigConst>(`${this.gameUrl}/constants`);
    }

    loadGameHistory(): Observable<GameHistory[]> {
        return this.http.get<GameHistory[]>(`${this.gameUrl}/history`);
    }

    deleteGameById(id: string): Observable<void> {
        return this.http.delete<void>(`${this.gameUrl}/${id}`);
    }

    deleteAllGames(): Observable<void> {
        return this.http.delete<void>(`${this.gameUrl}`);
    }

    deleteAllGamesHistory(): Observable<void> {
        return this.http.delete<void>(`${this.gameUrl}/history`);
    }

    verifyIfGameExists(name: string): Observable<boolean> {
        return this.http.get<boolean>(`${this.gameUrl}/?name=${name}`);
    }

    updateGameConstants(gameConstants: GameConfigConst): Observable<void> {
        return this.http.put<void>(`${this.gameUrl}/constants`, gameConstants);
    }
}
