import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/game_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const GridSnapApp());
}

class GridSnapApp extends StatelessWidget {
  const GridSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: GameTheme.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: GameTheme.bgPrimary,
      ),
      home: const SplashScreen(),
    );
  }
}
