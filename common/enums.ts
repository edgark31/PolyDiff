<<<<<<< HEAD
=======
export enum GameEvents {
    ValidateCoords = 'ValidateCoords',
    CheckStatus = 'CheckStatus',
    EndGame = 'EndGame',
    TimerUpdate = 'TimerUpdate',
    RemoveDifference = 'removeDifference',
    GameStarted = 'GameStarted',
    AbandonGame = 'AbandonGame',
    StartGameByRoomId = 'CreateOneVsOneGame',
    StartNextGame = 'StartNextGame',
    RequestHint = 'RequestHint',
    UpdateDifferencesFound = 'UpdateDifferencesFound',
    GameModeChanged = 'GameModeChanged',
    GamePageRefreshed = 'Refresh',
}

export enum PlayerEvents {
    PlayerRefused = 'PlayerRefused',
    GetJoinedPlayerNames = 'GetJoinedPlayerNames',
    PlayerAccepted = 'PlayerAccepted',
    AcceptPlayer = 'AcceptPlayer',
    CancelJoining = 'CancelJoining',
    RefusePlayer = 'RefusePlayer',
    PlayerNameTaken = 'PlayerNameTaken',
    UpdateWaitingPlayerNameList = 'UpdateWaitingPlayerNameList',
    CheckIfPlayerNameIsAvailable = 'CheckIfPlayerNameIsAvailable',
    WaitingPlayerNameListUpdated = 'WaitingPlayerNameListUpdated',
}

export enum GameCardEvents {
    ResetTopTime = 'ResetTopTime',
    ResetAllTopTimes = 'ResetAllTopTimes',
    GameCardDeleted = 'GameCardDeleted',
    GameCardCreated = 'GameCardCreated',
    RequestReload = 'RequestReload',
    AllGamesDeleted = 'AllGamesDeleted',
    GameDeleted = 'GameDeleted',
    GameConstantsUpdated = 'GameConstantsUpdated',
    GamesHistoryDeleted = 'GamesHistoryDeleted',
}

export enum HistoryEvents {
    RequestReload = 'RequestReload',
}

export enum RoomEvents {
    CreateClassicSoloRoom = 'CreateClassicSoloRoom',
    RoomSoloCreated = 'RoomSoloCreated',
    RoomLimitedCreated = 'RoomLimitedCreated',
    CreateLimitedRoom = 'CreateSoloLimitedRoom',
    RoomOneVsOneCreated = 'RoomOneVsOneCreated',
    RoomOneVsOneAvailable = 'RoomOneVsOneAvailable',
    CreateOneVsOneRoom = 'CreateOneVsOneRoom',
    CreateCoopLimitedRoom = 'CreateCoopLimitedRoom',
    CheckRoomOneVsOneAvailability = 'CheckRoomOneVsOneAvailability',
    UpdateRoomOneVsOneAvailability = 'UpdateRoomOneVsOneAvailability',
    OneVsOneRoomDeleted = 'OneVsOneRoomDeleted',
    UndoRoomCreation = 'UndoRoomCreation',
    DeleteCreatedOneVsOneRoom = 'DeleteCreatedOneVsOneRoom',
    JoinOneVsOneRoom = 'JoinOneVsOneRoom',
    CheckIfAnyCoopRoomExists = 'CheckIfAnyCoopRoomExists',
    LimitedCoopRoomJoined = 'LimitedCoopRoomJoined',
    DeleteCreatedCoopRoom = 'DeleteCreatedCoopRoom',
    NoGameAvailable = 'NoGameAvailable',
}

export enum PlayerStatus {
    Winner = 'Winner',
    Quitter = 'Quitter',
}

export enum GameModes {
    ClassicSolo = 'Classic->Solo',
    ClassicOneVsOne = 'Classic->OneVsOne',
    LimitedSolo = 'Limited->Solo',
    LimitedCoop = 'Limited->Coop',
    Classic = "Classic",
    Limited = "Limited",
}

export enum MessageEvents {
    LocalMessage = 'LocalMessage',
    GlobalMessage = 'GlobalMessage',
}

export enum MessageTag {
    Sent = 'Sent',
    Received = 'Received',
    Common = 'Common',
    Global = 'Global',
}

export enum GamePageEvent {
    EndGame = 'EndGame',
    Abandon = 'Abandon',
}

export enum ConnectionEvents {
    UserConnectionRequest = 'UserConnectionRequest',
    UserDeconnectionRequest = 'UserDeconnectionRequest',
    UserCreationRequest = 'UserCreationRequest',
}

export enum LobbyEvents {
    Create = 'LobbyCreate',
    Join = 'LobbyJoin',
    Leave = 'LobbyLeave',
    OptPlayer = 'OptPlayer',
    JoinAsObserver = 'JoinAsObserver',
    LeaveAsObserver = 'LeaveAsObserver',
    UpdateLobbys = 'UpdateLobbys',
    Start = 'Start',
}

export enum LobbyState {
    Idle = 'LobbyIdle',
    Waiting = 'LobbyWaiting',
    InGame = 'LobbyInGame',
}

export enum AccountEvents {
    ChangePseudo = 'ChangePseudo',
    Update = 'Update',
}

export enum FriendEvents {
    Invite = 'Invite',
    OptInvite = 'OptInvite',
    CancelInvite = 'CancelInvite',
    AddFavorite = 'AddFavorite',
    Update = 'Update',
    SendScore = 'SendScore',
    ShareScore = 'ShareScore',
}

export enum GameEvents {
    Start = 'Start',
    UpdateTimer = 'UpdateTimer',
    // CheckStatus = "CheckStatus",
    // RemoveDifference = "RemoveDifference",
    Next = 'Next',
    Leave = 'Leave',
    End = 'End',
}

export enum GameState {
    InGame = 'GameInGame',
    Left = 'GameHasLeft',
    Abandoned = 'GameHasAbandoned',
}

export enum ChannelEvents {
    SendLobbyMessage = 'SendLobbyMessage',
    LobbyMessage = 'LobbyMessage',
    SendLocalMessage = 'SendLocalMessage',
    LocalMessage = 'LocalMessage',
    SendGlobalMessage = 'SendGlobalMessage',
    GlobalMessage = 'GlobalMessage',
    UpdateLog = 'UpdateLog',
    FriendConnection = 'FriendConnection',
}

export enum RankingEvents {
    Update = 'Update',
}
>>>>>>> c5f4dc77a04b45be526171e798ba15819d6d8df8
