import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testpoint/providers/test_provider.dart';
import 'package:testpoint/models/question_model.dart';

class QuestionCreationStep extends StatefulWidget {
  const QuestionCreationStep({super.key});

  @override
  State<QuestionCreationStep> createState() => _QuestionCreationStepState();
}

class _QuestionCreationStepState extends State<QuestionCreationStep> {
  final GlobalKey<FormState> _questionFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<TestProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with question counter
              _buildHeader(provider),
              const SizedBox(height: 24),
              
              // Questions list and form in vertical layout
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Questions list at the top (shows all questions without scroll)
                      _buildQuestionsSection(context, provider),
                      
                      const SizedBox(height: 24),
                      
                      // Question creation form below
                      _buildQuestionForm(context, provider),
                    ],
                  ),
                ),
              ),
              
              // Error message
              if (provider.errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          provider.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: provider.clearError,
                        icon: Icon(
                          Icons.close,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(TestProvider provider) {
    return Row(
      children: [
        Icon(
          Icons.quiz,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Questions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Questions added: ${provider.questionCount}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionForm(BuildContext context, TestProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _questionFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add New Question',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Question text input
              TextFormField(
                controller: provider.questionTextController,
                maxLines: 3,
                maxLength: 500,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: const InputDecoration(
                  labelText: 'Question Text *',
                  hintText: 'Enter your question here...',
                  border: OutlineInputBorder(),
                  helperText: 'Minimum 10 characters',
                  contentPadding: EdgeInsets.all(16),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Question text is required';
                  }
                  if (value.trim().length < 10) {
                    return 'Question text must be at least 10 characters';
                  }
                  if (value.trim().length > 500) {
                    return 'Question text cannot exceed 500 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Answer options
              Row(
                children: [
                  Text(
                    'Answer Options',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '*',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Select the correct answer by tapping the radio button next to the option',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              ...List.generate(4, (index) => _buildOptionField(context, provider, index)),
              
              const SizedBox(height: 20),
              
              // Add question button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: provider.isSaving ? null : () => _addQuestion(provider),
                  icon: provider.isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                  label: Text(provider.isSaving ? 'Adding...' : 'Add Question'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionField(BuildContext context, TestProvider provider, int index) {
    final isSelected = provider.selectedCorrectAnswer == index;
    final optionLabels = ['A', 'B', 'C', 'D'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected 
            ? Theme.of(context).colorScheme.primary 
            : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isSelected 
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1)
          : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Radio button with letter label
            GestureDetector(
              onTap: () => provider.setSelectedCorrectAnswer(index),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected 
                      ? Theme.of(context).colorScheme.primary 
                      : Theme.of(context).colorScheme.outline,
                    width: 2,
                  ),
                  color: isSelected 
                    ? Theme.of(context).colorScheme.primary 
                    : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    optionLabels[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected 
                        ? Theme.of(context).colorScheme.onPrimary 
                        : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Option text field
            Expanded(
              child: TextFormField(
                controller: provider.optionControllers[index],
                maxLength: 100,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'Option ${index + 1} *',
                  hintText: 'Enter answer option...',
                  border: const OutlineInputBorder(),
                  counterText: '', // Hide character counter
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  suffixIcon: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Option ${index + 1} is required';
                  }
                  if (value.trim().length > 100) {
                    return 'Option cannot exceed 100 characters';
                  }
                  
                  // Check for duplicate options
                  final currentText = value.trim().toLowerCase();
                  for (int i = 0; i < provider.optionControllers.length; i++) {
                    if (i != index) {
                      final otherText = provider.optionControllers[i].text.trim().toLowerCase();
                      if (otherText.isNotEmpty && currentText == otherText) {
                        return 'This option is already used';
                      }
                    }
                  }
                  
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsSection(BuildContext context, TestProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Questions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${provider.questionCount}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (provider.questions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.quiz_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No questions added yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first question using the form below',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              // Show all questions without scroll - each takes the space it needs
              Column(
                children: provider.questions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final question = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildQuestionListItem(context, provider, question, index),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsList(BuildContext context, TestProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Questions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${provider.questionCount}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (provider.questions.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.quiz_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No questions added yet',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first question using the form',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: provider.questions.length,
                  itemBuilder: (context, index) {
                    final question = provider.questions[index];
                    return _buildQuestionListItem(context, provider, question, index);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionListItem(BuildContext context, TestProvider provider, Question question, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Question ${index + 1}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _deleteQuestion(provider, index),
                  icon: const Icon(Icons.delete_outline),
                  iconSize: 20,
                  tooltip: 'Delete question',
                  style: IconButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Question text
            Text(
              question.text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            
            // Show all options with correct answer highlighted
            Column(
              children: question.options.asMap().entries.map((entry) {
                final optionIndex = entry.key;
                final option = entry.value;
                final optionLabel = String.fromCharCode(65 + optionIndex); // A, B, C, D
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: option.isCorrect 
                      ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                      : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: option.isCorrect 
                      ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1.5)
                      : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: option.isCorrect 
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        ),
                        child: Center(
                          child: Text(
                            optionLabel,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: option.isCorrect 
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option.text,
                          style: TextStyle(
                            fontWeight: option.isCorrect ? FontWeight.w600 : FontWeight.normal,
                            color: option.isCorrect 
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          ),
                        ),
                      ),
                      if (option.isCorrect)
                        Icon(
                          Icons.check_circle,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addQuestion(TestProvider provider) async {
    if (_questionFormKey.currentState?.validate() ?? false) {
      await provider.addQuestion();
      if (provider.errorMessage == null) {
        // Question added successfully, form is already cleared by provider
        _questionFormKey.currentState?.reset();
      }
    }
  }

  Future<void> _deleteQuestion(TestProvider provider, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question'),
        content: const Text('Are you sure you want to delete this question? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.deleteQuestion(index);
    }
  }
}