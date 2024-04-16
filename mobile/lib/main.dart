import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/app_text_constants.dart';
import 'package:mobile/pages/sign_in_page.dart';
import 'package:mobile/providers/avatar_provider.dart';
import 'package:mobile/providers/camera_image_provider.dart';
import 'package:mobile/providers/game_record_provider.dart';
import 'package:mobile/providers/register_provider.dart';
import 'package:mobile/providers/theme_provider.dart';
import 'package:mobile/replay/game_event_playback_manager.dart';
import 'package:mobile/replay/game_events_services.dart';
import 'package:mobile/replay/replay_images_provider.dart';
import 'package:mobile/replay/replay_player_provider.dart';
import 'package:mobile/services/chat_service.dart';
import 'package:mobile/services/form_service.dart';
import 'package:mobile/services/friend_service.dart';
import 'package:mobile/services/game_area_service.dart';
import 'package:mobile/services/game_card_service.dart';
import 'package:mobile/services/game_manager_service.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/lobby_selection_service.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:mobile/services/socket_service.dart';
import 'package:mobile/services/sound_service.dart';
import 'package:mobile/utils/theme_utils.dart';
import 'package:provider/provider.dart';

Widget defaultHome = SignInPage();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeServices();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => CameraImageProvider()),
    ChangeNotifierProvider(create: (context) {
      RegisterProvider registerProvider = Get.find();
      return registerProvider;
    }),
    ChangeNotifierProvider(create: (context) {
      SocketService socketService = Get.find();
      return socketService;
    }),
    ChangeNotifierProvider(create: (context) {
      InfoService infoService = Get.find();
      return infoService;
    }),
    ChangeNotifierProvider(create: (context) {
      FormService formService = Get.find();
      return formService;
    }),
    ChangeNotifierProvider(create: (context) {
      SoundService soundService = Get.find();
      return soundService;
    }),
    ChangeNotifierProvider(create: (context) {
      GameAreaService gameAreaService = Get.find();
      return gameAreaService;
    }),

    ChangeNotifierProvider(create: (context) {
      LobbySelectionService lobbySelectionService = Get.find();
      return lobbySelectionService;
    }),
    ChangeNotifierProvider(create: (context) {
      LobbyService lobbyService = Get.find();
      return lobbyService;
    }),

    ChangeNotifierProvider(create: (context) {
      ReplayPlayerProvider replayPlayerProvider = Get.find();
      return replayPlayerProvider;
    }),
    ChangeNotifierProvider(create: (context) {
      ReplayImagesProvider replayImagesProvider = Get.find();
      return replayImagesProvider;
    }),
    ChangeNotifierProvider(create: (context) {
      GameRecordProvider gameRecordProvider = Get.find();
      return gameRecordProvider;
    }),
    ChangeNotifierProvider(create: (context) {
      GameManagerService gameManagerService = Get.find();
      return gameManagerService;
    }),
    ChangeNotifierProvider(create: (context) {
      ChatService chatService = Get.find();
      return chatService;
    }),
    ChangeNotifierProvider(create: (context) {
      GameCardService gameCardService = Get.find();
      return gameCardService;
    }),
    ChangeNotifierProvider(create: (context) {
      FriendService friendService = Get.find();
      return friendService;
    }),
    // Avatar
    ChangeNotifierProvider(create: (context) {
      AvatarProvider avatarProvider = Get.find();
      return avatarProvider;
    }),
    ChangeNotifierProvider(create: (context) {
      ThemeProvider themeProvider = Get.find();
      return themeProvider;
    }),

    ChangeNotifierProvider(create: (context) {
      GameEventPlaybackService playbackService = Get.find();
      return playbackService;
    }),

    ChangeNotifierProvider(create: (context) {
      GameEventPlaybackManager playbackManager = Get.find();
      return playbackManager;
    }),
  ], child: const MyApp()));
}

void initializeServices() {
  Get.put(SocketService());
  Get.put(InfoService());
  Get.put(FormService());
  Get.put(SoundService());
  Get.put(GameAreaService());
  Get.put(LobbySelectionService());
  Get.put(LobbyService());
  Get.put(ReplayPlayerProvider());
  Get.put(ReplayImagesProvider());
  Get.put(GameRecordProvider());
  Get.put(GameEventPlaybackService());
  Get.put(GameEventPlaybackManager());
  Get.put(GameManagerService());
  Get.put(ChatService());
  Get.put(GameCardService());
  Get.put(FriendService());
  Get.put(AvatarProvider());
  Get.put(RegisterProvider());
  Get.put(ThemeProvider());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = Get.find();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: APP_NAME_TXT,
      themeMode: themeProvider.themeMode,
      theme: ThemeClass.lightTheme,
      darkTheme: ThemeClass.darkTheme,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: SignInPage.routeName,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
