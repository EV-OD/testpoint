
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testpoint/providers/auth_provider.dart';
import 'package:testpoint/features/student/widgets/student_test_list.dart';

enum NavigationTab { dashboard, profile, settings }

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  NavigationTab _selectedTab = NavigationTab.dashboard;

  Widget _buildScreen() {
    switch (_selectedTab) {
      case NavigationTab.dashboard:
        return _buildDashboardContent();
      case NavigationTab.profile:
        return _buildProfileContent();
      case NavigationTab.settings:
        return _buildSettingsContent();
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
      StudentTest(
        id: '1',
        name: 'Mathematics Mid-term',
        subject: 'Mathematics',
        scheduledDate: DateTime.now().add(const Duration(days: 1)),
        duration: 60,
        isCompleted: isCompleted,
        score: isCompleted ? 85 : null,
      ),
      StudentTest(
        id: '2',
        name: 'Science Quiz',
        subject: 'Science',
        scheduledDate: DateTime.now().add(const Duration(days: 3)),
        duration: 45,
        isCompleted: isCompleted,
        score: isCompleted ? 92 : null,
      ),
    ];

    return StudentTestList(
      tests: dummyTests.where((test) => test.isCompleted == isCompleted).toList(),
      isCompletedTab: isCompleted,
    );
  }

  Widget _buildProfileContent() {
    return const Center(
      child: Text('Profile'),
      // TODO: Implement profile screen
    );
  }

  Widget _buildSettingsContent() {
    return const Center(
      child: Text('Settings'),
      // TODO: Implement settings screen
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedTab == NavigationTab.dashboard
            ? 'Student Dashboard'
            : _selectedTab.name[0].toUpperCase() + _selectedTab.name.substring(1)),
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
      body: _buildScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab.index,
        onDestinationSelected: (index) {
          setState(() {
            _selectedTab = NavigationTab.values[index];
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
