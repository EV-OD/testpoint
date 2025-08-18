import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:testpoint/models/test_model.dart';
import 'package:testpoint/models/question_model.dart';
import 'package:testpoint/config/app_routes.dart';

class TestResultsScreen extends StatelessWidget {
  final Test test;
  final List<Question> questions;
  final Map<int, int> answers;
  final int score;

  const TestResultsScreen({
    super.key,
    required this.test,
    required this.questions,
    required this.answers,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final correctAnswers = _calculateCorrectAnswers();
    final totalQuestions = questions.length;
    final answeredQuestions = answers.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Results'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            context.go(AppRoutes.studentDashboard);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultHeader(context),
            const SizedBox(height: 24),
            _buildScoreCard(context, correctAnswers, totalQuestions),
            const SizedBox(height: 24),
            _buildStatsCards(context, answeredQuestions, totalQuestions),
            const SizedBox(height: 24),
            _buildAnswerReview(context),
            const SizedBox(height: 32),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildResultHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            score >= 80 ? Colors.green : score >= 60 ? Colors.orange : Colors.red,
            score >= 80 ? Colors.green[700]! : score >= 60 ? Colors.orange[700]! : Colors.red[700]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  score >= 80 ? Icons.celebration : score >= 60 ? Icons.check_circle : Icons.sentiment_dissatisfied,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  score >= 80 ? 'Excellent!' : score >= 60 ? 'Good Job!' : 'Need Improvement',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            test.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Test completed successfully',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, int correctAnswers, int totalQuestions) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star,
                color: Theme.of(context).colorScheme.primary,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'Your Score',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            child: Center(
              child: Text(
                '$score%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '$correctAnswers out of $totalQuestions correct',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, int answeredQuestions, int totalQuestions) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Answered',
            '$answeredQuestions/$totalQuestions',
            Icons.question_answer,
            Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Accuracy',
            '${answeredQuestions > 0 ? ((_calculateCorrectAnswers() / answeredQuestions) * 100).toStringAsFixed(1) : 0}%',
            Icons.gps_fixed,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerReview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assignment_turned_in,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Answer Review',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            final selectedAnswer = answers[index];
            final correctIndex = question.correctAnswerIndex;
            final isCorrect = selectedAnswer != null && correctIndex >= 0 && selectedAnswer == correctIndex;
            final wasAnswered = selectedAnswer != null;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: !wasAnswered 
                    ? Colors.grey.withOpacity(0.1)
                    : isCorrect 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: !wasAnswered 
                      ? Colors.grey.withOpacity(0.3)
                      : isCorrect 
                          ? Colors.green.withOpacity(0.3)
                          : Colors.red.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: !wasAnswered 
                              ? Colors.grey
                              : isCorrect 
                                  ? Colors.green
                                  : Colors.red,
                        ),
                        child: Icon(
                          !wasAnswered 
                              ? Icons.help_outline
                              : isCorrect 
                                  ? Icons.check
                                  : Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Question ${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        !wasAnswered 
                            ? 'Not answered'
                            : isCorrect 
                                ? 'Correct'
                                : 'Incorrect',
                        style: TextStyle(
                          color: !wasAnswered 
                              ? Colors.grey[600]
                              : isCorrect 
                                  ? Colors.green[700]
                                  : Colors.red[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    question.text,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (wasAnswered) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Your answer: ${String.fromCharCode(65 + selectedAnswer!)}. ${question.options[selectedAnswer].text}',
                      style: TextStyle(
                        color: isCorrect ? Colors.green[700] : Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (!isCorrect && correctIndex >= 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Correct answer: ${question.correctAnswerText}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (correctIndex < 0) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_outlined,
                            size: 16,
                            color: Colors.orange[700],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'This question has no correct answer specified. Please contact your teacher.',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context.go(AppRoutes.studentDashboard);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home, size: 20),
                SizedBox(width: 8),
                Text(
                  'Back to Dashboard',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // TODO: Share results functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share functionality coming soon!'),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.share, size: 20),
                SizedBox(width: 8),
                Text(
                  'Share Results',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  int _calculateCorrectAnswers() {
    int correct = 0;
    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final correctIndex = question.correctAnswerIndex;
      final selectedAnswer = answers[i];
      
      // Debug logging for questions without correct answers
      if (correctIndex < 0) {
        print('=== QUESTION VALIDATION DEBUG ===');
        print('WARNING: Question ${i + 1} "${question.text}" has no correct answer set!');
        print('correctOptionIndex field: ${question.correctOptionIndex}');
        print('Calculated correctAnswerIndex: ${question.correctAnswerIndex}');
        print('Options count: ${question.options.length}');
        print('Question options:');
        for (int j = 0; j < question.options.length; j++) {
          print('  ${String.fromCharCode(65 + j)}. ${question.options[j].text} (isCorrect: ${question.options[j].isCorrect})');
        }
        print('=== END DEBUG ===');
      }
      
      if (correctIndex >= 0 && selectedAnswer == correctIndex) {
        correct++;
      }
    }
    return correct;
  }
}
