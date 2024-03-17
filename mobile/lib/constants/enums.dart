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
}

enum ChannelEvents {
  SendLobbyMessage,
  LobbyMessage,
  SendLocalMessage,
  LocalMessage,
  SendGlobalMessage,
  GlobalMessage,
  UpdateLog,
  FriendConnection,
}

enum LobbyEvents {
  Create,
  Join,
  Leave,
  OptPlayer,
  JoinAsObserver,
  LeaveAsObserver,
  UpdateLobbys,
  Start,
  LeaveRoom,
}

enum GameEvents {
  StartGame,
  UpdateTimer,
  Clic,
  Found,
  NotFound,
  Cheat,
  NextGame,
  AbandonGame,
  EndGame
}

extension GameEventsExtension on GameEvents {
  String get name {
    switch (this) {
      case GameEvents.StartGame:
        return 'StartGame';
      case GameEvents.UpdateTimer:
        return 'UpdateTimer';
      case GameEvents.Clic:
        return 'Clic';
      case GameEvents.Found:
        return 'Found';
      case GameEvents.NotFound:
        return 'NotFound';
      case GameEvents.Cheat:
        return 'Cheat';
      case GameEvents.NextGame:
        return 'NextGame';
      case GameEvents.AbandonGame:
        return 'AbandonGame';
      case GameEvents.EndGame:
        return 'EndGame';
      default:
        return '';
    }
  }

  String get value {
    switch (this) {
      case GameEvents.StartGame:
        return 'StartGame';
      case GameEvents.UpdateTimer:
        return 'UpdateTimer';
      case GameEvents.Clic:
        return 'Clic';
      case GameEvents.Found:
        return 'Found';
      case GameEvents.NotFound:
        return 'NotFound';
      case GameEvents.Cheat:
        return 'Cheat';
      case GameEvents.NextGame:
        return 'NextGame';
      case GameEvents.AbandonGame:
        return 'AbandonGame';
      case GameEvents.EndGame:
        return 'EndGame';
      default:
        return '';
    }
  }
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
      case LobbyEvents.JoinAsObserver:
        return 'JoinAsObserver';
      case LobbyEvents.LeaveAsObserver:
        return 'LeaveAsObserver';
      case LobbyEvents.UpdateLobbys:
        return 'UpdateLobbys';
      case LobbyEvents.Start:
        return 'Start';
      case LobbyEvents.LeaveRoom:
        return 'LeaveRoom';
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
      case LobbyEvents.JoinAsObserver:
        return 'JoinAsObserver';
      case LobbyEvents.LeaveAsObserver:
        return 'LeaveAsObserver';
      case LobbyEvents.UpdateLobbys:
        return 'UpdateLobbys';
      case LobbyEvents.Start:
        return 'Start';
      case LobbyEvents.LeaveRoom:
        return 'LeaveRoom';
      default:
        return '';
    }
  }
}
