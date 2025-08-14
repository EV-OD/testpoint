import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:testpoint/models/test_model.dart';
import 'package:testpoint/models/user_model.dart';
import 'package:testpoint/services/test_service.dart';
import 'package:testpoint/services/group_service.dart';

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
    return _availableTests.where((test) {
      return test.isPublished && 
             test.dateTime.isBefore(now) && 
             !test.isExpired;
    }).toList();
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

      // Get user's groups
      final userGroups = await _groupService.getUserGroups(currentUser.uid);
      final groupIds = userGroups.map((g) => g.id).toList();

      if (groupIds.isEmpty) {
        _availableTests = [];
        _completedTests = [];
        _hasInitiallyLoaded = true;
        notifyListeners();
        return;
      }

      // Get tests for user's groups
      final allTests = await _testService.getTestsByGroups(groupIds);
      
      // Separate available and completed tests
      _availableTests = allTests.where((test) => 
        test.isPublished && !_isTestCompletedByStudent(test, currentUser.uid)
      ).toList();
      
      _completedTests = allTests.where((test) => 
        _isTestCompletedByStudent(test, currentUser.uid)
      ).toList();

      _hasInitiallyLoaded = true;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load tests: $e');
      _hasInitiallyLoaded = true;
    } finally {
      _setLoading(false);
    }
  }

  // Check if test is completed by student (placeholder - will be replaced with actual test session check)
  bool _isTestCompletedByStudent(Test test, String studentId) {
    // TODO: Check test_sessions collection for completion
    // For now, return false to show all tests as available
    return false;
  }

  // Check if test is available to take
  bool isTestAvailable(Test test) {
    final now = DateTime.now();
    return test.isPublished && 
           test.dateTime.isBefore(now) && 
           !test.isExpired &&
           !_isTestCompletedByStudent(test, _auth.currentUser?.uid ?? '');
  }

  // Get test status for display
  String getTestStatus(Test test) {
    final now = DateTime.now();
    final studentId = _auth.currentUser?.uid ?? '';

    if (_isTestCompletedByStudent(test, studentId)) {
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
}
