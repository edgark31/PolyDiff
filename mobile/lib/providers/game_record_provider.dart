import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/info_service.dart';

class GameRecordProvider extends ChangeNotifier {
  final String baseUrl = API_URL;
  final InfoService _infoService = Get.find();

  GameRecord _gameRecord = DEFAULT_GAME_RECORD;

  List<GameRecord> _gameRecords = [];
  List<GameRecord> get gameRecords => _gameRecords;
  GameRecord get gameRecord => _gameRecord;

  GameRecordProvider();

  setCurrentGameRecord(GameRecord gameRecord) {
    _gameRecord = gameRecord;
    notifyListeners();
  }

  // Returns the selected replay from profile page
  Future<String?> getByDate(String date) async {
    final url = Uri.parse('$baseUrl/games/records/$date');

    try {
      final response = await http.get(url);

      _gameRecord = GameRecord.fromJson(response.body as Map<String, dynamic>);
      print("GameRecord with $date fetched for ${_infoService.username}");
      notifyListeners();
      return null;
    } catch (error) {
      return 'Error: $error';
    }
  }

  Future<String?> addAccountIdByDate(String date) async {
    final accountId = _infoService.id;
    final url = Uri.parse('$baseUrl/games/records/$date');

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"accountId": accountId}),
      );

      if (response.statusCode == 200) {
        print("AccountId added for ${_infoService.username}");
        notifyListeners();
        return null;
      } else {
        return "Failed to fetch GameRecord with date : $date";
      }
    } catch (error) {
      return 'Error: $error';
    }
  }

  // deletes the selected game record from profile page

  Future<String?> deleteAccountIdByDate(String date) async {
    final accountId = _infoService.id;
    final url = Uri.parse('$baseUrl/games/records/$date');

    try {
      final response = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"accountId": accountId}),
      );

      if (response.statusCode == 200) {
        print("GameRecord deleted for ${_infoService.username}");
        notifyListeners();
        return null;
      } else {
        return "Failed to fetch GameRecord with date : $date response status : ${response.statusCode}";
      }
    } catch (error) {
      return 'Error: $error';
    }
  }
}
