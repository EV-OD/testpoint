
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testpoint/providers/auth_provider.dart';

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
    final authProvider = Provider.of<AuthProvider>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Welcome, ${authProvider.currentUser?.name ?? 'Student'}!'),
          Text('Role: ${authProvider.currentUser?.role.toString().split('.').last ?? 'N/A'}'),
          // TODO: Add tabs for pending and completed tests
        ],
      ),
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
