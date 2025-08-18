import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testpoint/providers/auth_provider.dart';
import 'package:testpoint/providers/student_statistics_provider.dart';

class StudentProfile extends StatelessWidget {
  const StudentProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          _buildProfileHeader(context, user),
          const SizedBox(height: 24),
          
          // Personal Information
          _buildPersonalInfoSection(context, user),
          const SizedBox(height: 20),
          
          // Academic Information
          _buildAcademicInfoSection(context),
          const SizedBox(height: 20),
          
          // Quick Stats
          _buildQuickStatsSection(context),
          const SizedBox(height: 20),
          
          // Detailed Performance Section
          _buildDetailedPerformanceSection(context),
          const SizedBox(height: 100), // Bottom padding for navigation
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // Name
          Text(
            user?.name ?? 'Student',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Student',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Email
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.email_outlined,
                color: Colors.white.withOpacity(0.8),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                user?.email ?? 'No email',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context, dynamic user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Personal Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoItem(context, 'Full Name', user?.name ?? 'N/A', Icons.badge),
            const SizedBox(height: 16),
            _buildInfoItem(context, 'Email Address', user?.email ?? 'N/A', Icons.email),
            const SizedBox(height: 16),
            _buildInfoItem(context, 'Role', 'Student', Icons.school),
            const SizedBox(height: 16),
            _buildInfoItem(context, 'Student ID', 'STU-${user?.name?.substring(0, 3).toUpperCase() ?? 'XXX'}001', Icons.numbers),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicInfoSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Academic Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoItem(context, 'Class/Grade', 'Not assigned', Icons.class_),
            const SizedBox(height: 16),
            _buildInfoItem(context, 'Section', 'Not assigned', Icons.group),
            const SizedBox(height: 16),
            _buildInfoItem(context, 'Enrollment Date', DateTime.now().toString().substring(0, 10), Icons.calendar_today),
            const SizedBox(height: 16),
            _buildInfoItem(context, 'Academic Year', '2025-2026', Icons.event_note),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsSection(BuildContext context) {
    return Consumer<StudentStatisticsProvider>(
      builder: (context, statsProvider, child) {
        if (statsProvider.loading && !statsProvider.hasInitiallyLoaded) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Padding(
              padding: EdgeInsets.all(60),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final stats = statsProvider.statistics;
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.analytics_outlined,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Quick Stats',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (statsProvider.loading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: statsProvider.loading 
                        ? null 
                        : () => statsProvider.refreshStatistics(),
                      tooltip: 'Refresh Statistics',
                    ),
                  ],
                ),
                
                if (statsProvider.error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            statsProvider.error!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Tests Taken',
                        '${stats.testsTaken}',
                        Icons.quiz,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Average Score',
                        statsProvider.getFormattedAverageScore(),
                        Icons.score,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Pending Tests',
                        '${stats.pendingTests}',
                        Icons.pending,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Best Score',
                        statsProvider.getFormattedBestScore(),
                        Icons.star,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
                
                // Additional stats row
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Accuracy',
                        statsProvider.getAccuracyPercentage(),
                        Icons.gps_fixed,
                        Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Grade',
                        statsProvider.getPerformanceGrade(),
                        Icons.grade,
                        Colors.indigo,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedPerformanceSection(BuildContext context) {
    return Consumer<StudentStatisticsProvider>(
      builder: (context, statsProvider, child) {
        if (statsProvider.loading && !statsProvider.hasInitiallyLoaded) {
          return const SizedBox.shrink();
        }

        final stats = statsProvider.statistics;
        
        if (stats.testsTaken == 0) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.assessment_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Test Data Yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Take your first test to see detailed performance analytics here.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.assessment_outlined,
                        color: Colors.purple,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Detailed Performance',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Performance metrics
                _buildPerformanceMetric(
                  context,
                  'Overall Grade',
                  statsProvider.getPerformanceGrade(),
                  Icons.grade,
                  _getGradeColor(statsProvider.getPerformanceGrade()),
                ),
                const SizedBox(height: 12),
                
                _buildPerformanceMetric(
                  context,
                  'Question Accuracy',
                  statsProvider.getAccuracyPercentage(),
                  Icons.gps_fixed,
                  Colors.teal,
                ),
                const SizedBox(height: 12),
                
                _buildPerformanceMetric(
                  context,
                  'Total Questions Answered',
                  '${stats.totalQuestions}',
                  Icons.quiz_outlined,
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                
                _buildPerformanceMetric(
                  context,
                  'Correct Answers',
                  '${stats.correctAnswers}',
                  Icons.check_circle_outline,
                  Colors.green,
                ),
                const SizedBox(height: 12),
                
                _buildPerformanceMetric(
                  context,
                  'Progress Trend',
                  statsProvider.getImprovementTrend(),
                  Icons.trending_up,
                  Colors.orange,
                ),
                
                // Progress indicator
                if (stats.testsTaken > 0) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Performance Overview',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Completion Rate',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: stats.testsTaken / (stats.testsTaken + stats.pendingTests),
                                    backgroundColor: Colors.blue.shade100,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${stats.testsTaken} of ${stats.testsTaken + stats.pendingTests} tests completed',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceMetric(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getGradeColor(String grade) {
    if (grade.startsWith('A')) return Colors.green;
    if (grade.startsWith('B')) return Colors.blue;
    if (grade.startsWith('C')) return Colors.orange;
    if (grade.startsWith('D')) return Colors.red.shade400;
    if (grade == 'F') return Colors.red;
    return Colors.grey;
  }
}