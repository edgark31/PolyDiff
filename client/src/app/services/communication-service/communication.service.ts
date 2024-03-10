/* eslint-disable @typescript-eslint/naming-convention */
import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { GameDetails } from '@app/interfaces/game-interfaces';
import { Observable, of } from 'rxjs';
import { catchError, tap } from 'rxjs/operators';
import { environment } from 'src/environments/environment';
import { Account, CarouselPaginator, Credentials, GameConfigConst, GameHistory, Song, Theme } from './../../../../../common/game-interfaces';

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

    login(creds: Credentials): Observable<Account> {
        return this.http.post<Account>(`${this.accountUrl}/login`, creds).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('logged in');
            }),
        );
    }

    modifyUser(oldusername: string, newusername: string): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/pseudo`, { oldUsername: oldusername, newUsername: newusername }).pipe(
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

    updateAvatar(oldusername: string, newavatar: string): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/avatar/upload`, { oldUsername: oldusername, newAvatar: newavatar }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('avatar update');
            }),
            catchError(this.handleError<void>('updateAvatar')),
        );
    }
    chooseAvatar(name: string, newavatar: string): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/avatar/choose`, { username: name, newAvatar: newavatar }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('avatar choose');
            }),
            catchError(this.handleError<void>('chooseAvatar')),
        );
    }

    modifyPassword(oldusername: string, newpassword: string): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/password`, { oldUsername: oldusername, newPassword: newpassword }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('password modify');
            }),
            catchError(this.handleError<void>('modifyPassword')),
        );
    }

    modifyTheme(oldusername: string, newtheme: Theme): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/theme`, { oldUsername: oldusername, newTheme: newtheme }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('theme modify');
            }),
            catchError(this.handleError<void>('modifyTheme')),
        );
    }

    modifySongError(oldusername: string, newSongError: Song): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/song/error`, { oldUsername: oldusername, newSong: newSongError }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('song Error modify');
            }),
            catchError(this.handleError<void>('modifySongError')),
        );
    }

    modifySongDifference(oldusername: string, newSongDifference: Song): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/song/difference`, { oldUsername: oldusername, newSong: newSongDifference }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('song Difference modify');
            }),
            catchError(this.handleError<void>('modifySongDifference')),
        );
    }

    modifyLanguage(oldusername: string, newlangage: string): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/langage`, { oldUsername: oldusername, newLangage: newlangage }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('langage modify');
            }),
            catchError(this.handleError<void>('modifylangage')),
        );
    }
    getPassword(password: string): Observable<boolean> {
        return this.http.post<boolean>(`${this.accountUrl}/admin`, { passwd: password }).pipe(
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
