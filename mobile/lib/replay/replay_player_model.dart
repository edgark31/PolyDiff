import 'package:mobile/replay/replay_game_model.dart';

class ReplayPlayer {
  String? accountId;
  String? username;
  List<Difference>? foundDifference = [];
  int? count = 0;

  ReplayPlayer({
    this.accountId,
    this.username,
    this.foundDifference,
    this.count,
  });

  ReplayPlayer copyWith({
    String? accountId,
    String? username,
    List<Difference>? foundDifference,
    int? count,
  }) {
    return ReplayPlayer(
      accountId: accountId,
      username: username,
      foundDifference: foundDifference,
      count: count,
    );
  }
}
