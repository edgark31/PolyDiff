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

  GameRecord _record = DEFAULT_GAME_RECORD;

  List<GameRecord> _gameRecords = [];
  List<GameRecordCard> _gameRecordCards = [];

  List<GameRecord> get gameRecords => _gameRecords;
  GameRecord get record => _record;

  GameRecordProvider();

  setCurrentGameRecord(GameRecord gameRecord) {
    _record = gameRecord;
    notifyListeners();
  }

  Future<String?> getDefault() async {
    final url = Uri.parse('$baseUrl/2024-04-07T23:53:19.447+00:00');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        _record = GameRecord.fromJson(jsonDecode(response.body));
        print("Default GameRecord fetched gamerecord ${_record.game.name}");

        print("Default GameRecord fetched for ${_infoService.username}");

        notifyListeners();
      } else {
        print('Server error: ${response.statusCode}');
        return 'Server error: ${response.statusCode}';
      }
      return null;
    } catch (error) {
      print('Error fetching game record: $error');
      return 'Error: $error';
    }
  }

  // Returns the selected replay from profile page
  Future<String?> getByDate(String date) async {
    final url = Uri.parse('$baseUrl/$date');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        _record = GameRecord.fromJson(jsonDecode(response.body));

        print("GameRecord with $date fetched for ${_infoService.username}");
        notifyListeners();
      } else {
        print('Server error: ${response.statusCode}');
        return 'Server error: ${response.statusCode}';
      }
      return null;
    } catch (error) {
      print('Error fetching game record: $error');
      return 'Error: $error';
    }
  }

  Future<String?> getAll() async {
    final accountId = _infoService.id;
    final url = Uri.parse('$baseUrl?accountId=$accountId');

    try {
      final response = await http.get(url);
      final List<dynamic> decodedJson = json.decode(response.body);

      _gameRecords = decodedJson
          .map((gameRecord) => GameRecord.fromJson(gameRecord))
          .toList();

      // To previewing the game records in the profile page
      _gameRecordCards = _gameRecords
          .map((gameRecord) => GameRecordCard.fromGameRecord(gameRecord))
          .toList();

      print("GameRecords fetched for ${_infoService.username}");
      notifyListeners();
      return null;
    } catch (error) {
      print('Error fetching game records: $error');
      return 'Error: $error';
    }
  }

  Future<String?> addAccountIdByDate(String date) async {
    final accountId = _infoService.id;
    final url = Uri.parse('$baseUrl/$date?accountId=$accountId');

    try {
      final response = await http.put(url);
      if (response.statusCode == 200) {
        print("AccountId added for ${_infoService.username}");
        notifyListeners();
        return null;
      } else {
        print('Server error: ${response.statusCode}');
        return "Failed to fetch GameRecord with date : $date";
      }
    } catch (error) {
      print('Error fetching game record: $error');
      return 'Error: $error';
    }
  }

  // deletes the selected game record from profile page
  Future<String?> deleteAccountIdByDate(String date) async {
    final accountId = _infoService.id;
    final url = Uri.parse('$baseUrl/$date?accountId=$accountId');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        print("GameRecord deleted for ${_infoService.username}");
        notifyListeners();
        return null;
      } else {
        print('Server error: ${response.statusCode}');
        return "Failed to fetch GameRecord with date : $date response status : ${response.statusCode}";
      }
    } catch (error) {
      print('Error fetching game record: $error');
      return 'Error: $error';
    }
  }

  setGameRecordByDate(String date) {
    _record = _gameRecords.firstWhere((gameRecord) => gameRecord.date == date);
    notifyListeners();
  }
}
