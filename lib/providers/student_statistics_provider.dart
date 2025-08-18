import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:testpoint/services/test_service.dart';
import 'package:testpoint/services/group_service.dart';
import 'package:testpoint/models/test_session_model.dart';

class StudentStatistics {
  final int testsTaken;
  final int pendingTests;
  final double averageScore;
  final int bestScore;
  final int totalQuestions;
  final int correctAnswers;

  StudentStatistics({
    required this.testsTaken,
    required this.pendingTests,
    required this.averageScore,
    required this.bestScore,
    required this.totalQuestions,
    required this.correctAnswers,
  });

  factory StudentStatistics.empty() {
    return StudentStatistics(
      testsTaken: 0,
      pendingTests: 0,
      averageScore: 0.0,
      bestScore: 0,
      totalQuestions: 0,
      correctAnswers: 0,
    );
  }
}

class StudentStatisticsProvider with ChangeNotifier {
  final TestService _testService;
  final GroupService _groupService;
  final auth.FirebaseAuth _auth;

  StudentStatistics _statistics = StudentStatistics.empty();
  bool _loading = false;
  String? _error;
  bool _hasInitiallyLoaded = false;

  StudentStatisticsProvider({
    TestService? testService,
    GroupService? groupService,
    auth.FirebaseAuth? firebaseAuth,
  })  : _testService = testService ?? TestService(),
        _groupService = groupService ?? GroupService(),
        _auth = firebaseAuth ?? auth.FirebaseAuth.instance {
    _initialize();
  }

  // Getters
  StudentStatistics get statistics => _statistics;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasInitiallyLoaded => _hasInitiallyLoaded;

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
    await calculateStatistics();
  }

  // Calculate comprehensive student statistics
  Future<void> calculateStatistics() async {
    try {
      _setLoading(true);
      _clearError();

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated');
      }

      final studentId = currentUser.uid;

      // Get user's groups
      final userGroups = await _groupService.getUserGroups(studentId);
      final groupIds = userGroups.map((g) => g.id).toList();

      if (groupIds.isEmpty) {
        _statistics = StudentStatistics.empty();
        _hasInitiallyLoaded = true;
        notifyListeners();
        return;
      }

      // Get all tests for user's groups
      final allTests = await _testService.getTestsByGroups(groupIds);

      // Calculate pending tests (published, not expired, not completed)
      int pendingCount = 0;
      List<TestSession> completedSessions = [];
      
      for (final test in allTests) {
        final session = await _testService.getTestSession(test.id, studentId);
        
        if (session != null && 
            (session.status == TestSessionStatus.completed || 
             session.status == TestSessionStatus.submitted)) {
          completedSessions.add(session);
        } else if (test.isPublished && !test.isExpired) {
          pendingCount++;
        }
      }

      // Calculate statistics from completed sessions
      final testsTaken = completedSessions.length;
      double averageScore = 0.0;
      int bestScore = 0;
      int totalQuestions = 0;
      int correctAnswers = 0;

      if (testsTaken > 0) {
        final scores = completedSessions.map((s) => s.finalScore ?? 0).toList();
        
        // Calculate average score
        final totalScore = scores.fold<int>(0, (sum, score) => sum + score);
        averageScore = totalScore / testsTaken;
        
        // Find best score
        bestScore = scores.reduce((a, b) => a > b ? a : b);
        
        // Count total questions and correct answers
        for (final session in completedSessions) {
          totalQuestions += session.answers.length;
          correctAnswers += session.answers.values
              .where((answer) => answer.isCorrect)
              .length;
        }
      }

      _statistics = StudentStatistics(
        testsTaken: testsTaken,
        pendingTests: pendingCount,
        averageScore: averageScore,
        bestScore: bestScore,
        totalQuestions: totalQuestions,
        correctAnswers: correctAnswers,
      );

      _hasInitiallyLoaded = true;
      notifyListeners();
    } catch (e) {
      _setError('Failed to calculate statistics: $e');
      _hasInitiallyLoaded = true;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh statistics
  Future<void> refreshStatistics() async {
    await calculateStatistics();
  }

  // Get formatted average score
  String getFormattedAverageScore() {
    if (_statistics.testsTaken == 0) return 'N/A';
    return '${_statistics.averageScore.toStringAsFixed(1)}%';
  }

  // Get formatted best score
  String getFormattedBestScore() {
    if (_statistics.testsTaken == 0) return 'N/A';
    return '${_statistics.bestScore}%';
  }

  // Get accuracy percentage
  String getAccuracyPercentage() {
    if (_statistics.totalQuestions == 0) return 'N/A';
    final accuracy = (_statistics.correctAnswers / _statistics.totalQuestions) * 100;
    return '${accuracy.toStringAsFixed(1)}%';
  }

  // Get performance grade
  String getPerformanceGrade() {
    if (_statistics.testsTaken == 0) return 'N/A';
    
    final avg = _statistics.averageScore;
    if (avg >= 90) return 'A+';
    if (avg >= 85) return 'A';
    if (avg >= 80) return 'A-';
    if (avg >= 75) return 'B+';
    if (avg >= 70) return 'B';
    if (avg >= 65) return 'B-';
    if (avg >= 60) return 'C+';
    if (avg >= 55) return 'C';
    if (avg >= 50) return 'C-';
    if (avg >= 40) return 'D';
    return 'F';
  }

  // Get improvement trend (simplified)
  String getImprovementTrend() {
    if (_statistics.testsTaken < 2) return 'Insufficient data';
    
    // This is a simplified version - you could enhance this by 
    // analyzing the chronological order of test scores
    final avg = _statistics.averageScore;
    if (avg >= 80) return 'Excellent progress';
    if (avg >= 70) return 'Good progress';
    if (avg >= 60) return 'Steady progress';
    return 'Needs improvement';
  }
}
