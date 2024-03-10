import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/models.dart';

class GameCardService extends ChangeNotifier {
  static GameCard defaultGameCard = GameCard(
    name: 'MASTER RACCOON',
    gameId: '1',
    gameMode: GameMode.classic,
    nDifferences: 7,
    numbersOfPlayers: 2,
    thumbnail: 'assets/images/placeholderThumbnail.bmp',
    playerUsernames: ["PlayerOne", "PlayerTwo"],
  );
  static List<GameCard> _gameCards = [defaultGameCard];

  List<GameCard> get gameCards => _gameCards;

  Future<String?> getGameCards() async {
    print('GameCardService.getGameCards()');
    const url = '$API_URL/games/all';

    try {
      print('Enter try');

      final response = await http.get(
        Uri.parse(url),
        // headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('if');
        print('Game card received : ${response.body}');
        String gameCardsServerString = response.body;
        
        return null;
      } else {
        print('else');
        final errorMessage = response.body;
        return errorMessage;
      }
    } catch (error) {
      return 'Error: $error';
    }
  }
}
