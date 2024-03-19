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

export enum ChatState {
    Global = 'Global',
    Waiting = 'Waiting',
    Game = 'Game',
    Nothing = 'Nothing',
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
    Classic = 'Classic',
    Limited = 'Limited',
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
    UserUpdate = 'UserUpdate',
    UserCreate = 'UserCreate',
    UserDelete = 'UserDelete',
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
    ValidateCoords = 'ValidateCoords',
    CheckStatus = 'CheckStatus',
    TimerUpdate = 'TimerUpdate',
    RemoveDifference = 'removeDifference',
    GameStarted = 'GameStarted',
    StartGameByRoomId = 'CreateOneVsOneGame',
    StartNextGame = 'StartNextGame',
    RequestHint = 'RequestHint',
    UpdateDifferencesFound = 'UpdateDifferencesFound',
    GameModeChanged = 'GameModeChanged',
    GamePageRefreshed = 'GamePageRefreshed',
    // J'utilise pas les events plus haut
    StartGame = 'StartGame',
    UpdateTimer = 'UpdateTimer',
    // CheckStatus = "CheckStatus",
    // RemoveDifference = "RemoveDifference",
    Clic = 'Clic',
    Found = 'Found',
    NotFound = 'NotFound',
    Cheat = 'Cheat',
    NextGame = 'NextGame',
    AbandonGame = 'AbandonGame',
    EndGame = 'EndGame',
}

export enum GameState {
    InGame = 'GameInGame',
    Left = 'GameHasLeft',
    Abandoned = 'GameHasAbandoned',
}

export enum ChannelEvents {
    SendLobbyMessage = 'SendLobbyMessage',
    LobbyMessage = 'LobbyMessage',
    SendGameMessage = 'SendGameMessage',
    GameMessage = 'GameMessage',
    SendGlobalMessage = 'SendGlobalMessage',
    GlobalMessage = 'GlobalMessage',
    UpdateLog = 'UpdateLog',
    FriendConnection = 'FriendConnection',
}

export enum RankingEvents {
    Update = 'Update',
}
