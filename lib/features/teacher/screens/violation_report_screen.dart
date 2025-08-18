import 'package:flutter/material.dart';
import 'package:testpoint/models/anti_cheat_violation_model.dart' as violation_model;
import 'package:testpoint/models/test_session_model.dart';

class ViolationReportScreen extends StatelessWidget {
  final TestSession session;
  final List<violation_model.AntiCheatViolation> violations;

  const ViolationReportScreen({
    super.key,
    required this.session,
    required this.violations,
  });

  @override
  Widget build(BuildContext context) {
    final violationsByType = _groupViolationsByType();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Violation Report'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: violations.isEmpty
          ? _buildNoViolations(context)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSessionInfo(context),
                  const SizedBox(height: 24),
                  _buildViolationSummary(context, violationsByType),
                  const SizedBox(height: 24),
                  _buildViolationDetails(context),
                  const SizedBox(height: 24),
                  _buildRiskAssessment(context),
                  const SizedBox(height: 32),
                  _buildRecommendations(context),
                ],
              ),
            ),
    );
  }

  Widget _buildNoViolations(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.verified_user,
              size: 64,
              color: Colors.green.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Violations Detected',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This student completed the test without any security violations.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.green.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.person, 'Student ID', session.studentId),
            _buildInfoRow(Icons.access_time, 'Started', _formatDateTime(session.startTime)),
            if (session.endTime != null)
              _buildInfoRow(Icons.done, 'Completed', _formatDateTime(session.endTime!)),
            _buildInfoRow(Icons.security, 'Violations', '${violations.length}'),
            _buildInfoRow(
              Icons.assessment,
              'Risk Level',
              _getRiskLevel().label,
              color: _getRiskLevel().color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: color ?? Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViolationSummary(BuildContext context, Map<violation_model.ViolationType, List<violation_model.AntiCheatViolation>> violationsByType) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Violation Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...violationsByType.entries.map((entry) => 
              _buildViolationTypeCard(context, entry.key, entry.value)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViolationTypeCard(BuildContext context, violation_model.ViolationType type, List<violation_model.AntiCheatViolation> typeViolations) {
    final maxSeverity = typeViolations.map((v) => v.severity).reduce((a, b) => a > b ? a : b);
    final color = _getSeverityColor(maxSeverity);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            type.icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  '${typeViolations.length} violation${typeViolations.length > 1 ? 's' : ''}',
                  style: TextStyle(color: color.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${typeViolations.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViolationDetails(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed Violations',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...violations.asMap().entries.map((entry) {
              final index = entry.key;
              final violation = entry.value;
              return _buildViolationDetailCard(context, index + 1, violation);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildViolationDetailCard(BuildContext context, int index, violation_model.AntiCheatViolation violation) {
    final color = _getSeverityColor(violation.severity);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      violation.type.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    Text(
                      _formatDateTime(violation.timestamp),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getSeverityLabel(violation.severity),
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            violation.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (violation.metadata.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: violation.metadata.entries.map((entry) => 
                Chip(
                  label: Text(
                    '${_formatKey(entry.key)}: ${entry.value}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: Colors.grey[100],
                )
              ).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRiskAssessment(BuildContext context) {
    final riskLevel = _getRiskLevel();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Risk Assessment',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: riskLevel.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: riskLevel.color.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    riskLevel.icon,
                    color: riskLevel.color,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          riskLevel.label,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: riskLevel.color,
                          ),
                        ),
                        Text(
                          _getRiskDescription(),
                          style: TextStyle(color: riskLevel.color.withOpacity(0.8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context) {
    final recommendations = _getRecommendations();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommendations',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...recommendations.map((recommendation) => 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.arrow_right, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(recommendation),
                    ),
                  ],
                ),
              )
            ),
          ],
        ),
      ),
    );
  }

  Map<violation_model.ViolationType, List<violation_model.AntiCheatViolation>> _groupViolationsByType() {
    final Map<violation_model.ViolationType, List<violation_model.AntiCheatViolation>> grouped = {};
    
    for (final violation in violations) {
      grouped.putIfAbsent(violation.type, () => []).add(violation);
    }
    
    return grouped;
  }

  RiskLevel _getRiskLevel() {
    final criticalCount = violations.where((v) => v.severity >= 3).length;
    final seriousCount = violations.where((v) => v.severity == 2).length;
    
    if (criticalCount > 0) {
      return RiskLevel.critical;
    } else if (seriousCount > 2 || violations.length > 5) {
      return RiskLevel.high;
    } else if (seriousCount > 0 || violations.length > 2) {
      return RiskLevel.medium;
    } else {
      return RiskLevel.low;
    }
  }

  String _getRiskDescription() {
    switch (_getRiskLevel()) {
      case RiskLevel.low:
        return 'Minor violations detected. Review recommended but no immediate action required.';
      case RiskLevel.medium:
        return 'Moderate violations detected. Consider discussing with student.';
      case RiskLevel.high:
        return 'Significant violations detected. Academic integrity review recommended.';
      case RiskLevel.critical:
        return 'Critical violations detected. Immediate investigation required.';
    }
  }

  List<String> _getRecommendations() {
    final riskLevel = _getRiskLevel();
    
    switch (riskLevel) {
      case RiskLevel.low:
        return [
          'Monitor student behavior in future tests',
          'Provide additional guidance on test-taking rules',
        ];
      case RiskLevel.medium:
        return [
          'Discuss violations with student',
          'Provide clear warning about academic integrity',
          'Monitor closely in future assessments',
        ];
      case RiskLevel.high:
        return [
          'Conduct formal academic integrity review',
          'Consider test retake under stricter supervision',
          'Implement additional monitoring measures',
          'Document violations for academic record',
        ];
      case RiskLevel.critical:
        return [
          'Immediate investigation required',
          'Consider test invalidation',
          'Formal disciplinary action may be warranted',
          'Review security measures and protocols',
        ];
    }
  }

  Color _getSeverityColor(int severity) {
    switch (severity) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.deepOrange;
      case 3:
      default:
        return Colors.red;
    }
  }

  String _getSeverityLabel(int severity) {
    switch (severity) {
      case 1:
        return 'Warning';
      case 2:
        return 'Serious';
      case 3:
      default:
        return 'Critical';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatKey(String key) {
    return key
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

enum RiskLevel {
  low,
  medium,
  high,
  critical,
}

extension RiskLevelExtension on RiskLevel {
  Color get color {
    switch (this) {
      case RiskLevel.low:
        return Colors.green;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.deepOrange;
      case RiskLevel.critical:
        return Colors.red;
    }
  }

  String get label {
    switch (this) {
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.medium:
        return 'Medium Risk';
      case RiskLevel.high:
        return 'High Risk';
      case RiskLevel.critical:
        return 'Critical Risk';
    }
  }

  IconData get icon {
    switch (this) {
      case RiskLevel.low:
        return Icons.check_circle;
      case RiskLevel.medium:
        return Icons.warning;
      case RiskLevel.high:
        return Icons.error;
      case RiskLevel.critical:
        return Icons.dangerous;
    }
  }
}
