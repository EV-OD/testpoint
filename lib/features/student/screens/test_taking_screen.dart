import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:testpoint/models/test_model.dart';
import 'package:testpoint/models/question_model.dart';
import 'package:testpoint/config/app_routes.dart';

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
  
  // Dummy questions for demonstration
  final List<Question> _questions = [
    Question(
      id: '1',
      text: 'What is the capital of France?',
      options: [
        QuestionOption(id: '1a', text: 'London', isCorrect: false),
        QuestionOption(id: '1b', text: 'Berlin', isCorrect: false),
        QuestionOption(id: '1c', text: 'Paris', isCorrect: true),
        QuestionOption(id: '1d', text: 'Madrid', isCorrect: false),
      ],
      createdAt: DateTime.now(),
    ),
    Question(
      id: '2',
      text: 'Which planet is known as the Red Planet?',
      options: [
        QuestionOption(id: '2a', text: 'Venus', isCorrect: false),
        QuestionOption(id: '2b', text: 'Mars', isCorrect: true),
        QuestionOption(id: '2c', text: 'Jupiter', isCorrect: false),
        QuestionOption(id: '2d', text: 'Saturn', isCorrect: false),
      ],
      createdAt: DateTime.now(),
    ),
    Question(
      id: '3',
      text: 'What is 2 + 2?',
      options: [
        QuestionOption(id: '3a', text: '3', isCorrect: false),
        QuestionOption(id: '3b', text: '4', isCorrect: true),
        QuestionOption(id: '3c', text: '5', isCorrect: false),
        QuestionOption(id: '3d', text: '6', isCorrect: false),
      ],
      createdAt: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();
    _startTime = DateTime.now();
    _remainingTime = Duration(minutes: widget.test.timeLimit);
    _startTimer();
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
        body: Column(
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
    final progress = (_currentQuestionIndex + 1) / _questions.length;
    
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
    final isLastQuestion = _currentQuestionIndex == _questions.length - 1;
    
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
              onPressed: isLastQuestion ? _submitTest : _nextQuestion,
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
                  Text(isLastQuestion ? 'Submit Test' : 'Next'),
                  const SizedBox(width: 8),
                  Icon(
                    isLastQuestion ? Icons.send : Icons.arrow_forward,
                    size: 18,
                  ),
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

  void _submitTest() {
    context.go(AppRoutes.testResults, extra: {
      'test': widget.test,
      'questions': _questions,
      'answers': _selectedAnswers,
      'score': _calculateScore(),
    });
  }

  int _calculateScore() {
    int correct = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i].correctAnswerIndex) {
        correct++;
      }
    }
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
