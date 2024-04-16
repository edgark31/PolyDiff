import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/canvas_model.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/replay/replay_images_provider.dart';
import 'package:mobile/replay/replay_player_provider.dart';
import 'package:mobile/services/info_service.dart';

class GameRecordProvider extends ChangeNotifier {
  final InfoService _infoService = Get.find();
  final ReplayPlayerProvider _players = Get.find();
  final ReplayImagesProvider _imagesProvider = Get.find();

  final String baseUrl = "$API_URL/records";

  List<GameRecord> _gameRecords = [];
  GameRecord _record = DEFAULT_GAME_RECORD;
  bool _isFromProfile = false;

  List<GameRecord> get gameRecords => _gameRecords;
  GameRecord get record => _record;

  Future<CanvasModel>? get currentCanvas => _imagesProvider.currentCanvas;
  List<Player> get playersData => _players.data;
  int get nObservers => _players.nObservers;
  int get timeLimit => _record.timeLimit;
  bool get isFromProfile => _isFromProfile;
  bool get hasCheatEnabled => _record.isCheatEnabled;

  set currentGameRecord(GameRecord gameRecord) {
    try {
      _record = gameRecord;
      _players.initialPlayersData = gameRecord.players;
      _players.initialNumberOfObservers = gameRecord.observers?.length ?? 0;
      print('GameRecord set: ${gameRecord.date} for ${gameRecord.game.name}');
    } catch (e) {
      print('Failed to set game record: $e');
    }
    notifyListeners();
  }

  set isPlaybackFromProfile(bool newIsFromProfile) {
    _isFromProfile = newIsFromProfile;
    print("Game provider _isFromProfile set : $_isFromProfile");
    notifyListeners();
  }

  void setIsFromProfile(bool newIsFromProfile) {
    _isFromProfile = newIsFromProfile;
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
      }
      print(
          "Fetched all games record : ${_gameRecords.length} for accountId : $accountId");
      notifyListeners();
      return null;
    } catch (error) {
      return 'Error: $error';
    }
  }

  Future<void> getByDate(String date) async {
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
        _players.initialPlayersData = _record.players;
        if (_record.observers != null) {
          _players.initialNumberOfObservers = _record.observers!.length;
        } else {
          _players.initialNumberOfObservers = 0;
        }

        print(
            "Players : ${_players.data.map((player) => player.name)} and observers : ${_players.nObservers} for game record : ${_record.date} ");
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
      print('Deleting game record for accountId : $accountId and date : $date');
      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        print(
            "GameRecord removed from saved for accountId : $accountId and username :  ${_infoService.username}");
        _gameRecords.removeWhere((element) => element.date == date);
        _gameRecords.removeWhere((element) => element.date == date);
        notifyListeners();
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error deleting game record: $error');
    }
  }
}
