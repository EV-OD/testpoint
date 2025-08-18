import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:testpoint/firebase_options.dart';
import 'package:testpoint/core/theme/app_theme.dart';
import 'package:testpoint/core/services/auth_service.dart';
import 'package:testpoint/providers/auth_provider.dart';
import 'package:testpoint/providers/test_provider.dart';
import 'package:testpoint/providers/teacher_dashboard_provider.dart';
import 'package:testpoint/providers/student_provider.dart';
import 'package:testpoint/providers/student_statistics_provider.dart';
import 'package:testpoint/providers/anti_cheat_provider.dart';
import 'package:testpoint/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with proper error handling
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    // If Firebase is already initialized, continue
    print('Firebase initialization: $e');
  }
  
  print('Starting app...');
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(AuthService()),
        ),
        ChangeNotifierProvider(
          create: (context) => TestProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => TeacherDashboardProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => StudentProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => StudentStatisticsProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => AntiCheatProvider(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final authProvider = Provider.of<AuthProvider>(context);
          print('Building MaterialApp with router...');
          return MaterialApp.router(
            title: 'Test Point',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: router(authProvider),
            debugShowCheckedModeBanner: false,
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
