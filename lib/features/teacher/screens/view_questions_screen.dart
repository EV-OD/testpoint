import 'package:flutter/material.dart';
import 'package:testpoint/models/question_model.dart';

class ViewQuestionsScreen extends StatelessWidget {
  final String testId;
  final String testName;
  final List<Question> questions;

  const ViewQuestionsScreen({
    super.key,
    required this.testId,
    required this.testName,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Questions: $testName'),
        elevation: 0,
      ),
      body: questions.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.quiz_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No questions found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Q${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                question.text,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Options:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...question.options.asMap().entries.map((entry) {
                          final optionIndex = entry.key;
                          final option = entry.value;
                          final isCorrect = question.correctAnswerIndex == optionIndex;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isCorrect
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.1),
                                    border: Border.all(
                                      color: isCorrect
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: isCorrect
                                        ? const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.green,
                                          )
                                        : Text(
                                            String.fromCharCode(65 + optionIndex),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    option.text,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isCorrect
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                      color: isCorrect
                                          ? Colors.green.shade700
                                          : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.2),
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '${questions.length} Questions Total',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
