import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/settings_provider.dart';
import 'config/app_theme.dart';
import 'screens/splash_screen.dart'; 

void main() async {
  // Ensure Flutter bindings are initialized before calling native code
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock the game to portrait mode
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  runApp(
    // Inject the SettingsProvider at the root of the app
    ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: const GridSnapApp(),
    ),
  );
}

class GridSnapApp extends StatelessWidget {
  const GridSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the settings provider for changes (like toggling Dark Mode)
    final settings = context.watch<SettingsProvider>();
    
    return MaterialApp(
      title: 'GridSnap',
      debugShowCheckedModeBanner: false,
      
      // Theme Data mapped from our AppTheme class
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      
      // Dynamically switch based on the user's saved preference
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      // Start the app with the Splash Screen (which will route to HomeScreen)
      home: const SplashScreen(),
    );
  }
}
