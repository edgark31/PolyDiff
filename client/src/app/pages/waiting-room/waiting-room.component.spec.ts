/* eslint-disable @typescript-eslint/no-explicit-any -- needed to spy on private methods*/

// describe('JoinedPlayerDialogComponent', () => {
//     let component: JoinedPlayerDialogComponent;
//     let fixture: ComponentFixture<JoinedPlayerDialogComponent>;
//     let roomManagerServiceSpy: jasmine.SpyObj<RoomManagerService>;
//     let joinedPlayerNamesMock: BehaviorSubject<WaitingPlayerNameList>;
//     let acceptPlayerNamesMock: BehaviorSubject<AcceptedPlayer>;
//     let dialogRefSpy: jasmine.SpyObj<MatDialogRef<JoinedPlayerDialogComponent>>;
//     let roomAvailabilityMock: BehaviorSubject<RoomAvailability>;
//     let deletedGameIdMock: BehaviorSubject<string>;
//     let refusePlayerIdMock: BehaviorSubject<string>;
//     let routerSpy: jasmine.SpyObj<Router>;

//     beforeEach(async () => {
//         deletedGameIdMock = new BehaviorSubject<string>('idMock');
//         roomAvailabilityMock = new BehaviorSubject<RoomAvailability>({
//             gameId: 'test-room-id',
//             isAvailableToJoin: false,
//             hostId: 'hostId',
//         });

//         joinedPlayerNamesMock = new BehaviorSubject<WaitingPlayerNameList>({
//             gameId: 'test-game-id',
//             playerNamesList: ['Alice', 'Bob', 'Charlie'],
//         });
//         acceptPlayerNamesMock = new BehaviorSubject<AcceptedPlayer>({
//             gameId: 'Jeu de la mort',
//             roomId: 'test-room-id',
//             playerName: 'Alice',
//         });
//         refusePlayerIdMock = new BehaviorSubject<string>('refusedPlayerId');
//         routerSpy = jasmine.createSpyObj('RouterTestingModule', ['navigate']);
//         dialogRefSpy = jasmine.createSpyObj('MatDialogRef', ['close', 'afterClosed']);
//         dialogRefSpy.afterClosed.and.returnValue(of('dialog closed'));
//         roomManagerServiceSpy = jasmine.createSpyObj('RoomManagerService', ['cancelJoining', 'getSocketId'], {
//             joinedPlayerNamesByGameId$: joinedPlayerNamesMock,
//             acceptedPlayerByRoom$: acceptPlayerNamesMock,
//             oneVsOneRoomsAvailabilityByRoomId$: roomAvailabilityMock,
//             deletedGameId$: deletedGameIdMock,
//             refusedPlayerId$: refusePlayerIdMock,
//             roomId$: of('roomId'),
//             isPlayerAccepted$: of(true),
//         });
//         await TestBed.configureTestingModule({
//             declarations: [JoinedPlayerDialogComponent],
//             imports: [MatDialogModule, RouterTestingModule],
//             providers: [
//                 { provide: MAT_DIALOG_DATA, useValue: { gameId: 'test-game-id', player: 'Alice' } },
//                 { provide: RoomManagerService, useValue: roomManagerServiceSpy },
//                 { provide: MatDialogRef, useValue: dialogRefSpy },
//                 { provide: Router, useValue: routerSpy },
//             ],
//         }).compileComponents();

//         fixture = TestBed.createComponent(JoinedPlayerDialogComponent);
//         component = fixture.componentInstance;
//         fixture.detectChanges();
//     });
//     afterEach(() => {
//         component.ngOnDestroy();
//     });

//     it('should create', () => {
//         expect(component).toBeTruthy();
//     });

//     it('handleCreateUndoCreation should call countDownBeforeClosing', () => {
//         const countDownSpy = spyOn<any>(component, 'countDownBeforeClosing');
//         component['data'] = { gameId: 'test-game-id', player: 'Alice' };
//         component['handleCreateUndoCreation']();
//         component['handleCreateUndoCreation']();
//         const mockAvailability: RoomAvailability = {
//             gameId: 'test-game-id',
//             isAvailableToJoin: false,
//             hostId: 'hostId',
//         };
//         roomAvailabilityMock.next(mockAvailability);
//         roomAvailabilityMock.next({} as unknown as RoomAvailability);
//         expect(countDownSpy).toHaveBeenCalled();
//     });

//     it('should call roomManagerService.cancelJoining with correct arguments', () => {
//         component.cancelJoining();
//         expect(roomManagerServiceSpy.cancelJoining).toHaveBeenCalledWith('test-game-id');
//     });

//     it('should handle refused players when refuse player names are received', () => {
//         const countDownSpy = spyOn<any>(component, 'countDownBeforeClosing');
//         component['handleRefusedPlayer']();
//         roomManagerServiceSpy.getSocketId.and.callFake(() => 'refusedPlayerId');
//         refusePlayerIdMock.next('refusedPlayerId');
//         expect(countDownSpy).toHaveBeenCalled();
//     });

//     it('should start countdown and show message if player is refuse or if gameCard is delete', fakeAsync(() => {
//         component['countDownBeforeClosing']('Test message');
//         expect(component.countdown).toBe(COUNTDOWN_TIME);
//         interval(WAITING_TIME)
//             .pipe(takeWhile(() => component.countdown > 0))
//             .subscribe(() => {
//                 component['countDownBeforeClosing']('Test message');
//             });
//         // Needed to not have periodic timer(s) still in the queue.
//         // eslint-disable-next-line @typescript-eslint/no-magic-numbers
//         tick(12000);
//         expect(dialogRefSpy.close).toHaveBeenCalled();
//     }));
// });
