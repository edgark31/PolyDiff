import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/info_service.dart';

class GameRecordProvider extends ChangeNotifier {
  final String baseUrl = "$API_URL/records";
  final InfoService _infoService = Get.find();

  List<GameRecord> _gameRecords = [];

  GameRecord _record = DEFAULT_GAME_RECORD;

  List<GameRecord> get gameRecords => _gameRecords;
  GameRecord get record => _record;

  set currentGameRecord(GameRecord gameRecord) {
    _record = gameRecord;
    print(
        'GameRecord set by default : ${gameRecord.date} for ${gameRecord.game.name}');
    notifyListeners();
  }

  Future<String?> getDefault() async {
    final uri = Uri.parse('$baseUrl/2024-04-11T18:18:37.970+00:00');
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final dynamic body = json.decode(response.body);
        _record = GameRecord.fromJson(body as Map<String, dynamic>);

        notifyListeners();
      }

      return null;
    } catch (error) {
      print('Error record: ${error}');
      return 'Error: $error';
    }
  }

  Future<String?> findAllByAccountId() async {
    final accountId = _infoService.id;
    try {
      final uri = Uri.parse('$baseUrl/$accountId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final dynamic body = jsonDecode(response.body);
        _gameRecords = List<GameRecord>.from(
            body['gameRecords'].map((x) => GameRecord.fromJson(x)));

        // Sets the first one by default as the current game record
        if (_gameRecords.isNotEmpty) {
          _record = _gameRecords.first;

          print(
              'GameRecord set by default after fetching all game records : $accountId');
        }
        notifyListeners();
      }
      return null;
    } catch (error) {
      print('COUCOU Error fetching game record: $error');
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

      if (response.body is Map<String, dynamic>) {
        _record = GameRecord.fromJson(jsonDecode(response.body));

        return;
      } else if (response.body is String) {
        final Map<String, dynamic> parsedRecord = jsonDecode(response.body);
        _record = (GameRecord.fromJson(parsedRecord));
      } else {
        print('Unexpected data format received: ${record.runtimeType}');
      }
    } catch (error) {
      print('Error deleting game record: $error');
    }
  }
}
