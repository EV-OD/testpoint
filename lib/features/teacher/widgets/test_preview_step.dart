import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testpoint/providers/test_provider.dart';
import 'package:testpoint/models/question_model.dart';
import 'dart:math';

class TestPreviewStep extends StatefulWidget {
  const TestPreviewStep({super.key});

  @override
  State<TestPreviewStep> createState() => _TestPreviewStepState();
}

class _TestPreviewStepState extends State<TestPreviewStep> {
  List<Question> _randomizedQuestions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _randomizeQuestions();
    });
  }

  void _randomizeQuestions() {
    final provider = Provider.of<TestProvider>(context, listen: false);
    final questions = provider.questions;
    
    setState(() {
      _randomizedQuestions = _shuffleQuestions(questions);
    });
  }

  List<Question> _shuffleQuestions(List<Question> questions) {
    final List<Question> shuffled = List.from(questions);
    shuffled.shuffle(Random());
    return shuffled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<TestProvider>(
      builder: (context, provider, child) {
        final currentTest = provider.currentTest;
        final questions = provider.questions;

        if (currentTest == null) {
          return Center(
            child: Text(
              'No test data available',
              style: TextStyle(
                fontSize: 16, 
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        if (questions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.quiz_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No questions added yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add questions in the previous step to preview your test',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Test Summary Header
            _buildTestSummary(context, currentTest, questions.length),
            
            const SizedBox(height: 16),
            
            // Preview Controls
            _buildPreviewControls(context),
            
            const SizedBox(height: 16),
            
            // Questions Preview
            Expanded(
              child: _buildQuestionsPreview(context, theme),
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            _buildActionButtons(context, provider),
          ],
        );
      },
    );
  }

  Widget _buildTestSummary(BuildContext context, dynamic currentTest, int questionCount) {
    final theme = Theme.of(context);
    final selectedGroup = Provider.of<TestProvider>(context, listen: false).selectedGroup;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Summary',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              icon: Icons.quiz,
              label: 'Test Name',
              value: currentTest.name,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              icon: Icons.group,
              label: 'Group',
              value: selectedGroup?.name ?? 'Unknown Group',
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              icon: Icons.timer,
              label: 'Duration',
              value: '${currentTest.timeLimit} minutes',
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              icon: Icons.help_outline,
              label: 'Questions',
              value: '$questionCount questions',
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              icon: Icons.schedule,
              label: 'Scheduled',
              value: _formatDateTime(currentTest.dateTime),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon, 
          size: 20, 
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewControls(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Preview shows questions in randomized order as students will see them',
                style: TextStyle(fontSize: 14),
              ),
            ),
            TextButton.icon(
              onPressed: _randomizeQuestions,
              icon: const Icon(Icons.shuffle, size: 18),
              label: const Text('Shuffle'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsPreview(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              'Test Questions Preview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _randomizedQuestions.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                return _buildQuestionPreview(
                  context,
                  _randomizedQuestions[index],
                  index + 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPreview(BuildContext context, Question question, int questionNumber) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question Header
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Q$questionNumber',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                question.text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Answer Options
        ...question.options.asMap().entries.map((entry) {
          final optionIndex = entry.key;
          final option = entry.value;
          final optionLetter = String.fromCharCode(65 + optionIndex); // A, B, C, D
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: option.isCorrect 
                    ? Colors.green 
                    : Theme.of(context).colorScheme.outline,
                  width: option.isCorrect ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: option.isCorrect 
                  ? Colors.green.shade50 
                  : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: option.isCorrect 
                          ? Colors.green 
                          : Theme.of(context).colorScheme.outline,
                      ),
                      color: option.isCorrect 
                        ? Colors.green 
                        : Colors.transparent,
                    ),
                    child: Center(
                      child: Text(
                        optionLetter,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: option.isCorrect 
                            ? Colors.white 
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option.text,
                      style: TextStyle(
                        fontWeight: option.isCorrect 
                          ? FontWeight.w600 
                          : FontWeight.normal,
                        color: option.isCorrect 
                          ? Colors.green.shade800 
                          : null,
                      ),
                    ),
                  ),
                  if (option.isCorrect)
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, TestProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // First row: Previous and Save as Draft
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => provider.goToStep(1), // Go back to questions step
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: provider.isSaving 
                    ? null 
                    : () => _saveAsDraft(context, provider),
                  icon: provider.isSaving 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                  label: Text(provider.isSaving ? 'Saving...' : 'Save as Draft'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Second row: Publish Test (full width)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: provider.isSaving 
                ? null 
                : () => _publishTest(context, provider),
              icon: provider.isSaving 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.publish),
              label: Text(provider.isSaving ? 'Publishing...' : 'Publish Test'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAsDraft(BuildContext context, TestProvider provider) async {
    await provider.saveAsDraft();
    
    if (context.mounted) {
      if (provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test saved as draft successfully!'),
            backgroundColor: Colors.blue,
          ),
        );
        
        // Navigate back to dashboard
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  Future<void> _publishTest(BuildContext context, TestProvider provider) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Publish Test'),
        content: const Text(
          'Are you sure you want to publish this test? Once published, '
          'students will be able to take it at the scheduled time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Publish'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.publishTest();
      
      if (context.mounted) {
        if (provider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Test published successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate back to dashboard
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    
    return '$day $month $year at $hour:$minute';
  }
}