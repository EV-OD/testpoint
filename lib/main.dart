import 'package:flutter/material.dart';
import 'package:testpoint/src/core/theme/app_theme.dart';
import 'package:testpoint/src/features/dev_menu/presentation/screens/dev_menu_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Point',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Automatically switch between light and dark mode
      home: const DevMenuScreen(),
    );
  }
}




