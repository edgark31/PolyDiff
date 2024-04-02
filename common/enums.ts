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
    Practice = 'Practice',
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
    Spectate = 'Spectate',
    UpdateLobbys = 'UpdateLobbys',
    Start = 'Start',
    RequestAccess = 'RequestAccess',
    RequestAccessHost = 'RequestAccessHost',
    SendResponseAccess = 'SendResponseAccess',
    NotifyGuest = 'NotifyGuest',
    CancelRequestAcess = 'CancelRequestAcess',
    CancelRequestAcessHost = 'CancelRequestAcessHost',
}

export enum LobbyState {
    Idle = 'LobbyIdle',
    Waiting = 'LobbyWaiting',
    InGame = 'LobbyInGame',
    Spectate = 'LobbySpectate',
}

export enum AccountEvents {
    RefreshAccount = 'RefreshAccount', // Pour rafraichir son propre compte
}

export enum UserEvents {
    UpdateUsers = 'UpdateUsers', // Pour chercher les users, même offline
}

export enum FriendEvents {
    SendRequest = 'SendRequest', // Envoyer une demande - ROLE de l'envoyeur
    CancelRequest = 'CancelRequest', // Annuler une demande -  ROLE de l'envoyeur
    OptRequest = 'OptRequest', // Accepter ou refuser une demande - ROLE du recepteur
    OptFavorite = 'OptFavorite', // Ajouter ou retirer un ami des favoris
    UpdateFriends = 'UpdateFriends', // Pour rafraichir la liste d'amis
    UpdateFoFs = 'UpdateFoFs', // Pour rafraichir la liste d'amis d'amis
    UpdateCommonFriends = 'UpdateCommonFriends', // Pour rafraichir la liste d'amis communs
    UpdateSentFriends = 'UpdateSentFriends', // Pour rafraichir la liste des demandes envoyées
    UpdatePendingFriends = 'UpdatePendingFriends', // Pour rafraichir la liste des demandes en attente
    DeleteFriend = 'DeleteFriend', // Pour supprimer un ami
    ShareScore = 'ShareScore', // Pour partager un score -- CLIENT LOURD seulement
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
    Spectate = 'Spectate',
    CheatActivated = 'CheatActivated',
    CheatDeactivated = 'CheatDeactivated',
    GameRecord = 'GameRecord',
    WatchRecordedGame = 'WatchRecordedGame',
    SaveGameRecord = 'SaveGameRecord',
}

export enum GameState {
    InGame = 'GameInGame',
    Abandoned = 'GameHasAbandoned',
    Spectate = 'GameSpectate',
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
