import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/models.dart';

class GameCardService extends ChangeNotifier {
  static List<GameCard> _gameCards = [];

  List<GameCard> get gameCards => _gameCards;

  Future<String?> getGameCards() async {
    const url = '$API_URL/games/cards';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      String gameCardsServerString = response.body;
      List<dynamic> gameCardsJson = jsonDecode(gameCardsServerString);
      _gameCards = gameCardsJson
          .map((gameCardJson) => GameCard.fromJson(gameCardJson))
          .toList();
      notifyListeners();
      return null;
    } else {
      final errorMessage = response.body;
      return errorMessage;
    }
  }
}
