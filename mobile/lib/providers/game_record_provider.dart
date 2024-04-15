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

  bool _isFromProfile = false;
  List<GameRecord> _gameRecords = [];
  GameRecord _record = DEFAULT_GAME_RECORD;

  // bool get isFromProfile => _isFromProfile;
  List<GameRecord> get gameRecords => _gameRecords;
  GameRecord get record => _record;

  GameRecordProvider();

  set currentGameRecord(GameRecord gameRecord) {
    _record = gameRecord;
    print(
        'GameRecord set by default : ${gameRecord.date} for ${gameRecord.game.name}');
    notifyListeners();
  }

  void setIsFromProfile(bool newIsFromProfile) {
    _isFromProfile = newIsFromProfile;
  }

  bool isFromProfile() {
    return _isFromProfile;
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

        _gameRecords = gameRecordsJson
            .map((gameRecordJson) => GameRecord.fromJson(gameRecordJson))
            .toList();
        notifyListeners();
      }
      return null;
    } catch (error) {
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
      print('Deleting game record for accountId : $accountId and date : $date');
      // Yes, the date is the accountId and the accountId is the date
      // Reverted because of a bug in the client DO NOT TOUCH
      final uri = Uri.parse('$baseUrl/$date')
          .replace(queryParameters: {'date': accountId});
      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        print(
            "GameRecord removed from saved for accountId : $accountId and username :  ${_infoService.username}");
        _gameRecords.removeWhere((element) => element.date == date);
        notifyListeners();
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error deleting game record: $error');
    }
  }

  @override
  void dispose() {
    _gameRecords = [];
    super.dispose();
  }
}
