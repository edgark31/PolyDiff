// ignore_for_file: constant_identifier_names

enum ConnectionEvents {
  UserConnectionRequest,
  UserDeconnectionRequest,
}

enum MessageEvents {
  LocalMessage,
  GlobalMessage,
}

enum MessageTag {
  Sent,
  Received,
  Common,
  Global,
}

enum EmailStatus { unknown, valid, invalid }

enum PasswordStatus { unknown, valid, invalid }

enum FormStatus {
  initial,
  valid,
  submissionInProgress,
  submissionSuccess,
  submissionFailure
}

enum SocketType {
  Auth,
  Lobby,
  Game,
}

enum GameModes {
  Classic,
  Limited,
  Practice,
}

enum ChannelEvents {
  SendLobbyMessage,
  LobbyMessage,
  SendGameMessage,
  GameMessage,
  SendGlobalMessage,
  GlobalMessage,
  UpdateLog,
  FriendConnection,
}

enum GameEvents {
  TimerUpdate, // Still used by server to emit time
  StartGame,
  UpdateTimer,
  Clic,
  Found,
  NotFound,
  Cheat,
  NextGame,
  AbandonGame,
  EndGame,
  Spectate,
  CheatActivated,
  CheatDeactivated,
}

enum LobbyEvents {
  Create,
  Join,
  Leave,
  OptPlayer,
  Spectate,
  UpdateLobbys,
  Start,
}


extension LobbyEventsExtension on LobbyEvents {
  String get name {
    switch (this) {
      case LobbyEvents.Create:
        return 'LobbyCreate';
      case LobbyEvents.Join:
        return 'LobbyJoin';
      case LobbyEvents.Leave:
        return 'LobbyLeave';
      case LobbyEvents.OptPlayer:
        return 'OptPlayer';
      case LobbyEvents.Spectate:
        return 'Spectate';
      case LobbyEvents.UpdateLobbys:
        return 'UpdateLobbys';
      case LobbyEvents.Start:
        return 'Start';
      default:
        return '';
    }
  }

  String get value {
    switch (this) {
      case LobbyEvents.Create:
        return 'LobbyCreate';
      case LobbyEvents.Join:
        return 'LobbyJoin';
      case LobbyEvents.Leave:
        return 'LobbyLeave';
      case LobbyEvents.OptPlayer:
        return 'OptPlayer';
      case LobbyEvents.Spectate:
        return 'Spectate';
      case LobbyEvents.UpdateLobbys:
        return 'UpdateLobbys';
      case LobbyEvents.Start:
        return 'Start';
      default:
        return '';
    }
  }
}

enum AccountEvents {
  UserUpdate,
  UserCreate,
  UserDelete,
  RefreshAccount,
}
