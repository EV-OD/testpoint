import 'package:flutter/material.dart';

// TODO: Replace with actual test model from backend
class StudentTest {
  final String id;
  final String name;
  final String subject;
  final DateTime scheduledDate;
  final int duration;
  final bool isCompleted;
  final int? score;

  StudentTest({
    required this.id,
    required this.name,
    required this.subject,
    required this.scheduledDate,
    required this.duration,
    this.isCompleted = false,
    this.score,
  });
}

class StudentTestList extends StatelessWidget {
  final List<StudentTest> tests;
  final bool isCompletedTab;

  const StudentTestList({
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
            if (!isCompletedTab) ...[
              const SizedBox(height: 8),
              const Text(
                'Your upcoming tests will appear here',
                style: TextStyle(color: Colors.grey),
              ),
            ],
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
                _buildInfoRow(Icons.subject, test.subject),
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
                if (isCompletedTab && test.score != null) ...[
                  const SizedBox(height: 4),
                  _buildInfoRow(
                    Icons.score,
                    'Score: ${test.score}%',
                  ),
                ],
              ],
            ),
            trailing: !isCompletedTab
                ? ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to take test screen
                    },
                    child: const Text('Take Test'),
                  )
                : Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            onTap: () {
              // TODO: Navigate to test details/results
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
