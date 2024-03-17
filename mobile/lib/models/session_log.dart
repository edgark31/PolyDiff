class SessionLog {
  String timestamp;
  bool isWinner;

  SessionLog({required this.timestamp, required this.isWinner});

  factory SessionLog.fromJson(Map<String, dynamic> json) {
    return SessionLog(
      timestamp: json['timestamp'],
      isWinner: json['isWinner'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'isWinner': isWinner,
    };
  }
}

class ConnexionLog {
  String timestamp;
  bool isConnexion;

  ConnexionLog({required this.timestamp, required this.isConnexion});

  factory ConnexionLog.fromJson(Map<String, dynamic> json) {
    return ConnexionLog(
      timestamp: json['timestamp'],
      isConnexion: json['isConnexion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'isConnexion': isConnexion,
    };
  }
}
