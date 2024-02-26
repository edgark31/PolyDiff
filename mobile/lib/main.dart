import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/pages/avatar_selection_page.dart';
import 'package:mobile/pages/home_page.dart';
import 'package:mobile/providers/camera_image_provider.dart';
import 'package:provider/provider.dart';

import 'services/socket_service.dart';

Widget defaultHome = HomePage();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => CameraImageUploader()),
    ChangeNotifierProvider(create: (context) => SocketService()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(builder: (context, child) {
      return MaterialApp(
        title: 'PolyDiff',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color(kLightGreen.value)),
        ),
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: AvatarSelectionPage.routeName,
      );
    });
  }
}
