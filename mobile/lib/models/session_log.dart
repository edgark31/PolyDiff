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

class ConnectionLog {
  String timestamp;
  bool isConnection;

  ConnectionLog({required this.timestamp, required this.isConnection});

  factory ConnectionLog.fromJson(Map<String, dynamic> json) {
    return ConnectionLog(
      timestamp: json['timestamp'],
      isConnection: json['isConnection'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'isConnection': isConnection,
    };
  }
}
