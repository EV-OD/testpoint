import 'package:flutter/material.dart';
import 'package:testpoint/models/test_model.dart';

class TestListView extends StatelessWidget {
  final List<Test> tests;
  final TestStatus testStatus;
  final Function(String action, Test test)? onTestAction;

  const TestListView({
    super.key,
    required this.tests,
    required this.testStatus,
    this.onTestAction,
  });

  @override
  Widget build(BuildContext context) {
    if (tests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyStateIcon(),
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyStateTitle(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (testStatus == TestStatus.draft) ...[
              const SizedBox(height: 8),
              Text(
                'Create your first test using the + button',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
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
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    test.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                _buildStatusBadge(test, context),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildInfoRow(Icons.group, test.group?.name ?? 'Unknown Group'),
                const SizedBox(height: 4),
                _buildInfoRow(
                  Icons.access_time,
                  '${test.timeLimit} minutes',
                ),
                const SizedBox(height: 4),
                _buildInfoRow(
                  Icons.quiz,
                  '${test.questionCount} questions',
                ),
                const SizedBox(height: 4),
                _buildInfoRow(
                  Icons.calendar_today,
                  _formatDate(test.dateTime),
                ),
              ],
            ),
            trailing: _buildTrailingWidget(context, test),
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

  IconData _getEmptyStateIcon() {
    switch (testStatus) {
      case TestStatus.draft:
        return Icons.drafts;
      case TestStatus.published:
        return Icons.pending_actions;
      case TestStatus.completed:
        return Icons.task;
    }
  }

  String _getEmptyStateTitle() {
    switch (testStatus) {
      case TestStatus.draft:
        return 'No draft tests';
      case TestStatus.published:
        return 'No published tests';
      case TestStatus.completed:
        return 'No completed tests';
    }
  }

  Widget _buildStatusBadge(Test test, BuildContext context) {
    final badgeData = _getStatusBadgeData(test.status, context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeData.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: badgeData.textColor.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Text(
        badgeData.text,
        style: TextStyle(
          color: badgeData.textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  _StatusBadgeData _getStatusBadgeData(TestStatus status, BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    switch (status) {
      case TestStatus.draft:
        return _StatusBadgeData(
          text: 'DRAFT',
          backgroundColor: isDarkMode 
              ? Colors.amber.shade900.withOpacity(0.3)
              : Colors.amber.shade50,
          textColor: isDarkMode 
              ? Colors.amber.shade200
              : Colors.amber.shade800,
        );
      case TestStatus.published:
        return _StatusBadgeData(
          text: 'PUBLISHED',
          backgroundColor: isDarkMode 
              ? Colors.blue.shade900.withOpacity(0.3)
              : Colors.blue.shade50,
          textColor: isDarkMode 
              ? Colors.blue.shade200
              : Colors.blue.shade800,
        );
      case TestStatus.completed:
        return _StatusBadgeData(
          text: 'COMPLETED',
          backgroundColor: isDarkMode 
              ? Colors.green.shade900.withOpacity(0.3)
              : Colors.green.shade50,
          textColor: isDarkMode 
              ? Colors.green.shade200
              : Colors.green.shade800,
        );
    }
  }

  Widget _buildTrailingWidget(BuildContext context, Test test) {
    switch (testStatus) {
      case TestStatus.draft:
        return PopupMenuButton<String>(
          onSelected: (value) {
            onTestAction?.call(value, test);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            if (test.questionCount > 0) // Can only publish if has questions
              const PopupMenuItem(
                value: 'publish',
                child: Row(
                  children: [
                    Icon(Icons.publish, size: 16),
                    SizedBox(width: 8),
                    Text('Publish'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        );
      case TestStatus.published:
        return PopupMenuButton<String>(
          onSelected: (value) {
            onTestAction?.call(value, test);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 16),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'restore_to_draft',
              child: Row(
                children: [
                  Icon(
                    Icons.undo, 
                    size: 16, 
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.amber.shade300 
                        : Colors.amber.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Restore to Draft', 
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.amber.shade300 
                          : Colors.amber.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case TestStatus.completed:
        return PopupMenuButton<String>(
          onSelected: (value) {
            onTestAction?.call(value, test);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.analytics, size: 16),
                  SizedBox(width: 8),
                  Text('View Results'),
                ],
              ),
            ),
          ],
          child: Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
    }
  }
}

class _StatusBadgeData {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const _StatusBadgeData({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });
}