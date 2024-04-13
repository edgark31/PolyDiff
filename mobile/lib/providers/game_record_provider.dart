import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/info_service.dart';

class GameRecordProvider extends ChangeNotifier {
  final InfoService _infoService = Get.find();

  final String baseUrl = "$API_URL/records";

  List<GameRecord> _gameRecords = [];
  GameRecord _record = DEFAULT_GAME_RECORD;

  List<GameRecord> get gameRecords => _gameRecords;
  GameRecord get record => _record;

  GameRecordProvider();

  set currentGameRecord(GameRecord gameRecord) {
    _record = gameRecord;
    print(
        'GameRecord set by default : ${gameRecord.date} for ${gameRecord.game.name}');
    notifyListeners();
  }

  Future<String?> findAllByAccountId() async {
    final accountId = _infoService.id;
    // try {
    final uri = Uri.parse('$baseUrl/$accountId');
    final response = await http.get(uri);
    try {
      if (response.statusCode == 200) {
        String gameRecordsServerString = response.body;
        List<dynamic> gameRecordsJson = jsonDecode(gameRecordsServerString);
        // for (var i = 0; i < gameRecordsJson.length; i++) {
        //   print('record $i');
        //   print('date : ${gameRecordsJson[i]['date']}');
        //   print('game : ${gameRecordsJson[i]['game']}');
        //   print('players : ${gameRecordsJson[i]['players']}');
        //   print('observers : ${gameRecordsJson[i]['observers']}');
        //   print('startTime : ${gameRecordsJson[i]['startTime']}');
        //   print('endTime : ${gameRecordsJson[i]['endTime']}');
        //   print('duration : ${gameRecordsJson[i]['duration']}');
        //   print('isCheatEnabled : ${gameRecordsJson[i]['isCheatEnabled']}');
        //   print('timeLimit : ${gameRecordsJson[i]['timeLimit']}');
        //   print('gameEvents : ${gameRecordsJson[i]['gameEvents']}');

        //   GameRecord converted = GameRecord.fromJson(gameRecordsJson[i]);

        //   print('converted record $i');
        //   print('date converted : ${converted.date}');
        //   print('game converted : ${converted.game.toString()}');
        //   print('players converted : ${converted.players.toString()}');
        //   print('observers converted : ${converted.observers.toString()}');
        //   print('startTime converted : ${converted.startTime}');
        //   print('endTime converted : ${converted.endTime}');
        //   print('duration converted : ${converted.duration}');
        //   print('isCheatEnabled converted : ${converted.isCheatEnabled}');
        //   print('timeLimit converted : ${converted.timeLimit}');
        //   print('gameEvents converted : ${converted.gameEvents.toString()}');
        // }

        _gameRecords = gameRecordsJson
            .map((gameRecordJson) => GameRecord.fromJson(gameRecordJson))
            .toList();
        notifyListeners();
      }
      return null;
    } catch (error) {
      print('Error fetching game record: $error');
      return 'Error: $error';
    }
  }

  Future<void> getByDate(String date) async {
    final accountId = _infoService.id;
    try {
      final uri = Uri.parse('$baseUrl/$date');
      final response = await http.get(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        _record = GameRecord.fromJson(body);
        print(
            "GameRecord fetch for accountId : $accountId and record date : $date");
        notifyListeners();
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error saving game record: $error');
    }
  }

  Future<void> deleteAccountId(String date) async {
    final accountId = _infoService.id;
    try {
      final uri = Uri.parse('$baseUrl/$accountId')
          .replace(queryParameters: {'date': date});
      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        print(
            "GameRecord removed from saved for accountId : $accountId and username :  ${_infoService.username}");
        notifyListeners();
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error deleting game record: $error');
    }
  }
}
