import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:testpoint/models/test_model.dart';
import 'package:testpoint/services/test_service.dart';

class TeacherDashboardProvider with ChangeNotifier {
  final TestService _testService;
  final auth.FirebaseAuth _auth;

  TeacherDashboardProvider({
    TestService? testService,
    auth.FirebaseAuth? firebaseAuth,
  })  : _testService = testService ?? TestService(),
        _auth = firebaseAuth ?? auth.FirebaseAuth.instance;

  // State variables
  List<Test> _allTests = [];
  bool _isLoading = false;
  bool _hasInitiallyLoaded = false;
  String? _errorMessage;

  // Getters
  List<Test> get allTests => List.unmodifiable(_allTests);
  bool get isLoading => _isLoading;
  bool get hasInitiallyLoaded => _hasInitiallyLoaded;
  String? get errorMessage => _errorMessage;

  // Filtered test lists by status
  List<Test> get draftTests => _allTests.where((test) => test.status == TestStatus.draft).toList();
  List<Test> get publishedTests => _allTests.where((test) => test.status == TestStatus.published).toList();
  List<Test> get completedTests => _allTests.where((test) => test.status == TestStatus.completed).toList();

  // Get tests by status
  List<Test> getTestsByStatus(TestStatus status) {
    return _allTests.where((test) => test.status == status).toList();
  }

  // Load all tests for the current teacher
  Future<void> loadTeacherTests() async {
    try {
      _setLoading(true);
      _clearError();

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated');
      }

      _allTests = await _testService.getTestsByTeacher(currentUser.uid);
      _hasInitiallyLoaded = true;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load tests: $e');
      _hasInitiallyLoaded = true; // Mark as loaded even on error to prevent infinite loop
    } finally {
      _setLoading(false);
    }
  }

  // Refresh tests
  Future<void> refreshTests() async {
    await loadTeacherTests();
  }

  // Delete a test
  Future<bool> deleteTest(String testId) async {
    try {
      _setLoading(true);
      _clearError();

      await _testService.deleteTest(testId);
      
      // Remove from local list
      _allTests.removeWhere((test) => test.id == testId);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Failed to delete test: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Publish a draft test
  Future<bool> publishTest(String testId) async {
    try {
      _setLoading(true);
      _clearError();

      // Find the test
      final testIndex = _allTests.indexWhere((test) => test.id == testId);
      if (testIndex == -1) {
        throw Exception('Test not found');
      }

      final test = _allTests[testIndex];
      final publishedTest = test.copyWith(status: TestStatus.published);
      
      await _testService.updateTestStatus(publishedTest);
      
      // Update local list
      _allTests[testIndex] = publishedTest;
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Failed to publish test: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Mark test as completed
  Future<bool> markTestCompleted(String testId) async {
    try {
      _setLoading(true);
      _clearError();

      // Find the test
      final testIndex = _allTests.indexWhere((test) => test.id == testId);
      if (testIndex == -1) {
        throw Exception('Test not found');
      }

      final test = _allTests[testIndex];
      final completedTest = test.copyWith(status: TestStatus.completed);
      
      await _testService.updateTestStatus(completedTest);
      
      // Update local list
      _allTests[testIndex] = completedTest;
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Failed to mark test as completed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Restore published test to draft
  Future<bool> restoreToDraft(String testId) async {
    try {
      _setLoading(true);
      _clearError();

      // Find the test
      final testIndex = _allTests.indexWhere((test) => test.id == testId);
      if (testIndex == -1) {
        throw Exception('Test not found');
      }

      final test = _allTests[testIndex];
      
      // Check if test can be restored to draft (shouldn't have started yet)
      if (test.isAvailable) {
        throw Exception('Cannot restore to draft: Test has already started or is in progress');
      }
      
      final draftTest = test.copyWith(status: TestStatus.draft);
      
      await _testService.updateTestStatus(draftTest);
      
      // Update local list
      _allTests[testIndex] = draftTest;
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Failed to restore test to draft: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Stream for real-time updates
  Stream<List<Test>> watchTeacherTests() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }
    
    return _testService.watchTestsByTeacher(currentUser.uid);
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
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

  // Get test statistics
  Map<String, int> getTestStatistics() {
    return {
      'total': _allTests.length,
      'drafts': draftTests.length,
      'published': publishedTests.length,
      'completed': completedTests.length,
    };
  }

  // Check if user can edit test
  bool canEditTest(Test test) {
    return test.status == TestStatus.draft || 
           (test.status == TestStatus.published && !test.isAvailable);
  }

  // Check if user can delete test
  bool canDeleteTest(Test test) {
    return test.status == TestStatus.draft;
  }

  // Check if user can publish test
  bool canPublishTest(Test test) {
    return test.status == TestStatus.draft && test.questionCount > 0;
  }

  // Check if user can restore test to draft
  bool canRestoreToDraft(Test test) {
    return test.status == TestStatus.published && !test.isAvailable;
  }

  // Helper method for testing
  void setTestsForTesting(List<Test> tests) {
    _allTests = tests;
    notifyListeners();
  }
}