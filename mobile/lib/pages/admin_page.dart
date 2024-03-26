import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/game_card_service.dart';
import 'package:mobile/widgets/customs/custom_app_bar.dart';
import 'package:provider/provider.dart';

class AdminPage extends StatefulWidget {
  static const routeName = ADMIN_ROUTE;

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => AdminPage(),
      settings: RouteSettings(name: routeName),
    );
  }

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool isLoading = false;
  bool _isFetchingGameCards = false;
  String errorMessage = "";
  final GameCardService gameCardService = Get.find();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isFetchingGameCards) {
      _isFetchingGameCards = true;
      _fetchGameCards();
    }
  }

  Future<void> _fetchGameCards() async {
    setState(() => isLoading = true);
    final gameCardService =
        Provider.of<GameCardService>(context, listen: false);
    String? serverErrorMessage = await gameCardService.getGameCards();
    if (mounted) {
      setState(() {
        isLoading = false;
        if (serverErrorMessage != null) {
          errorMessage = serverErrorMessage;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameCardService = context.watch<GameCardService>();
    final gameCardsFromServer = gameCardService.gameCards;
    if (isLoading) return CircularProgressIndicator();
    return Scaffold(
      appBar: CustomAppBar(
        title: "Page d'administration",
      ),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  gameCardsFromServer.clear();
                  //TODO: Implementer le vrai delete all
                });
              },
              child: Text('Supprimer tous les jeux'),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: GridView.builder(
                padding: EdgeInsets.all(8.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: gameCardsFromServer.length,
                itemBuilder: (context, index) {
                  return AdminGame(
                    game: gameCardsFromServer[index],
                    onDelete: () {
                      setState(() {
                        gameCardService
                            .deleteGameById(gameCardsFromServer[index].id);
                        setState(() {
                          isLoading = true;
                        });
                        Future.delayed(Duration(milliseconds: 500), () {
                          _fetchGameCards();
                        });
                      });
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminGame extends StatelessWidget {
  final GameCard game;
  final VoidCallback onDelete;

  const AdminGame({super.key, required this.game, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    String imagePath = '$BASE_URL/${game.id}/original.bmp';
    return Card(
      child: Column(
        children: [
          Text(
            game.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
              child: Image.network(
            imagePath,
            fit: BoxFit.cover,
          )),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
