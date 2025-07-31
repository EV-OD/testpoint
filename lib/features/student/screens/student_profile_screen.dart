import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testpoint/providers/auth_provider.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            context: context,
            title: 'Personal Information',
            items: [
              {'Name': user?.name ?? 'Not available'},
              {'Email': user?.email ?? 'Not available'},
              {'Group': 'Group A'}, // TODO: Implement actual group information
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context: context,
            title: 'Test Statistics',
            items: [
              {'Tests Taken': '0'}, // TODO: Implement actual statistics
              {'Tests Pending': '0'},
              {'Average Score': 'N/A'},
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required String title,
    required List<Map<String, String>> items,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.keys.first,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(item.values.first),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
