import 'package:flutter/material.dart';

enum NavigationItem {
  dashboard,
  profile,
  settings,
}

class AppBottomNavigation extends StatelessWidget {
  final NavigationItem selectedItem;
  final Function(NavigationItem) onItemSelected;

  const AppBottomNavigation({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedItem.index,
      onDestinationSelected: (index) =>
          onItemSelected(NavigationItem.values[index]),
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
    );
  }
}
