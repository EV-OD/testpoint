import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testpoint/models/question_model.dart';
import 'package:testpoint/models/test_model.dart';
import 'package:testpoint/models/test_session_model.dart';
import 'package:testpoint/providers/test_provider.dart';

class StudentTestResultsScreen extends StatefulWidget {
  final Test test;
  final TestSession submission;

  const StudentTestResultsScreen({
    super.key,
    required this.test,
    required this.submission,
  });

  @override
  State<StudentTestResultsScreen> createState() => _StudentTestResultsScreenState();
}

class _StudentTestResultsScreenState extends State<StudentTestResultsScreen> {
  List<Question> _questions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTestQuestions();
  }

  Future<void> _loadTestQuestions() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final testProvider = Provider.of<TestProvider>(context, listen: false);
      _questions = await testProvider.getQuestions(widget.test.id);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load test questions: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.test.name} - Results'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final question = _questions[index];
                    final studentAnswer = widget.submission.answers[question.id];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Q${index + 1}: ${question.text}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            ...question.options.asMap().entries.map((entry) {
                              final optionIndex = entry.key;
                              final option = entry.value;
                              final isCorrect = option.isCorrect;
                              final isStudentAnswer = studentAnswer?.selectedAnswerIndex == optionIndex;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isCorrect
                                        ? Colors.green
                                        : isStudentAnswer
                                            ? Colors.red
                                            : Theme.of(context).colorScheme.outline,
                                    width: isCorrect || isStudentAnswer ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: isCorrect
                                      ? Colors.green.shade50
                                      : isStudentAnswer
                                          ? Colors.red.shade50
                                          : null,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isCorrect ? Icons.check_circle : Icons.cancel,
                                      color: isCorrect ? Colors.green : Colors.red,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(option.text),
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
    );
  }
}
