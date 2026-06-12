import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';
import 'services/user_profile_service.dart';
import 'services/health_history_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProfileService>(create: (_) => UserProfileService()),
        ChangeNotifierProvider<HealthHistoryService>(create: (_) => HealthHistoryService()),
        ProxyProvider<UserProfileService, ApiService>(
          update: (_, profile, __) => ApiService(baseUrl: profile.serverUrl),
        ),
      ],
      child: const HealProApp(),
    ),
  );
}

class HealProApp extends StatelessWidget {
  const HealProApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<UserProfileService>().themeMode;
    return MaterialApp(
      title: 'HealPRO AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}
