import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:testpoint/models/test_model.dart';
import 'package:testpoint/models/user_model.dart';
import 'package:testpoint/services/test_service.dart';
import 'package:testpoint/services/group_service.dart';
import 'package:testpoint/models/test_session_model.dart';

import 'package:testpoint/models/question_model.dart';

class StudentProvider extends ChangeNotifier {
  final TestService _testService;
  final GroupService _groupService;
  final auth.FirebaseAuth _auth;

  List<Test> _availableTests = [];
  List<Test> _completedTests = [];
  bool _loading = false;
  String? _error;
  bool _hasInitiallyLoaded = false;

  StudentProvider({
    TestService? testService,
    GroupService? groupService,
    auth.FirebaseAuth? firebaseAuth,
  })  : _testService = testService ?? TestService(),
        _groupService = groupService ?? GroupService(),
        _auth = firebaseAuth ?? auth.FirebaseAuth.instance {
    _initialize();
  }

  // Getters
  List<Test> get availableTests => _availableTests;
  List<Test> get completedTests => _completedTests;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasInitiallyLoaded => _hasInitiallyLoaded;

  // Get pending tests (available and not yet taken)
  List<Test> get pendingTests {
    final now = DateTime.now();
    
    final filtered = _availableTests.where((test) {
      // Show published tests that are not expired
      // This includes both current tests and future scheduled tests
      return test.isPublished && !test.isExpired;
    }).toList();
    
    return filtered;
  }

  // Private methods
  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  Future<void> _initialize() async {
    await loadStudentTests();
  }

  // Load tests for the current student
  Future<void> loadStudentTests() async {
    try {
      _setLoading(true);
      _clearError();

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated');
      }

      print('--- loadStudentTests ---');
      print('User: ${currentUser.uid}');

      // Get user's groups
      final userGroups = await _groupService.getUserGroups(currentUser.uid);
      final groupIds = userGroups.map((g) => g.id).toList();

      print('Groups: $groupIds');

      if (groupIds.isEmpty) {
        _availableTests = [];
        _completedTests = [];
        _hasInitiallyLoaded = true;
        notifyListeners();
        print('No groups found. Tests loaded: 0 available, 0 completed.');
        print('--- end loadStudentTests ---');
        return;
      }

      // Get tests for user's groups
      final allTests = await _testService.getTestsByGroups(groupIds);
      print('Total tests fetched: ${allTests.length}');

      for (var test in allTests) {
        print('  - Test: ${test.name} (${test.id})');
      }
      
      // Separate available and completed tests
      final newAvailableTests = <Test>[];
      final newCompletedTests = <Test>[];

      for (final test in allTests) {
        final isCompleted = await _isTestCompletedByStudent(test, currentUser.uid);
        print('  - Test: ${test.name}, isCompleted: $isCompleted');
        if (isCompleted) {
          newCompletedTests.add(test);
        } else {
          newAvailableTests.add(test);
        }
      }

      _availableTests = newAvailableTests;
      _completedTests = newCompletedTests;

      print('Available tests: ${_availableTests.map((t) => t.name).toList()}');
      print('Completed tests: ${_completedTests.map((t) => t.name).toList()}');
      
      _hasInitiallyLoaded = true;
      notifyListeners();
      print('--- end loadStudentTests ---');
    } catch (e) {
      print('Error loading tests: $e');
      _setError('Failed to load tests: $e');
      _hasInitiallyLoaded = true;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> _isTestCompletedByStudent(Test test, String studentId) async {
    print('--- _isTestCompletedByStudent ---');
    print('Test: ${test.name} (${test.id}), Student: $studentId');
    final session = await _testService.getTestSession(test.id, studentId);
    if (session != null) {
      print('  - Session found: status = ${session.status}');
      final bool isCompleted = session.status == TestSessionStatus.completed || session.status == TestSessionStatus.submitted;
      print('  - Returning: $isCompleted');
      print('--- end _isTestCompletedByStudent ---');
      return isCompleted;
    } else {
      print('  - No session found.');
      print('  - Returning: false');
      print('--- end _isTestCompletedByStudent ---');
      return false;
    }
  }

  Future<void> submitTest(Test test, List<Question> questions, Map<int, int> answers, int score) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated');
      }

      final questionOrder = questions.map((q) => q.id).toList();
      final studentAnswers = <String, StudentAnswer>{};
      for (int i = 0; i < questions.length; i++) {
        final question = questions[i];
        final selectedAnswerIndex = answers[i];
        if (selectedAnswerIndex != null) {
          final correctIndex = question.correctAnswerIndex;
          final isCorrect = correctIndex >= 0 && correctIndex == selectedAnswerIndex;
          studentAnswers[question.id] = StudentAnswer(
            selectedAnswerIndex: selectedAnswerIndex,
            answeredAt: DateTime.now(),
            isCorrect: isCorrect,
          );
        }
      }

      final session = TestSession(
        id: '${test.id}_${currentUser.uid}',
        testId: test.id,
        studentId: currentUser.uid,
        startTime: DateTime.now(), // This should be set when the test starts
        endTime: DateTime.now(),
        timeLimit: test.timeLimit,
        answers: studentAnswers,
        questionOrder: questionOrder,
        status: TestSessionStatus.submitted,
        violations: [],
        finalScore: score,
        createdAt: DateTime.now(),
      );

      await _testService.submitTestSession(session);
      await refreshTests();
    } catch (e) {
      _setError('Failed to submit test: $e');
    }
  }

  // Check if test is available to take
  bool isTestAvailable(Test test) {
    final now = DateTime.now();
    
    // Test is available if:
    // 1. It's published
    // 2. The scheduled time has passed (or is very close)
    // 3. It's not expired
    // 4. Student hasn't completed it
    return test.isPublished && 
           test.dateTime.isBefore(now.add(Duration(minutes: 5))) && // Allow 5 minutes early access
           !test.isExpired &&
           !_completedTests.any((t) => t.id == test.id);
  }

  // Get test status for display
  String getTestStatus(Test test) {
    final now = DateTime.now();
    final studentId = _auth.currentUser?.uid ?? '';

    if (_completedTests.any((t) => t.id == test.id)) {
      return 'Completed';
    }

    if (test.isExpired) {
      return 'Expired';
    }

    if (test.dateTime.isAfter(now)) {
      final difference = test.dateTime.difference(now);
      if (difference.inDays > 0) {
        return 'Starts in ${difference.inDays} day(s)';
      } else if (difference.inHours > 0) {
        return 'Starts in ${difference.inHours} hour(s)';
      } else {
        return 'Starts in ${difference.inMinutes} minute(s)';
      }
    }

    return 'Available';
  }

  // Refresh tests
  Future<void> refreshTests() async {
    await loadStudentTests();
  }

  // Get test by ID
  Test? getTestById(String testId) {
    try {
      return [..._availableTests, ..._completedTests]
          .firstWhere((test) => test.id == testId);
    } catch (e) {
      return null;
    }
  }

  // Get test session data for completed tests
  Future<TestSession?> getTestSession(String testId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated');
      }
      
      return await _testService.getTestSession(testId, currentUser.uid);
    } catch (e) {
      print('Error getting test session: $e');
      return null;
    }
  }

  // Get test questions for results display
  Future<List<Question>> getTestQuestions(String testId) async {
    try {
      return await _testService.getQuestions(testId);
    } catch (e) {
      print('Error getting test questions: $e');
      return [];
    }
  }
}
