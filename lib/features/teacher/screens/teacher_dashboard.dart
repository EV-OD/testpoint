
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testpoint/providers/auth_provider.dart';
import 'package:testpoint/features/shared/widgets/app_bottom_navigation.dart';
import 'package:testpoint/features/teacher/screens/teacher_profile_screen.dart';
import 'package:testpoint/features/teacher/screens/teacher_settings_screen.dart';
import 'package:testpoint/features/teacher/widgets/test_list_view.dart';

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
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Pending Tests'),
              Tab(text: 'Completed Tests'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildTestList(isCompleted: false),
                _buildTestList(isCompleted: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestList({required bool isCompleted}) {
    // TODO: Replace with actual data from backend
    final dummyTests = [
      Test(
        id: '1',
        name: 'Mathematics Test 1',
        group: 'Grade 10',
        scheduledDate: DateTime.now().add(const Duration(days: 2)),
        duration: 60,
        isCompleted: isCompleted,
      ),
      Test(
        id: '2',
        name: 'Science Quiz',
        group: 'Grade 11',
        scheduledDate: DateTime.now().add(const Duration(days: 5)),
        duration: 45,
        isCompleted: isCompleted,
      ),
    ];

    return TestListView(
      tests: dummyTests.where((test) => test.isCompleted == isCompleted).toList(),
      isCompletedTab: isCompleted,
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
      floatingActionButton: _selectedItem == NavigationItem.dashboard
          ? FloatingActionButton.extended(
              onPressed: () {
                // TODO: Navigate to create test screen
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Test'),
            )
          : null,
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
