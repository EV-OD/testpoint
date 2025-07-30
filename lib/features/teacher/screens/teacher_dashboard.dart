
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testpoint/providers/auth_provider.dart';
import 'package:testpoint/features/shared/widgets/app_bottom_navigation.dart';
import 'package:testpoint/features/teacher/screens/teacher_profile_screen.dart';
import 'package:testpoint/features/teacher/screens/teacher_settings_screen.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  NavigationItem _selectedItem = NavigationItem.dashboard;

  Widget _buildSelectedScreen() {
    switch (_selectedItem) {
      case NavigationItem.dashboard:
        return _buildDashboardContent();
      case NavigationItem.profile:
        return const TeacherProfileScreen();
      case NavigationItem.settings:
        return const TeacherSettingsScreen();
    }
  }

  Widget _buildDashboardContent() {
    final authProvider = Provider.of<AuthProvider>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Welcome, ${authProvider.currentUser?.name ?? 'Teacher'}!'),
          Text('Role: ${authProvider.currentUser?.role.toString().split('.').last ?? 'N/A'}'),
          // TODO: Add tabs for pending and completed tests
          // TODO: Add FloatingActionButton for test creation
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedItem == NavigationItem.dashboard 
            ? 'Teacher Dashboard'
            : _selectedItem.name[0].toUpperCase() + _selectedItem.name.substring(1)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: authProvider.isLoginLoading
                ? null
                : () async {
                    await authProvider.logout();
                  },
          ),
        ],
      ),
      body: _buildSelectedScreen(),
      bottomNavigationBar: AppBottomNavigation(
        selectedItem: _selectedItem,
        onItemSelected: (item) {
          setState(() {
            _selectedItem = item;
          });
        },
      ),
    );
  }
}
