import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testpoint/core/theme/app_theme.dart';
import 'package:testpoint/core/services/auth_service.dart';
import 'package:testpoint/providers/auth_provider.dart';
import 'package:testpoint/routing/app_router.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(AuthService()),
      child: Builder(
        builder: (context) {
          final authProvider = Provider.of<AuthProvider>(context);
          return MaterialApp.router(
            title: 'Test Point',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: router(authProvider),
          );
        },
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(); // This widget is now just a placeholder
  }
}
