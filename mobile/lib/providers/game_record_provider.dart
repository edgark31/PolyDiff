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
    try {
      final uri = Uri.parse('$baseUrl/$accountId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        String gameRecordsServerString = response.body;
        List<dynamic> gameRecordsJson = jsonDecode(gameRecordsServerString);
        // print(gameRecordsJson);
        for (var i = 0; i < gameRecordsJson.length; i++) {
          print('record $i');
          print('date : ${gameRecordsJson[i]['date']}');
          print('game : ${gameRecordsJson[i]['game']}');
          print('players : ${gameRecordsJson[i]['players']}');
          print('observers : ${gameRecordsJson[i]['observers']}');
          print('startTime : ${gameRecordsJson[i]['startTime']}');
          print('endTime : ${gameRecordsJson[i]['endTime']}');
          print('duration : ${gameRecordsJson[i]['duration']}');
          print('isCheatEnabled : ${gameRecordsJson[i]['isCheatEnabled']}');
          print('timeLimit : ${gameRecordsJson[i]['timeLimit']}');
          print('gameEvents : ${gameRecordsJson[i]['gameEvents']}');

          GameRecord converted = GameRecord.fromJson(gameRecordsJson[i]);

          print('converted record $i');
          print('date converted : ${converted.date}');
          print('game converted : ${converted.game.toString()}');
          print('players converted : ${converted.players.toString()}');
          print('observers converted : ${converted.observers.toString()}');
          print('startTime converted : ${converted.startTime}');
          print('endTime converted : ${converted.endTime}');
          print('duration converted : ${converted.duration}');
          print('isCheatEnabled converted : ${converted.isCheatEnabled}');
          print('timeLimit converted : ${converted.timeLimit}');
          print('gameEvents converted : ${converted.gameEvents.toString()}');
        }
        // Map<String, dynamic> firstGameRecord = gameRecordsJson[0];
        // print('first record');
        // print('date : ${firstGameRecord['date']}');
        // print('game : ${firstGameRecord['game']}');
        // print('players : ${firstGameRecord['players']}');
        // print('observers : ${firstGameRecord['observers']}');
        // print('startTime : ${firstGameRecord['startTime']}');
        // print('endTime : ${firstGameRecord['endTime']}');
        // print('duration : ${firstGameRecord['duration']}');
        // print('isCheatEnabled : ${firstGameRecord['isCheatEnabled']}');
        // print('timeLimit : ${firstGameRecord['timeLimit']}');
        // print('gameEvents : ${firstGameRecord['gameEvents']}');
        // // print(firstGameRecord);

        // // _gameRecords = gameRecordsJson
        // //     .map((gameRecordJson) => GameRecord.fromJson(gameRecordJson))
        // //     .toList();
        // print('Game Records converted');
        // GameRecord firstGameRecordConverted =
        //     GameRecord.fromJson(firstGameRecord);
        // // print(firstGameRecordConverted.toString());
        // print('date converted : ${firstGameRecordConverted.date}');
        // print('game converted : ${firstGameRecordConverted.game.toString()}');
        // print(
        //     'players converted : ${firstGameRecordConverted.players.toString()}');
        // print(
        //     'observers converted : ${firstGameRecordConverted.observers.toString()}');
        // print('startTime converted : ${firstGameRecordConverted.startTime}');
        // print('endTime converted : ${firstGameRecordConverted.endTime}');
        // print('duration converted : ${firstGameRecordConverted.duration}');
        // print(
        //     'isCheatEnabled converted : ${firstGameRecordConverted.isCheatEnabled}');
        // print('timeLimit converted : ${firstGameRecordConverted.timeLimit}');
        // print(
        //     'gameEvents converted : ${firstGameRecordConverted.gameEvents.toString()}');
        // print(_gameRecords);
        // final List<dynamic> body = json.decode(response.body);
        // _gameRecords =
        //     body.map((dynamic item) => GameRecord.fromJson(item)).toList();

        // // Sets the first one by default as the current game record
        // if (_gameRecords.isNotEmpty) {
        //   _record = _gameRecords.first;

        //   print(
        //       'GameRecord set by default after fetching all game records : $accountId');
        // }
        // notifyListeners();
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
