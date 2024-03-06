export enum CardEvents {
    ResetTopTime = 'ResetTopTime',
    ResetAllTopTimes = 'ResetAllTopTimes',
    CardDeleted = 'CardDeleted',
    CardCreated = 'CardCreated',
    RequestReload = 'RequestReload',
    AllGamesDeleted = 'AllGamesDeleted',
    GameDeleted = 'GameDeleted',
    // GameConstantsUpdated = 'GameConstantsUpdated',
    // GamesHistoryDeleted = 'GamesHistoryDeleted',
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
}

export enum MessageTag {
    Sent = 'Sent',
    Received = 'Received',
    Common = 'Common',
    Global = 'Global',
}

export enum LobbyEvents {
    Create = 'LobbyCreate',
    Join = 'LobbyJoin',
    Leave = 'LobbyLeave',
    Kick = 'LobbyKick',
    Lock = 'LobbyLock',
    OptPlayer = 'LobbyOptPlayer',
    JoinAsObserver = 'LobbyJoinAsObserver',
    LeaveAsObserver = 'LobbyLeaveAsObserver',
    UpdateLobbies = 'LobbyUpdateLobbies',
    Start = 'LobbyStart',
}

export enum AccountEvents {
    ChangePseudo = 'AccountChangePseudo',
    Update = 'AccountUpdate',
}

export enum FriendEvents {
    Invite = 'FriendInvite',
    OptInvite = 'FriendOptInvite',
    CancelInvite = 'FriendCancelInvite',
    AddFavorite = 'FriendAddFavorite',
    Update = 'FriendUpdate',
    SendScore = 'FriendSendScore',
    ShareScore = 'FriendShareScore',
}

export enum GameEvents {
    Start = 'GameStart',
    UpdateTimer = 'GameUpdateTimer',
    Next = 'NextGame',
    Leave = 'LeaveGame',
    End = 'EndGame',
    ValidateCoords = 'ValidateCoords',
    CheckStatus = 'CheckStatus',
    TimerUpdate = 'TimerUpdate',
    RemoveDifference = 'RemoveDifference',
    AbandonGame = 'AbandonGame',
    StartGameByRoomId = 'CreateOneVsOneGame',
    StartNextGame = 'StartNextGame',
    RequestHint = 'RequestHint',
    UpdateDifferencesFound = 'UpdateDifferencesFound',
    GameModeChanged = 'GameModeChanged',
    GamePageRefreshed = 'Refresh',
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
    Update = 'RankingUpdate',
}
