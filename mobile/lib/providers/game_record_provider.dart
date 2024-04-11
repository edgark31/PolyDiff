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

  final String baseUrl = "$API_URL/records/";

  GameRecord _record = DEFAULT_GAME_RECORD;

  List<GameRecord> _gameRecords = [];

  List<GameRecord> get gameRecords => _gameRecords;
  GameRecord get record => _record;

  GameRecordProvider();

  set currentGameRecord(GameRecord gameRecord) {
    _record = gameRecord;
    notifyListeners();
  }

  Future<String?> findAllByAccountId() async {
    final accountId = _infoService.id;
    try {
      final uri = Uri.parse('$baseUrl/records/$accountId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        _gameRecords =
            body.map((dynamic item) => GameRecord.fromJson(item)).toList();

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
