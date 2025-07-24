
import 'package:flutter/material.dart';
import 'package:testpoint/src/features/auth/presentation/screens/initial_password_change_screen.dart';
import 'package:testpoint/src/features/auth/presentation/screens/login_screen.dart';
import 'package:testpoint/src/features/dashboard/presentation/screens/student_dashboard_screen.dart';
import 'package:testpoint/src/features/dashboard/presentation/screens/teacher_dashboard_screen.dart';
import 'package:testpoint/src/features/profile/presentation/screens/profile_screen.dart';
import 'package:testpoint/src/features/settings/presentation/screens/settings_screen.dart';

class DevMenuScreen extends StatelessWidget {
  const DevMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Menu'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Go to Login'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InitialPasswordChangeScreen()),
                );
              },
              child: const Text('Go to Password Change'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StudentDashboardScreen()),
                );
              },
              child: const Text('Go to Student Dashboard'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TeacherDashboardScreen()),
                );
              },
              child: const Text('Go to Teacher Dashboard'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: const Text('Go to Profile'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
              child: const Text('Go to Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
