import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'services/audio_handler.dart';
import 'screens/home_screen.dart';

late MyAudioHandler audioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    audioHandler = await AudioService.init(
      builder: () => MyAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.zentask.zenfocus.channel.audio',
        androidNotificationChannelName: 'ZenFocus Calm Music',
        androidNotificationOngoing: true,
        androidShowNotificationBadge: true,
      ),
    );
  } catch (e) {
    debugPrint('AudioService init failed: $e');
  }

  runApp(const ZenTaskApp());
}

class ZenTaskApp extends StatelessWidget {
  const ZenTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Custom premium HSL-aligned color palette
    final ColorScheme darkColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1), // Indigo
      brightness: Brightness.dark,
      surface: const Color(0xFF18181C), // Obsidian surface/cards
      primary: const Color(0xFF6366F1), // Indigo accents
      secondary: const Color(0xFF00F5D4), // Mint Green accent
      error: const Color(0xFFF72585), // Coral Red error/alert
    );

    return MaterialApp(
      title: 'ZenTask',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        scaffoldBackgroundColor: const Color(0xFF0F0F12), // Obsidian background
        cardColor: darkColorScheme.surface,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: darkColorScheme.secondary,
          foregroundColor: const Color(0xFF0F0F12),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: darkColorScheme.surface,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
