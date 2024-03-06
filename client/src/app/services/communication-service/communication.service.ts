import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Account, CarouselPaginator, Credentials, GameConfigConst, GameDetails, GameHistory, Theme } from '@common/game-interfaces';
import { Observable, of } from 'rxjs';
import { catchError, tap } from 'rxjs/operators';
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

    modifyPassword(oldusername: string, oldpassword: string, newpassword: string): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/password`, { oldUsername: oldusername, oldpassword, newPassword: newpassword }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('password modify');
            }),
            catchError(this.handleError<void>('modifyPassword')),
        );
    }

    modifyTheme(oldusername: string, oldtheme: Theme, newtheme: Theme): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/theme`, { oldUsername: oldusername, oldTheme: oldtheme, newTheme: newtheme }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('theme modify');
            }),
            catchError(this.handleError<void>('modifyTheme')),
        );
    }

    modifyLangage(oldusername: string, oldlangage: string, newlangage: string): Observable<void> {
        return this.http.put<void>(`${this.accountUrl}/langage`, { oldUsername: oldusername, oldLangage: oldlangage, newLangage: newlangage }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {
                // eslint-disable-next-line no-console
                console.log('langage modify');
            }),
            catchError(this.handleError<void>('modifylangage')),
        );
    }
    // modifyProfile(oldprofil: modifYProfile, newprofile: modifYProfile): Observable<void> {
    //     return this.http.put<void>(`${this.accountUrl}/Profile`, { oldProfil: oldprofil, newProfile: newprofile }).pipe(
    //         // eslint-disable-next-line @typescript-eslint/no-empty-function
    //         tap(() => {
    //             // eslint-disable-next-line no-console
    //             console.log('User modify');
    //         }),
    //         catchError(this.handleError<void>('modifyUser')),
    //     );
    // }

    recuperatePassword(password: string): Observable<boolean> {
        return this.http.post<boolean>(`${this.accountUrl}/admin`, { passwd: password }).pipe(
            // eslint-disable-next-line @typescript-eslint/no-empty-function
            tap(() => {}),
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
