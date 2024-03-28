import 'package:mobile/models/replay_game_model.dart';

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

  factory ReplayPlayer.fromJson(Map<String, dynamic> json) {
    List<Difference> foundDifference = json['foundDifference'] != null
        ? json['foundDifference']
            .map<Difference>((x) => Difference.fromJson(x))
            .toList()
        : [];

    return ReplayPlayer(
      accountId: json['accountId'] ?? '',
      username: json['username'] ?? '',
      foundDifference: foundDifference,
      count: json['count'] ?? 0,
    );
  }
}
