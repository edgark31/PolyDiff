import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/models.dart';

class GameCardProvider {
  final String baseUrl;

  GameCardProvider({this.baseUrl = API_URL});

  Future<GameCard> getById() async {
    final response = await http.get(Uri.parse('$baseUrl/games/carousel/0'));

    if (response.statusCode == 200) {
      Map<String, dynamic> body = jsonDecode(response.body);
      GameCard gameCard = GameCard.fromJson(body);
      return gameCard;
    } else {
      throw Exception('Failed to load GameCard with ID 0');
    }
  }

  Future<List<GameCard>> getAll() async {
    final response = await http.get(Uri.parse('$baseUrl/games/carousel'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<GameCard> gameCards =
          body.map((dynamic item) => GameCard.fromJson(item)).toList();
      return gameCards;
    } else {
      throw Exception('Failed to load GameCards');
    }
  }
}
