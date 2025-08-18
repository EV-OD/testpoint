import 'package:flutter/material.dart';
import 'package:testpoint/models/anti_cheat_violation_model.dart';

class AntiCheatWarningDialog extends StatelessWidget {
  final AntiCheatViolation violation;
  final int remainingWarnings;
  final VoidCallback onContinue;
  final VoidCallback? onSubmitTest;

  const AntiCheatWarningDialog({
    super.key,
    required this.violation,
    required this.remainingWarnings,
    required this.onContinue,
    this.onSubmitTest,
  });

  @override
  Widget build(BuildContext context) {
    final isLastWarning = remainingWarnings <= 1;
    final isCritical = violation.severity >= 3;
    
    return WillPopScope(
      onWillPop: () async => false, // Prevent dismissing by back button
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCritical ? Colors.red : Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isCritical ? Icons.error : Icons.warning,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isCritical ? 'Critical Violation' : 'Security Warning',
                style: TextStyle(
                  color: isCritical ? Colors.red : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isCritical ? Colors.red : Colors.orange).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isCritical ? Colors.red : Colors.orange).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        violation.type.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          violation.type.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    violation.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (isCritical) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This is a critical violation. Your test will be submitted automatically.',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isLastWarning ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isLastWarning ? Icons.error : Icons.info,
                          color: isLastWarning ? Colors.red : Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isLastWarning 
                                ? 'Final Warning!'
                                : 'Warning $remainingWarnings of ${remainingWarnings + violation.severity - 1}',
                            style: TextStyle(
                              color: isLastWarning ? Colors.red.shade700 : Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isLastWarning
                          ? 'One more violation will result in automatic test submission.'
                          : '$remainingWarnings warnings remaining before automatic submission.',
                      style: TextStyle(
                        color: isLastWarning ? Colors.red.shade600 : Colors.orange.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            _buildViolationDetails(),
          ],
        ),
        actions: [
          if (!isCritical) ...[
            TextButton(
              onPressed: onSubmitTest,
              child: Text(
                'Submit Test Now',
                style: TextStyle(color: Colors.red.shade600),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: isLastWarning ? Colors.orange : Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(isLastWarning ? 'Continue Carefully' : 'Continue Test'),
            ),
          ] else ...[
            ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit Test'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildViolationDetails() {
    if (violation.metadata.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        ...violation.metadata.entries.map((entry) {
          String value = entry.value.toString();
          
          // Format specific metadata fields
          if (entry.key == 'duration_seconds') {
            value = '${entry.value} seconds';
          } else if (entry.key == 'app_name') {
            value = '"${entry.value}"';
          }
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Text(
              '• ${_formatKey(entry.key)}: $value',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          );
        }),
      ],
    );
  }

  String _formatKey(String key) {
    return key
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

/// Show anti-cheat warning dialog
Future<void> showAntiCheatWarning(
  BuildContext context, {
  required AntiCheatViolation violation,
  required int remainingWarnings,
  required VoidCallback onContinue,
  VoidCallback? onSubmitTest,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AntiCheatWarningDialog(
      violation: violation,
      remainingWarnings: remainingWarnings,
      onContinue: onContinue,
      onSubmitTest: onSubmitTest,
    ),
  );
}

/// Show simple anti-cheat message (for less critical violations)
Future<void> showAntiCheatMessage(
  BuildContext context, {
  required String message,
  VoidCallback? onOk,
}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.security,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Security Notice'),
        ],
      ),
      content: Text(message),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onOk?.call();
          },
          child: const Text('Understood'),
        ),
      ],
    ),
  );
}
