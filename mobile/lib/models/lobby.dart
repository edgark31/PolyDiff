import 'package:mobile/models/models.dart';

class Lobby {
  final int lobbyId;
  final Game game;
  List<Player> players;
  final String creatorId;
  bool isPrivate;
  List<String> chatMessages;
  bool isGameStarted;

  Lobby({
    required this.lobbyId,
    required this.game,
    required this.creatorId,
    this.players = const [],
    this.isPrivate = false,
    this.chatMessages = const [],
    this.isGameStarted = false,
  });

  void addPlayer(Player player) {
    if (!isGameStarted &&
        players.length < 4 &&
        !players.any((p) => p.playerId == player.playerId)) {
      players = List.from(players)..add(player);
    } else {
      print("Lobby is full, game has started, or player already in lobby.");
    }
  }

  bool removePlayer(String playerId) {
    if (!isGameStarted) {
      try {
        final playerToRemove =
            players.firstWhere((player) => player.playerId == playerId);
        players.remove(playerToRemove);
        return true;
      } catch (e) {
        // No matching player found
        return false;
      }
    }
    return false;
  }

  void startGame() {
    if (players.any((player) => player.playerId == creatorId) &&
        players.length >= 2 &&
        players.length <= 4) {
      isGameStarted = true;
      print("Game started with ${players.length} players!");
    } else {
      print("Cannot start game. Must have 2 to 4 players.");
    }
  }

  void addChatMessage(String message) {
    chatMessages = List.from(chatMessages)..add(message);
  }
}
