import { WaitingGameComponent } from '@app/components/waiting-game/waiting-game.component';
/* eslint-disable import/no-unresolved */
import { OverlayModule } from '@angular/cdk/overlay';
import { HttpClient, HttpClientModule } from '@angular/common/http';
import { NgModule } from '@angular/core';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatDialogModule } from '@angular/material/dialog';
import { MatExpansionModule } from '@angular/material/expansion';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatGridListModule } from '@angular/material/grid-list';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatListModule } from '@angular/material/list';
import { MatMenuModule } from '@angular/material/menu';
import { MatPaginatorModule } from '@angular/material/paginator';
import { MatSelectModule } from '@angular/material/select';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatSliderModule } from '@angular/material/slider';
import { MatTableModule } from '@angular/material/table';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatTooltipModule } from '@angular/material/tooltip';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { RouterModule } from '@angular/router';
import { CreationGameDialogComponent } from '@app/components/creation-game-dialog/creation-game-dialog.component';
import { GameInfosComponent } from '@app/components/game-infos/game-infos.component';
import { GameSheetComponent } from '@app/components/game-sheet/game-sheet.component';
import { PlayerNameDialogBoxComponent } from '@app/components/player-name-dialog-box/player-name-dialog-box.component';
import { AppRoutingModule, routes } from '@app/modules/app-routing.module';
import { AppMaterialModule } from '@app/modules/material.module';
import { AppComponent } from '@app/pages/app/app.component';
import { CreationPageComponent } from '@app/pages/creation-page/creation-page.component';
import { GamePageComponent } from '@app/pages/game-page/game-page.component';
import { MainPageComponent } from '@app/pages/main-page/main-page.component';
import { SelectionPageComponent } from '@app/pages/selection-page/selection-page.component';
import { TranslateCompiler, TranslateLoader, TranslateModule } from '@ngx-translate/core';
import { TranslateHttpLoader } from '@ngx-translate/http-loader';
import { TranslateMessageFormatCompiler } from 'ngx-translate-messageformat-compiler';
import { AccountDialogComponent } from './components/account-dialog/account-dialog.component';
import { CanvasMiddleButtonsComponent } from './components/canvas-middle-buttons/canvas-middle-buttons.component';
import { CanvasTopButtonsComponent } from './components/canvas-top-buttons/canvas-top-buttons.component';
import { CanvasUnderButtonsComponent } from './components/canvas-under-buttons/canvas-under-buttons.component';
import { ChatBoxComponent } from './components/chat-box/chat-box.component';
import { ConfigDialogComponent } from './components/config-dialog/config-dialog.component';
import { DeleteResetConfirmationDialogComponent } from './components/delete-reset-confirmation-dialog/delete-reset-confirmation-dialog.component';
import { FriendsInfosComponent } from './components/friends-infos/friends-infos.component';
import { GamePageDialogComponent } from './components/game-page-dialog/game-page-dialog.component';
import { HistoryBoxComponent } from './components/history-box/history-box.component';
import { HistoryLoginComponent } from './components/history-login/history-login.component';
import { ImageCanvasComponent } from './components/image-canvas/image-canvas.component';
import { ImportDialogComponent } from './components/import-dialog-box/import-dialog-box.component';
import { JoinedPlayerDialogComponent } from './components/joined-player-dialog/joined-player-dialog.component';
import { MenuComponent } from './components/menu/menu.component';
import { ModalAccessMatchComponent } from './components/modal-access-match/modal-access-match.component';
import { ModalAdminComponent } from './components/modal-admin/modal-admin.component';
import { NameGenerationDialogComponent } from './components/name-generation-dialog/name-generation-dialog.component';
import { NavBarComponent } from './components/nav-bar/nav-bar.component';
import { NoGameAvailableDialogComponent } from './components/no-game-available-dialog/no-game-available-dialog.component';
import { ReplayButtonsComponent } from './components/replay-buttons/replay-buttons/replay-buttons.component';
import { RoomSheetComponent } from './components/room-sheet/room-sheet.component';
import { ShareModalComponent } from './components/share-modal/share-modal.component';
import { WaitingPlayerToJoinComponent } from './components/waiting-player-to-join/waiting-player-to-join.component';
import { ChatPageComponent } from './pages/chat-page/chat-page.component';
import { ClassicTimePageComponent } from './pages/classic-time-page/classic-time-page.component';
import { ConfigPageComponent } from './pages/config-page/config-page.component';
import { ConfirmPasswordPageComponent } from './pages/confirm-password-page/confirm-password-page.component';
import { CreateRoomPageComponent } from './pages/create-room-page/create-room-page.component';
import { FriendPageComponent } from './pages/friend-page/friend-page.component';
import { GameModePageComponent } from './pages/game-mode-page/game-mode-page.component';
import { LimitedTimePageComponent } from './pages/limited-time-page/limited-time-page.component';
import { LoginPageComponent } from './pages/login-page/login-page.component';
import { PersonalizationPageComponent } from './pages/personnalization-page/personnalization-page.component';
import { ProfilPageComponent } from './pages/profil-page/profil-page.component';
import { RecoverPasswordPageComponent } from './pages/recover-password-page/recover-password-page.component';
import { RegistrationPageComponent } from './pages/registration-page/registration-page.component';
import { ReplayGamePageComponent } from './pages/replay-game-page/replay-game-page.component';
import { ReplayPageComponent } from './pages/replay-page/replay-page.component';
import { WaitingRoomComponent } from './pages/waiting-room/waiting-room.component';
/**
 * Main module that is used in main.ts.
 * All automatically generated components will appear in this module.
 * Please do not move this module in the module folder.
 * Otherwise Angular Cli will not know in which module to put new component
 */
export const createTranslateLoader = (http: HttpClient) => {
    return new TranslateHttpLoader(http, './assets/i18n/', '.json');
};
@NgModule({
    declarations: [
        AppComponent,
        ShareModalComponent,
        CreationPageComponent,
        MainPageComponent,
        SelectionPageComponent,
        GamePageComponent,
        GameSheetComponent,
        PlayerNameDialogBoxComponent,
        GameInfosComponent,
        ImageCanvasComponent,
        ImportDialogComponent,
        ConfigPageComponent,
        CreationGameDialogComponent,
        GamePageDialogComponent,
        CanvasTopButtonsComponent,
        MenuComponent,
        NavBarComponent,
        ChatBoxComponent,
        CanvasMiddleButtonsComponent,
        ReplayButtonsComponent,
        DeleteResetConfirmationDialogComponent,
        LimitedTimePageComponent,
        ConfigDialogComponent,
        NoGameAvailableDialogComponent,
        HistoryBoxComponent,
        LoginPageComponent,
        RecoverPasswordPageComponent,
        NameGenerationDialogComponent,
        PersonalizationPageComponent,
        ProfilPageComponent,
        ModalAdminComponent,
        ConfirmPasswordPageComponent,
        ImportDialogComponent,
        ChatPageComponent,
        GameModePageComponent,
        CreateRoomPageComponent,
        WaitingRoomComponent,
        ModalAccessMatchComponent,
        LimitedTimePageComponent,
        RoomSheetComponent,
        ClassicTimePageComponent,
        CanvasUnderButtonsComponent,
        RegistrationPageComponent,
        AccountDialogComponent,
        FriendPageComponent,
        HistoryLoginComponent,
        FriendsInfosComponent,
        WaitingPlayerToJoinComponent,
        JoinedPlayerDialogComponent,
        ReplayPageComponent,
        ReplayGamePageComponent,
        WaitingGameComponent,
    ],
    imports: [
        AppMaterialModule,
        AppRoutingModule,
        BrowserAnimationsModule,
        BrowserModule,
        FormsModule,
        HttpClientModule,
        ReactiveFormsModule,
        MatDialogModule,
        OverlayModule,
        MatTooltipModule,
        MatFormFieldModule,
        MatInputModule,
        MatButtonModule,
        RouterModule,
        MatGridListModule,
        MatExpansionModule,
        MatSelectModule,
        MatMenuModule,
        MatCheckboxModule,
        MatTableModule,
        MatPaginatorModule,
        MatToolbarModule,
        MatIconModule,
        MatSidenavModule,
        MatListModule,
        MatSliderModule,
        MatPaginatorModule,
        RouterModule.forRoot(routes),
        TranslateModule.forRoot({
            loader: {
                provide: TranslateLoader,
                useFactory: createTranslateLoader,
                deps: [HttpClient],
            },
            compiler: {
                provide: TranslateCompiler,
                useClass: TranslateMessageFormatCompiler,
            },
        }),
    ],
    providers: [],
    bootstrap: [AppComponent],
})
export class AppModule {}
