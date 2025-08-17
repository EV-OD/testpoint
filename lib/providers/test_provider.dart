import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:testpoint/models/test_model.dart';
import 'package:testpoint/models/question_model.dart';
import 'package:testpoint/models/group_model.dart';
import 'package:testpoint/services/test_service.dart';

class TestProvider with ChangeNotifier {
  final TestService _testService;
  final auth.FirebaseAuth _auth;

  TestProvider({
    TestService? testService,
    auth.FirebaseAuth? firebaseAuth,
  })  : _testService = testService ?? TestService(),
        _auth = firebaseAuth ?? auth.FirebaseAuth.instance;

  // State variables
  Test? _currentTest;
  List<Question> _questions = [];
  List<Group> _availableGroups = [];
  List<Test> _teacherTests = [];
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _selectedGroupId; // Track selected group during form filling

  // Form controllers
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController groupController = TextEditingController();
  final TextEditingController timeLimitController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  // Question form controllers
  final TextEditingController questionTextController = TextEditingController();
  final List<TextEditingController> optionControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  int _selectedCorrectAnswer = 0;

  // Getters
  Test? get currentTest => _currentTest;
  List<Question> get questions => List.unmodifiable(_questions);
  List<Group> get availableGroups => List.unmodifiable(_availableGroups);
  List<Test> get teacherTests => List.unmodifiable(_teacherTests);
  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  int get selectedCorrectAnswer => _selectedCorrectAnswer;
  int get questionCount => _questions.length;

  // Computed properties
  bool get canGoNext => _validateCurrentStep();
  bool get canGoPrevious => _currentStep > 0;
  bool get isLastStep => _currentStep >= 2; // 0: Basic Info, 1: Questions, 2: Preview
  String? get selectedGroupId => _selectedGroupId ?? _currentTest?.groupId;
  Group? get selectedGroup => _availableGroups.isNotEmpty && selectedGroupId != null
      ? _availableGroups.firstWhere(
          (group) => group.id == selectedGroupId,
          orElse: () => _availableGroups.first,
        )
      : null;

  @override
  void dispose() {
    nameController.dispose();
    groupController.dispose();
    timeLimitController.dispose();
    dateController.dispose();
    timeController.dispose();
    questionTextController.dispose();
    for (final controller in optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Test creation workflow
  void startNewTest() {
    _currentTest = null;
    _questions.clear();
    _selectedGroupId = null;
    _currentStep = 0;
    _clearForm();
    _clearError();
    notifyListeners();
  }

  void loadTestForEditing(Test test) {
    _currentTest = test;
    _selectedGroupId = test.groupId;
    _populateFormFromTest(test);
    _loadQuestionsForTest(test.id);
    _currentStep = 0;
    _clearError();
    notifyListeners();
  }

  // Step navigation
  void nextStep() {
    if (canGoNext && !isLastStep) {
      _currentStep++;
      _clearError();
      notifyListeners();
    }
  }

  void previousStep() {
    if (canGoPrevious) {
      _currentStep--;
      _clearError();
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 2) {
      _currentStep = step;
      _clearError();
      notifyListeners();
    }
  }

  // Basic test information
  Future<void> saveBasicInfo() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      _setLoading(true);
      _clearError();

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated');
      }

      // Parse date and time
      final dateTime = _parseDateTimeFromControllers();
      
      final test = Test(
        id: _currentTest?.id ?? '',
        name: nameController.text.trim(),
        groupId: selectedGroupId ?? '',
        timeLimit: int.parse(timeLimitController.text),
        questionCount: _questions.length,
        dateTime: dateTime,
        testMaker: currentUser.uid,
        createdAt: _currentTest?.createdAt ?? DateTime.now(),
      );

      if (_currentTest == null) {
        // Create new test
        _currentTest = await _testService.createTest(test);
      } else {
        // Update existing test
        _currentTest = await _testService.updateTest(test);
      }

      nextStep();
    } catch (e) {
      _setError('Failed to save test information: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Question management
  void setSelectedCorrectAnswer(int index) {
    if (index >= 0 && index < 4) {
      _selectedCorrectAnswer = index;
      notifyListeners();
    }
  }

  Future<void> addQuestion() async {
    if (!_validateQuestionForm()) {
      return;
    }

    if (_currentTest == null) {
      _setError('Test must be created before adding questions');
      return;
    }

    try {
      _setSaving(true);
      _clearError();

      final options = optionControllers.asMap().entries.map((entry) {
        return QuestionOption(
          id: 'opt${entry.key + 1}',
          text: entry.value.text.trim(),
          isCorrect: entry.key == _selectedCorrectAnswer,
        );
      }).toList();

      final question = Question(
        id: '',
        text: questionTextController.text.trim(),
        options: options,
        createdAt: DateTime.now(),
      );

      final addedQuestion = await _testService.addQuestion(_currentTest!.id, question);
      _questions.add(addedQuestion);
      
      // Update test question count
      _currentTest = _currentTest!.copyWith(questionCount: _questions.length);
      
      _clearQuestionForm();
      notifyListeners();
    } catch (e) {
      _setError('Failed to add question: $e');
    } finally {
      _setSaving(false);
    }
  }

  Future<void> updateQuestion(int index, Question question) async {
    if (index < 0 || index >= _questions.length || _currentTest == null) {
      return;
    }

    try {
      _setSaving(true);
      _clearError();

      await _testService.updateQuestion(_currentTest!.id, question);
      _questions[index] = question;
      notifyListeners();
    } catch (e) {
      _setError('Failed to update question: $e');
    } finally {
      _setSaving(false);
    }
  }

  Future<void> deleteQuestion(int index) async {
    if (index < 0 || index >= _questions.length || _currentTest == null) {
      return;
    }

    try {
      _setSaving(true);
      _clearError();

      final question = _questions[index];
      await _testService.deleteQuestion(_currentTest!.id, question.id);
      _questions.removeAt(index);
      
      // Update test question count
      _currentTest = _currentTest!.copyWith(questionCount: _questions.length);
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete question: $e');
    } finally {
      _setSaving(false);
    }
  }

  // Data loading
  Future<void> loadAvailableGroups() async {
    try {
      _setLoading(true);
      _clearError();

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated');
      }

      _availableGroups = await _testService.getAvailableGroups(currentUser.uid);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load groups: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTeacherTests() async {
    try {
      _setLoading(true);
      _clearError();

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated');
      }

      _teacherTests = await _testService.getTestsByTeacher(currentUser.uid);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load tests: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<Test?> getTestById(String testId) async {
    try {
      return await _testService.getTestById(testId);
    } catch (e) {
      _setError('Failed to load test: $e');
      return null;
    }
  }

  Future<void> _loadQuestionsForTest(String testId) async {
    try {
      _questions = await _testService.getQuestions(testId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load questions: $e');
    }
  }

  // Public method to get questions for any test
  Future<List<Question>> getQuestions(String testId) async {
    try {
      print('DEBUG: TestProvider.getQuestions called for testId: $testId');
      final questions = await _testService.getQuestions(testId);
      print('DEBUG: TestProvider.getQuestions fetched ${questions.length} questions.');
      return questions;
    } catch (e) {
      print('DEBUG: Error in TestProvider.getQuestions: $e');
      throw Exception('Failed to load questions: $e');
    }
  }

  // Group selection
  void selectGroup(String groupId) {
    if (_availableGroups.any((group) => group.id == groupId)) {
      _selectedGroupId = groupId;
      // Also update current test if it exists
      if (_currentTest != null) {
        _currentTest = _currentTest!.copyWith(groupId: groupId);
      }
      notifyListeners();
    }
  }

  // Test publishing and draft management
  Future<void> saveAsDraft() async {
    if (_currentTest == null) {
      _setError('No test to save as draft');
      return;
    }

    try {
      _setSaving(true);
      _clearError();

      // Update test status to draft
      final draftTest = _currentTest!.copyWith(status: TestStatus.draft);
      _currentTest = await _testService.updateTest(draftTest);
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to save as draft: $e');
    } finally {
      _setSaving(false);
    }
  }

  Future<void> publishTest() async {
    if (_currentTest == null) {
      _setError('No test to publish');
      return;
    }

    if (_questions.isEmpty) {
      _setError('Test must have at least one question');
      return;
    }

    try {
      _setSaving(true);
      _clearError();

      // Validate test before publishing
      if (!_currentTest!.isValid()) {
        throw Exception('Test validation failed: ${_currentTest!.getValidationErrors().join(', ')}');
      }

      // Update test status to published
      final publishedTest = _currentTest!.copyWith(status: TestStatus.published);
      _currentTest = await _testService.updateTest(publishedTest);
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to publish test: $e');
    } finally {
      _setSaving(false);
    }
  }

  // Validation methods
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Basic info
        return formKey.currentState?.validate() ?? false;
      case 1: // Questions
        return _questions.isNotEmpty;
      case 2: // Preview
        return true;
      default:
        return false;
    }
  }

  bool _validateQuestionForm() {
    if (questionTextController.text.trim().isEmpty) {
      _setError('Question text is required');
      return false;
    }

    if (questionTextController.text.trim().length < 10) {
      _setError('Question text must be at least 10 characters');
      return false;
    }

    for (int i = 0; i < optionControllers.length; i++) {
      if (optionControllers[i].text.trim().isEmpty) {
        _setError('Option ${i + 1} is required');
        return false;
      }
    }

    // Check for duplicate options
    final optionTexts = optionControllers.map((c) => c.text.trim().toLowerCase()).toList();
    final uniqueTexts = optionTexts.toSet();
    if (uniqueTexts.length != optionTexts.length) {
      _setError('All options must be unique');
      return false;
    }

    return true;
  }

  // Helper methods
  void _clearForm() {
    nameController.clear();
    groupController.clear();
    timeLimitController.text = '60'; // Default 60 minutes
    dateController.clear();
    timeController.clear();
    _selectedGroupId = null;
    _clearQuestionForm();
  }

  void _clearQuestionForm() {
    questionTextController.clear();
    for (final controller in optionControllers) {
      controller.clear();
    }
    _selectedCorrectAnswer = 0;
  }

  void _populateFormFromTest(Test test) {
    nameController.text = test.name;
    timeLimitController.text = test.timeLimit.toString();
    
    // Format date and time
    final dateTime = test.dateTime;
    dateController.text = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    timeController.text = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  DateTime _parseDateTimeFromControllers() {
    // Parse date (DD/MM/YYYY)
    final dateParts = dateController.text.split('/');
    final day = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final year = int.parse(dateParts[2]);

    // Parse time (HH:MM)
    final timeParts = timeController.text.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    return DateTime(year, month, day, hour, minute);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSaving(bool saving) {
    _isSaving = saving;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Public method to clear errors
  void clearError() {
    _clearError();
    notifyListeners();
  }
}