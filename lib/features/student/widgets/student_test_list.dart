import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:testpoint/models/test_model.dart';
import 'package:testpoint/models/question_model.dart';
import 'package:testpoint/providers/student_provider.dart';
import 'package:testpoint/config/app_routes.dart';

class StudentTestList extends StatelessWidget {
  final bool isCompletedTab;

  const StudentTestList({
    super.key,
    required this.isCompletedTab,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, studentProvider, child) {
        if (studentProvider.loading && !studentProvider.hasInitiallyLoaded) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (studentProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading tests',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  studentProvider.error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => studentProvider.refreshTests(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final tests = isCompletedTab 
            ? studentProvider.completedTests 
            : studentProvider.pendingTests;

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
                  Text(
                    'Your upcoming tests will appear here',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => studentProvider.refreshTests(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tests.length,
            itemBuilder: (context, index) {
              final test = tests[index];
              return _buildTestCard(context, test, studentProvider);
            },
          ),
        );
      },
    );
  }

  Widget _buildTestCard(BuildContext context, Test test, StudentProvider provider) {
    final status = provider.getTestStatus(test);
    final isAvailable = provider.isTestAvailable(test);
    
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
            const SizedBox(height: 8),
            _buildStatusChip(context, status, isAvailable),
          ],
        ),
        trailing: _buildActionButton(context, test, isAvailable, isCompletedTab),
        onTap: () {
          if (isCompletedTab) {
            _navigateToTestResults(context, test);
          } else if (isAvailable) {
            _navigateToTestInstructions(context, test);
          }
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context, String status, bool isAvailable) {
    Color backgroundColor;
    Color textColor;
    
    if (status == 'Completed') {
      backgroundColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green[700]!;
    } else if (status == 'Expired') {
      backgroundColor = Colors.red.withOpacity(0.1);
      textColor = Colors.red[700]!;
    } else if (status == 'Available') {
      backgroundColor = Theme.of(context).colorScheme.primary.withOpacity(0.1);
      textColor = Theme.of(context).colorScheme.primary;
    } else {
      backgroundColor = Colors.orange.withOpacity(0.1);
      textColor = Colors.orange[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget? _buildActionButton(BuildContext context, Test test, bool isAvailable, bool isCompletedTab) {
    if (isCompletedTab) {
      return Icon(
        Icons.check_circle,
        color: Colors.green[600],
        size: 28,
      );
    }

    if (!isAvailable) {
      return Icon(
        Icons.lock,
        color: Colors.grey[400],
        size: 24,
      );
    }

    return ElevatedButton(
      onPressed: () => _navigateToTestInstructions(context, test),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: const Text('Take Test'),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final testDate = DateTime(date.year, date.month, date.day);
    
    if (testDate == today) {
      return 'Today ${_formatTime(date)}';
    } else if (testDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow ${_formatTime(date)}';
    } else if (testDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year} ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _navigateToTestInstructions(BuildContext context, Test test) {
    context.go(AppRoutes.testInstructions, extra: test);
  }

  void _navigateToTestResults(BuildContext context, Test test) {
    // TODO: Get actual test session data for results
    context.go(AppRoutes.testResults, extra: {
      'test': test,
      'questions': <Question>[], // TODO: Load actual questions
      'answers': <int, int>{}, // TODO: Load actual answers
      'score': 0, // TODO: Load actual score
    });
  }
}
