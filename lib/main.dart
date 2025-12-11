import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'models/habit.dart';
import 'models/habit_adapter.dart';
import 'models/habit_completion.dart';
import 'models/habit_completion_adapter.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(HabitCompletionAdapter());
  
  // Initialize timezone
  tz.initializeTimeZones();
  
  // Initialize notifications
  await NotificationService().init();
  
  runApp(
    const ProviderScope(
      child: SmartHabitTrackerApp(),
    ),
  );
}

class SmartHabitTrackerApp extends ConsumerWidget {
  const SmartHabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'Smart Habit Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
