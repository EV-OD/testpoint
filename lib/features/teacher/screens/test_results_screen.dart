import 'package:flutter/material.dart';
import 'package:testpoint/models/test_model.dart';
import 'package:testpoint/models/test_session_model.dart';

class TestResultsScreen extends StatelessWidget {
  final Test test;
  final List<TestSession> sessions;

  const TestResultsScreen({
    super.key,
    required this.test,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    final completedSessions = sessions.where((s) => s.isCompleted).toList();
    
    // Calculate average score from finalScore and totalQuestions
    double averageScore = 0.0;
    if (completedSessions.isNotEmpty) {
      final scores = completedSessions
          .where((s) => s.finalScore != null)
          .map((s) => (s.finalScore! / s.totalQuestionsCount) * 100)
          .toList();
      if (scores.isNotEmpty) {
        averageScore = scores.reduce((a, b) => a + b) / scores.length;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Results: ${test.name}'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Statistics Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Test Statistics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Total Submissions',
                        sessions.length.toString(),
                        Icons.people,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Completed',
                        completedSessions.length.toString(),
                        Icons.check_circle,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Average Score',
                        '${averageScore.toStringAsFixed(1)}%',
                        Icons.trending_up,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Results List
          Expanded(
            child: sessions.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.analytics,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No submissions yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Results will appear here when students submit their tests',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      final scorePercentage = session.finalScore != null && session.totalQuestionsCount > 0 
                          ? (session.finalScore! / session.totalQuestionsCount) * 100 
                          : 0.0;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getScoreColor(scorePercentage)
                                .withOpacity(0.1),
                            child: Icon(
                              session.isCompleted
                                  ? Icons.check_circle
                                  : Icons.access_time,
                              color: _getScoreColor(scorePercentage),
                            ),
                          ),
                          title: Text(
                            'Student ${session.studentId}', // Use studentId since studentName is not available
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.isCompleted
                                    ? 'Completed on ${_formatDate(session.endTime!)}'
                                    : 'Started on ${_formatDate(session.startTime)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              if (session.isCompleted && session.endTime != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Time taken: ${_formatDuration(session.endTime!.difference(session.startTime))}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ],
                          ),
                          trailing: session.isCompleted
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${scorePercentage.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _getScoreColor(scorePercentage),
                                      ),
                                    ),
                                    Text(
                                      '${session.finalScore ?? 0}/${session.totalQuestionsCount}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                )
                              : Chip(
                                  label: const Text(
                                    'In Progress',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor:
                                      Colors.orange.withOpacity(0.1),
                                  side: BorderSide(
                                    color: Colors.orange.withOpacity(0.3),
                                  ),
                                ),
                          onTap: session.isCompleted
                              ? () {
                                  _showSessionDetails(context, session);
                                }
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  void _showSessionDetails(BuildContext context, TestSession session) {
    final scorePercentage = session.finalScore != null && session.totalQuestionsCount > 0 
        ? (session.finalScore! / session.totalQuestionsCount) * 100 
        : 0.0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Student ${session.studentId}\'s Result'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Score', '${session.finalScore ?? 0}/${session.totalQuestionsCount}'),
            _buildDetailRow('Percentage', '${scorePercentage.toStringAsFixed(1)}%'),
            _buildDetailRow('Time Taken', _formatDuration(session.endTime!.difference(session.startTime))),
            _buildDetailRow('Started At', _formatDate(session.startTime)),
            _buildDetailRow('Completed At', _formatDate(session.endTime!)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
