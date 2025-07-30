import 'package:flutter/material.dart';

// TODO: Replace with actual test model
class Test {
  final String id;
  final String name;
  final String group;
  final DateTime scheduledDate;
  final int duration;
  final bool isCompleted;

  Test({
    required this.id,
    required this.name,
    required this.group,
    required this.scheduledDate,
    required this.duration,
    this.isCompleted = false,
  });
}

class TestListView extends StatelessWidget {
  final List<Test> tests;
  final bool isCompletedTab;

  const TestListView({
    super.key,
    required this.tests,
    required this.isCompletedTab,
  });

  @override
  Widget build(BuildContext context) {
    if (tests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompletedTab ? Icons.task : Icons.pending_actions,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${isCompletedTab ? 'completed' : 'pending'} tests',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tests.length,
      itemBuilder: (context, index) {
        final test = tests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              test.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildInfoRow(Icons.group, test.group),
                const SizedBox(height: 4),
                _buildInfoRow(
                  Icons.access_time,
                  '${test.duration} minutes',
                ),
                const SizedBox(height: 4),
                _buildInfoRow(
                  Icons.calendar_today,
                  _formatDate(test.scheduledDate),
                ),
              ],
            ),
            trailing: !isCompletedTab
                ? PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'preview',
                        child: Text('Preview'),
                      ),
                    ],
                    onSelected: (value) {
                      // TODO: Implement edit and preview functionality
                    },
                  )
                : null,
            onTap: () {
              // TODO: Navigate to test details
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  String _formatDate(DateTime date) {
    // TODO: Use a proper date formatting library
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
