/* eslint-disable @typescript-eslint/naming-convention */
import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { GameDetails } from '@app/interfaces/game-interfaces';
import { Observable, of } from 'rxjs';
import { catchError, tap } from 'rxjs/operators';
import { environment } from 'src/environments/environment';
import { Account, CarouselPaginator, Credentials, Game, GameConfigConst, GameHistory, Theme } from './../../../../../common/game-interfaces';

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

    modifyUser(oldUsername: string, newUsername: string): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/username`, { oldUsername: oldUsername, newUsername: newUsername }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('User modify');
            }),
            catchError(this.handleError<void>('modifyUser')),
        );
    }

    sendMail(mail: string): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/mail`, { email: mail }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('mail modify');
            }),
            catchError(this.handleError<void>('modifyUser')),
        );
    }

    updateAvatar(username: string, newAvatar: string): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/avatar/upload`, { username: username, newAvatar: newAvatar }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('avatar update');
            }),
            catchError(this.handleError<void>('updateAvatar')),
        );
    }
    chooseAvatar(name: string, newAvatar: string): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/avatar/choose`, { username: name, newAvatar: newAvatar }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('avatar choose');
            }),
            catchError(this.handleError<void>('chooseAvatar')),
        );
    }

    modifyPassword(username: string, newPassword: string): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/password`, { username: username, newPassword: newPassword }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('password modify');
            }),
            catchError(this.handleError<void>('modifyPassword')),
        );
    }

    modifyTheme(oldUsername: string, newTheme: Theme): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/desktop/theme`, { oldUsername: oldUsername, newTheme: newTheme }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('theme modified');
            }),
            catchError(this.handleError<void>('modifyTheme')),
        );
    }

    modifySongError(username: string, newSoundId: String): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/sound/error`, { username: username, newSoundId: newSoundId }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('sound on Error modify');
            }),
            catchError(this.handleError<void>('modifySongError')),
        );
    }

    modifySongDifference(username: string, newCorrectSoundId: String): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/sound/correct`, { username: username, newSoundId: newCorrectSoundId }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('Correct sound modify');
            }),
            catchError(this.handleError<void>('modifiedCorrectSound')),
        );
    }

    modifyLanguage(username: string, newLanguage: string): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/language`, { username: username, newLanguage: newLanguage }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('langage modify');
            }),
            catchError(this.handleError<void>('modifyLanguage')),
        );
    }

    getPassword(password: string): Observable<boolean> {
        return this.http.post<boolean>(`${this.accountUrl}/admin`, { password: password }).pipe(
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('langage modify');
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
