import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testpoint/providers/auth_provider.dart';

class StudentProfile extends StatelessWidget {
  const StudentProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'Student Name',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  user?.email ?? 'student@example.com',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildSection(
            context,
            'Academic Information',
            [
              {'Grade': '10'}, // TODO: Get from backend
              {'Group': 'Science'}, // TODO: Get from backend
              {'Student ID': 'STU001'}, // TODO: Get from backend
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            'Test Statistics',
            [
              {'Tests Completed': '15'}, // TODO: Get from backend
              {'Average Score': '85%'}, // TODO: Get from backend
              {'Tests Pending': '3'}, // TODO: Get from backend
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            'Recent Activity',
            [
              {'Last Test': 'Mathematics Mid-term'}, // TODO: Get from backend
              {'Score': '90%'}, // TODO: Get from backend
              {'Date': '25 July 2025'}, // TODO: Get from backend
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Map<String, String>> items,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.keys.first,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      item.values.first,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
