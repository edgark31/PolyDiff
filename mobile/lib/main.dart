import 'package:flutter/material.dart';
import 'package:mobile/pages/login_page.dart';
import 'package:provider/provider.dart';

import 'services/socket_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SocketService(),
      child: MaterialApp(
        title: 'PolyDiff',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: LoginPage(),
      ),
    );
  }
}
