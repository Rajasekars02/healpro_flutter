import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
      ],
      child: const HealProApp(),
    ),
  );
}

class HealProApp extends StatelessWidget {
  const HealProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealPRO AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Or based on settings
      home: const HomeScreen(),
    );
  }
}
