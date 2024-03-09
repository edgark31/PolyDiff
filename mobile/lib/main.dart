import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/pages/classic_game_page.dart';
import 'package:mobile/pages/home_page.dart';
import 'package:mobile/services/game_area_service.dart';
import 'package:mobile/services/socket_service.dart';
import 'package:mobile/services/sound_service.dart';
import 'package:provider/provider.dart';

Widget defaultHome = HomePage();

void main() async {
  initializeServices();
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) {
      GameAreaService gameAreaService = Get.find();
      return gameAreaService;
    }),
  ], child: const MyApp()));
}

void initializeServices() {
  Get.put(SocketService());
  Get.put(GameAreaService());
  Get.put(SoundService());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PolyDiff',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Color(kLightGreen.value)),
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: ClassicGamePage.routeName,
    );
  }
}
