import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:testpoint/models/test_model.dart';
import 'package:testpoint/models/question_model.dart';
import 'package:testpoint/config/app_routes.dart';

import 'package:provider/provider.dart';
import 'package:testpoint/providers/student_provider.dart';
import 'package:testpoint/providers/test_provider.dart';

class TestTakingScreen extends StatefulWidget {
  final Test test;

  const TestTakingScreen({
    super.key,
    required this.test,
  });

  @override
  State<TestTakingScreen> createState() => _TestTakingScreenState();
}

class _TestTakingScreenState extends State<TestTakingScreen> with WidgetsBindingObserver {
  late PageController _pageController;
  int _currentQuestionIndex = 0;
  Map<int, int> _selectedAnswers = {};
  late DateTime _startTime;
  late Duration _remainingTime;
  
  List<Question> _questions = [];
  bool _isLoadingQuestions = true;
  String? _questionsErrorMessage;
  bool _isSubmitting = false; // Add this loading state

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();
    _startTime = DateTime.now();
    _remainingTime = Duration(minutes: widget.test.timeLimit);
    _loadQuestions();
    _startTimer();
  }

  Future<void> _loadQuestions() async {
    try {
      print('DEBUG: _loadQuestions() called for test ID: ${widget.test.id}');
      setState(() {
        _isLoadingQuestions = true;
        _questionsErrorMessage = null;
      });

      final testProvider = Provider.of<TestProvider>(context, listen: false);
      _questions = await testProvider.getQuestions(widget.test.id);
      _questions.shuffle(); // Randomize question order

      print('DEBUG: Fetched ${_questions.length} questions.');
      if (_questions.isNotEmpty) {
        print('DEBUG: First question: ${_questions.first.text}');
      }

      setState(() {
        _isLoadingQuestions = false;
      });
    } catch (e) {
      print('DEBUG: Error in _loadQuestions(): $e');
      setState(() {
        _isLoadingQuestions = false;
        _questionsErrorMessage = 'Failed to load questions: $e';
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      // App switched or closed - potential cheating
      _handleAntiCheatViolation('App switch detected');
    }
  }

  void _startTimer() {
    // Start countdown timer that updates every second
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      
      setState(() {
        _remainingTime = Duration(
          seconds: _remainingTime.inSeconds - 1,
        );
      });

      // Check if time is up
      if (_remainingTime.inSeconds <= 0) {
        _handleTimeUp();
        return false;
      }
      return true;
    });
  }

  void _handleTimeUp() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Time\'s Up!'),
        content: const Text('Your test time has expired. Your answers will be submitted automatically.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _submitTest();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleAntiCheatViolation(String violation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Security Violation'),
        content: Text('$violation. Your test will be submitted automatically.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _submitTest();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await _showExitConfirmation();
        return shouldExit ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.test.name}'),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final shouldExit = await _showExitConfirmation();
              if (shouldExit == true) {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _remainingTime.inMinutes < 10 ? Colors.red : Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(_remainingTime),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: _questions.isEmpty 
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No questions available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please contact your teacher',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentQuestionIndex = index;
                  });
                },
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return _buildQuestionPage(_questions[index], index);
                },
              ),
            ),
            _buildNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = _questions.isEmpty ? 0.0 : (_currentQuestionIndex + 1) / _questions.length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_selectedAnswers.length}/${_questions.length} answered',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(Question question, int questionIndex) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
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
            child: Text(
              question.text,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ...question.options.asMap().entries.map((entry) {
            final optionIndex = entry.key;
            final option = entry.value;
            final isSelected = _selectedAnswers[questionIndex] == optionIndex;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedAnswers[questionIndex] = optionIndex;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected 
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            '${String.fromCharCode(65 + optionIndex)}. ${option.text}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildNavigationBar() {
    final isFirstQuestion = _currentQuestionIndex == 0;
    final isLastQuestion = _questions.isEmpty || _currentQuestionIndex == _questions.length - 1;
    
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
          if (!isFirstQuestion)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousQuestion,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, size: 18),
                    SizedBox(width: 8),
                    Text('Previous'),
                  ],
                ),
              ),
            ),
          if (!isFirstQuestion && !isLastQuestion) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting 
                  ? null 
                  : (isLastQuestion ? _submitTest : _nextQuestion),
              style: ElevatedButton.styleFrom(
                backgroundColor: isLastQuestion 
                    ? Colors.green 
                    : Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isSubmitting && isLastQuestion) ...[
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Submitting...'),
                  ] else ...[
                    Text(isLastQuestion ? 'Submit Test' : 'Next'),
                    const SizedBox(width: 8),
                    Icon(
                      isLastQuestion ? Icons.send : Icons.arrow_forward,
                      size: 18,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }



  Future<bool?> _showExitConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Test?'),
        content: const Text(
          'Are you sure you want to exit the test? Your progress will be saved but you can continue later if time permits.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  void _submitTest() async {
    if (_isSubmitting) return; // Prevent double submission
    
    setState(() {
      _isSubmitting = true;
    });

    try {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final score = _calculateScore();
      
      await studentProvider.submitTest(widget.test, _questions, _selectedAnswers, score);
      
      if (mounted) {
        context.go(AppRoutes.testResults, extra: {
          'test': widget.test,
          'questions': _questions,
          'answers': _selectedAnswers,
          'score': score,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit test: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  int _calculateScore() {
    int correct = 0;
    for (int i = 0; i < _questions.length; i++) {
      // Ensure the question exists and has a valid correct answer index
      final correctIndex = _questions[i].correctAnswerIndex;
      if (correctIndex >= 0 && _selectedAnswers[i] == correctIndex) {
        correct++;
      }
    }
    // Avoid division by zero if there are no questions
    if (_questions.isEmpty) return 0;
    return ((correct / _questions.length) * 100).round();
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }
}
