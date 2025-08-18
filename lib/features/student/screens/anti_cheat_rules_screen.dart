import 'package:flutter/material.dart';
import 'package:testpoint/models/anti_cheat_config_model.dart';
import 'package:testpoint/models/test_model.dart';

class AntiCheatRulesScreen extends StatelessWidget {
  final Test test;
  final AntiCheatConfig config;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const AntiCheatRulesScreen({
    super.key,
    required this.test,
    required this.config,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anti-Cheating Rules'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildTestInfo(context),
                  const SizedBox(height: 32),
                  _buildRulesSection(context),
                  const SizedBox(height: 32),
                  _buildConsequencesSection(context),
                  const SizedBox(height: 32),
                  _buildExamplesSection(context),
                  const SizedBox(height: 32),
                  _buildAcknowledgment(context),
                ],
              ),
            ),
          ),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.security,
            size: 48,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(height: 12),
          Text(
            'Academic Integrity Notice',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This test is monitored by an advanced anti-cheating system',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTestInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, Icons.quiz, 'Test Name', test.name),
            _buildInfoRow(context, Icons.timer, 'Duration', '${test.timeLimit} minutes'),
            _buildInfoRow(context, Icons.warning_amber, 'Max Warnings', '${config.maxWarnings}'),
            if (config.enableScreenPinning)
              _buildInfoRow(context, Icons.pin_drop, 'Screen Pinning', 'Required'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Anti-Cheating Rules',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildRuleCard(
          context,
          '🔄',
          'No App Switching',
          'Do not switch to other applications during the test. The system will detect any app switches.',
          config.enableSuspiciousActivityDetection,
        ),
        if (config.enableScreenPinning)
          _buildRuleCard(
            context,
            '📌',
            'Screen Pinning Required',
            'Keep screen pinning enabled throughout the test. Disabling it will result in immediate test submission.',
            true,
          ),
        if (config.enableScreenshotPrevention)
          _buildRuleCard(
            context,
            '📸',
            'No Screenshots',
            'Taking screenshots during the test is prohibited and will be detected.',
            true,
          ),
        if (config.enableScreenRecordingDetection)
          _buildRuleCard(
            context,
            '🎥',
            'No Screen Recording',
            'Screen recording during the test is strictly forbidden and will trigger automatic submission.',
            true,
          ),
        _buildRuleCard(
          context,
          '👀',
          'Stay Focused',
          'Keep the test application in focus. Minimize distractions and avoid multitasking.',
          true,
        ),
      ],
    );
  }

  Widget _buildRuleCard(BuildContext context, String emoji, String title, String description, bool enabled) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: enabled 
            ? Theme.of(context).cardColor
            : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled 
              ? Theme.of(context).colorScheme.outline.withOpacity(0.2)
              : Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: enabled ? null : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: enabled 
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (!enabled)
            Icon(
              Icons.not_interested,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildConsequencesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Violation Consequences',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.error.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Warning System',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• First violation: Warning message displayed\n'
                '• Subsequent violations: Escalating warnings\n'
                '• After ${config.maxWarnings} violations: Automatic test submission\n'
                '• Critical violations: Immediate test submission',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExamplesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Examples',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildExampleCard(
                context,
                '✅ Allowed',
                Colors.green,
                [
                  'Reading questions carefully',
                  'Using calculator app (if permitted)',
                  'Taking breaks (timer continues)',
                  'Changing answers before submission',
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildExampleCard(
                context,
                '❌ Prohibited',
                Colors.red,
                [
                  'Switching to messaging apps',
                  'Taking screenshots',
                  'Using browser for research',
                  'Screen recording',
                  'Disabling screen pinning',
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExampleCard(BuildContext context, String title, Color color, List<String> examples) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          ...examples.map((example) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '• $example',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAcknowledgment(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Important Notice',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'By proceeding with this test, you acknowledge that you have read and understood all anti-cheating rules. You agree to maintain academic integrity throughout the test session.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onReject,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: onAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'I Understand & Accept',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
