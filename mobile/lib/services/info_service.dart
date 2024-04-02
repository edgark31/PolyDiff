import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/models/models.dart';

class InfoService extends ChangeNotifier {
  static late Credentials credentials;
  static String _username = 'temp_name';
  static String _id = 'temp_id';
  static String _email = 'temp_email';
  static String _theme = 'light';
  static String _language = 'fr';
  static Sound _onErrorSound = DEFAULT_ON_ERROR_SOUND;
  static Sound _onCorrectSound = DEFAULT_ON_CORRECT_SOUND;
  static Statistics _statistics = Statistics(
    gamesPlayed: 0,
    gameWon: 0,
    averageTime: 0,
    averageDifferences: 0,
  );
  static List<ConnectionLog> _connections = [];
  static List<SessionLog> _sessions = [];

  String get username => _username;
  String get id => _id;

  String get email => _email;
  String get language => _language;
  String get theme => _theme;
  Sound get onErrorSound => _onErrorSound;
  Sound get onCorrectSound => _onCorrectSound;
  Statistics get statistics => _statistics;
  List<ConnectionLog> get connections => _connections;
  List<SessionLog> get sessions => _sessions;

  void setId(String newId) {
    // print('Changing id from $_id to $newId');
    _id = newId;
    notifyListeners();
  }

  void setUsername(String newName) {
    print('Changing name from $_username to $newName for ($_id)');
    _username = newName;
    notifyListeners();
  }

  void setEmail(String? newEmail) {
    if (newEmail != null) {
      // print('Changing email from $_email to $newEmail for $username ($_id)');
      _email = newEmail;
      notifyListeners();
    }
  }

    void setSessions(List<SessionLog> newSessions) {
    String oldSessions =
        _sessions.map((c) => c.toJson().toString()).join(', ');
    String newSessionsString =
        newSessions.map((c) => c.toJson().toString()).join(', ');
    print(
        'Changing sessions from $oldSessions to $newSessionsString for $username ($_id)');
    _sessions = newSessions;
    notifyListeners();
  }

  void setConnections(List<ConnectionLog> newConnections) {
    String oldConnections =
        _connections.map((c) => c.toJson().toString()).join(', ');
    String newConnectionsString =
        newConnections.map((c) => c.toJson().toString()).join(', ');
    print(
        'Changing connections from $oldConnections to $newConnectionsString for $username ($_id)');
    _connections = newConnections;
    notifyListeners();
  }

  void setStatistics(Statistics newStatistics) {
    print(
        'Changing statistics from ${_statistics.toJson()} to ${newStatistics.toJson()} for $username ($_id)');
    _statistics = newStatistics;
    notifyListeners();
  }

  void setTheme(String newTheme) {
    print('Changing theme from $_theme to $newTheme for $username ($_id)');
    _theme = newTheme;
    notifyListeners();
  }

  void setOnErrorSound(Sound newOnErrorSound) {
    print(
        'Changing onErrorSoundId from $_onErrorSound to $newOnErrorSound for $username ($_id)');
    _onErrorSound = newOnErrorSound;
    notifyListeners();
  }

  void setOnCorrectSound(Sound newOnCorrectSound) {
    print(
        'Changing onCorrectSoundId from $_onCorrectSound to $newOnCorrectSound for $username ($_id)');
    _onCorrectSound = newOnCorrectSound;
  }

  void setLanguage(String newLanguage) {
    print(
        'Changing language from $_language to $newLanguage for $username ($_id)');
    _language = newLanguage;
    notifyListeners();
  }

  void setCredentials(Credentials credentialsReceived) {
    credentials = credentialsReceived;
    setUsername(credentials.username);
    setEmail(credentials.email);
  }

  void setInfosOnConnection(String serverConnectionResponse) {
    final result = jsonDecode(serverConnectionResponse) as Map<String, dynamic>;

    print('result: $result');

    // print('id: ${result['id']}');
    setId(result['id']);

    // print('credentials: ${result['credentials']}');
    final credentials = Credentials.fromJson(result['credentials']);
    final onErrorSound = Sound.fromJson(result['profile']['onErrorSound']);
    final onCorrectSound = Sound.fromJson(result['profile']['onCorrectSound']);
    final statistics = Statistics.fromJson(result['profile']['stats']);
    final connections = List<ConnectionLog>.from(result['profile']
            ['connections']
        .map((connection) => ConnectionLog.fromJson(connection)));
    final sessions = List<SessionLog>.from(result['profile']
            ['sessions']
        .map((session) => SessionLog.fromJson(session)));

    setCredentials(credentials);
    setStatistics(statistics);
    setConnections(connections);
    setSessions(sessions);

    setTheme(result['profile']['mobileTheme']);
    setLanguage(result['profile']['language']);
    setOnCorrectSound(onCorrectSound);
    setOnErrorSound(onErrorSound);
  }
}
