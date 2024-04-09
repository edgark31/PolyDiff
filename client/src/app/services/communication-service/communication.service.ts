/* eslint-disable @typescript-eslint/naming-convention */
import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { GameDetails } from '@app/interfaces/game-interfaces';
import { Observable, of } from 'rxjs';
import { catchError, tap } from 'rxjs/operators';
import { environment } from 'src/environments/environment';
import {
    Account,
    CarouselPaginator,
    Credentials,
    Game,
    GameConfigConst,
    GameHistory,
    GameRecord,
    Sound,
    Theme,
} from './../../../../../common/game-interfaces';

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

    createUser(credentials: Credentials, idAvatar: string): Observable<void> {
        return this.http.post<void>(`${this.accountUrl}/register`, { creds: credentials, id: idAvatar }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('User created');
            }),
        );
    }

    login(credentials: Credentials): Observable<Account> {
        return this.http.post<Account>(`${this.accountUrl}/login`, credentials).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('logged in');
            }),
        );
    }

    updateUsername(oldUsername: string, newUsername: string): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/username`, { oldUsername, newUsername }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('Username modified');
            }),
            catchError(this.handleError<void>('modifyUsername')),
        );
    }

    sendMail(mail: string): Observable<Account> {
        return this.http.put<Account>(`${this.accountUrl}/mail`, { email: mail }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('mail modify');
            }),
        );
    }

    updateAvatar(username: string, avatar: string): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/avatar/upload`, { username, avatar }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('avatar update');
            }),
            catchError(this.handleError<void>('updateAvatar')),
        );
    }
    chooseAvatar(username: string, newAvatar: string): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/avatar/choose`, { username, id: newAvatar }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('avatar choose');
            }),
            catchError(this.handleError<void>('chooseAvatar')),
        );
    }

    modifyPassword(username: string, newPassword: string): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/password`, { username, newPassword }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('password modify');
            }),
            catchError(this.handleError<void>('modifyPassword')),
        );
    }

    modifyTheme(username: string, newTheme: Theme): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/desktop/theme`, { username, newTheme }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('theme modified');
            }),
            catchError(this.handleError<void>('modifyTheme')),
        );
    }

    modifySongError(username: string, newErrorSound: Sound): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/sound/error`, { username, newSound: newErrorSound }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('sound on error modified');
            }),
            catchError(this.handleError<void>('modifySongError')),
        );
    }

    modifySongDifference(username: string, newCorrectSound: Sound): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/sound/correct`, { username, newSound: newCorrectSound }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('on correct sound modified');
            }),
            catchError(this.handleError<void>('modifyCorrectSound')),
        );
    }

    modifyLanguage(username: string, newLanguage: string): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/language`, { username, newLanguage }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('Language modified');
            }),
            catchError(this.handleError<void>('Language modified')),
        );
    }

    getPassword(password: string): Observable<boolean> {
        return this.http.post<boolean>(`${this.accountUrl}/admin`, { password }).pipe(
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('Modified password');
            }),
            catchError(this.handleError<boolean>('Recuperate Password')),
        );
    }

    checkCode(code: string): Observable<boolean> {
        return this.http.post<boolean>(`${this.gameUrl}/match/check/code`, { Code: code }).pipe(
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('code check');
            }),
            catchError(this.handleError<boolean>('checkcode')),
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

    getGameById(id: string): Observable<Game> {
        return this.http.get<Game>(`${this.gameUrl}/${id}`).pipe(catchError(this.handleError<Game>(`getGameById id=${id}`)));
    }

    getGameRecords(date: Date): Observable<GameRecord[]> {
        return this.http.get<GameRecord[]>(`${environment.serverUrl}/api/records${date}`);
    }

    deleteAllGameRecords(date: Date): Observable<void> {
        return this.http.delete<void>(`${environment.serverUrl}/api/records/${date}`);
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

    private handleError<T>(_request: string, result?: T): (error: Error) => Observable<T> {
        return () => of(result as T);
    }
}
