import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:testpoint/models/test_model.dart';
import 'package:testpoint/models/question_model.dart';
import 'package:testpoint/models/group_model.dart';
import 'package:testpoint/repositories/test_repository.dart';
import 'package:testpoint/services/group_service.dart';

class TestService {
  final TestRepository _testRepository;
  final GroupService _groupService;
  final auth.FirebaseAuth _auth;

  TestService({
    TestRepository? testRepository,
    GroupService? groupService,
    auth.FirebaseAuth? firebaseAuth,
  })  : _testRepository = testRepository ?? TestRepository(),
        _groupService = groupService ?? GroupService(),
        _auth = firebaseAuth ?? auth.FirebaseAuth.instance;

  // Test CRUD operations
  Future<Test> createTest(Test test) async {
    try {
      // Ensure user is authenticated first
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated to create tests');
      }

      // Set test_maker to current user
      final testWithMaker = test.copyWith(testMaker: currentUser.uid);

      // Validate test data
      if (!validateTest(testWithMaker)) {
        throw Exception('Invalid test data: ${testWithMaker.getValidationErrors().join(', ')}');
      }
      
      // Create test in repository
      final testId = await _testRepository.createTest(testWithMaker);
      
      // Return test with generated ID
      return testWithMaker.copyWith(id: testId);
    } catch (e) {
      throw Exception('Failed to create test: $e');
    }
  }

  Future<Test> updateTest(Test test) async {
    try {
      // Validate ownership
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated to update tests');
      }

      if (!await validateTestOwnership(test.id, currentUser.uid)) {
        throw Exception('User does not have permission to update this test');
      }

      // Check if test can be edited
      if (!await canEditTest(test.id, currentUser.uid)) {
        throw Exception('Test cannot be edited after publication');
      }

      // Validate test data
      if (!validateTest(test)) {
        throw Exception('Invalid test data: ${test.getValidationErrors().join(', ')}');
      }

      await _testRepository.updateTest(test);
      return test;
    } catch (e) {
      throw Exception('Failed to update test: $e');
    }
  }

  Future<void> deleteTest(String testId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated to delete tests');
      }

      if (!await canDeleteTest(testId, currentUser.uid)) {
        throw Exception('Test cannot be deleted');
      }

      await _testRepository.deleteTest(testId);
    } catch (e) {
      throw Exception('Failed to delete test: $e');
    }
  }

  Future<List<Test>> getTestsByTeacher(String teacherId) async {
    try {
      return await _testRepository.getTestsByCreator(teacherId);
    } catch (e) {
      throw Exception('Failed to get tests by teacher: $e');
    }
  }

  Future<List<Test>> getTestsByGroup(String groupId) async {
    try {
      return await _testRepository.getTestsByGroup(groupId);
    } catch (e) {
      throw Exception('Failed to get tests by group: $e');
    }
  }

  Future<Test?> getTestById(String testId) async {
    try {
      return await _testRepository.getTest(testId);
    } catch (e) {
      throw Exception('Failed to get test: $e');
    }
  }

  // Question management
  Future<Question> addQuestion(String testId, Question question) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated to add questions');
      }

      if (!await validateTestOwnership(testId, currentUser.uid)) {
        throw Exception('User does not have permission to modify this test');
      }

      if (!await canEditTest(testId, currentUser.uid)) {
        throw Exception('Test cannot be modified after publication');
      }

      // Validate question
      if (!question.isValid()) {
        throw Exception('Invalid question data: ${question.getValidationErrors().join(', ')}');
      }

      final questionId = await _testRepository.addQuestion(testId, question);
      return question.copyWith(id: questionId);
    } catch (e) {
      throw Exception('Failed to add question: $e');
    }
  }

  Future<void> updateQuestion(String testId, Question question) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated to update questions');
      }

      if (!await validateTestOwnership(testId, currentUser.uid)) {
        throw Exception('User does not have permission to modify this test');
      }

      if (!await canEditTest(testId, currentUser.uid)) {
        throw Exception('Test cannot be modified after publication');
      }

      // Validate question
      if (!question.isValid()) {
        throw Exception('Invalid question data: ${question.getValidationErrors().join(', ')}');
      }

      await _testRepository.updateQuestion(testId, question.id, question);
    } catch (e) {
      throw Exception('Failed to update question: $e');
    }
  }

  Future<void> deleteQuestion(String testId, String questionId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated to delete questions');
      }

      if (!await validateTestOwnership(testId, currentUser.uid)) {
        throw Exception('User does not have permission to modify this test');
      }

      if (!await canEditTest(testId, currentUser.uid)) {
        throw Exception('Test cannot be modified after publication');
      }

      await _testRepository.deleteQuestion(testId, questionId);
    } catch (e) {
      throw Exception('Failed to delete question: $e');
    }
  }

  Future<List<Question>> getQuestions(String testId) async {
    try {
      return await _testRepository.getQuestions(testId);
    } catch (e) {
      throw Exception('Failed to get questions: $e');
    }
  }

  // Group operations
  Future<List<Group>> getAvailableGroups(String teacherId) async {
    try {
      return await _groupService.getAvailableGroups(teacherId);
    } catch (e) {
      throw Exception('Failed to get available groups: $e');
    }
  }

  // Validation methods
  Future<bool> validateTestOwnership(String testId, String teacherId) async {
    return await _testRepository.validateTestOwnership(testId, teacherId);
  }

  Future<bool> canEditTest(String testId, String teacherId) async {
    return await _testRepository.canEditTest(testId, teacherId);
  }

  Future<bool> canDeleteTest(String testId, String teacherId) async {
    return await _testRepository.canDeleteTest(testId, teacherId);
  }

  bool validateTest(Test test) {
    return test.isValid();
  }

  // Utility methods
  List<Question> randomizeQuestions(List<Question> questions) {
    final List<Question> shuffled = List.from(questions);
    shuffled.shuffle(Random());
    return shuffled;
  }

  bool isTestAvailable(Test test) {
    final now = DateTime.now();
    return now.isAfter(test.dateTime) && now.isBefore(test.dateTime.add(Duration(minutes: test.timeLimit)));
  }

  // Stream methods for real-time updates
  Stream<List<Test>> watchTestsByTeacher(String teacherId) {
    return _testRepository.watchTestsByCreator(teacherId);
  }

  Stream<List<Question>> watchQuestions(String testId) {
    return _testRepository.watchQuestions(testId);
  }

  Stream<Test?> watchTest(String testId) {
    return _testRepository.watchTest(testId);
  }

  // Test statistics and analytics
  Future<Map<String, dynamic>> getTestStatistics(String testId) async {
    try {
      final test = await getTestById(testId);
      if (test == null) {
        throw Exception('Test not found');
      }

      final questions = await getQuestions(testId);

      return {
        'testId': testId,
        'testName': test.name,
        'questionCount': questions.length,
        'timeLimit': test.timeLimit,
        'isPublished': test.isPublished,
        'isExpired': test.isExpired,
        'isAvailable': test.isAvailable,
        'createdAt': test.createdAt,
        'scheduledAt': test.dateTime,
      };
    } catch (e) {
      throw Exception('Failed to get test statistics: $e');
    }
  }

  // Batch operations
  Future<void> addMultipleQuestions(String testId, List<Question> questions) async {
    try {
      for (final question in questions) {
        await addQuestion(testId, question);
      }
    } catch (e) {
      throw Exception('Failed to add multiple questions: $e');
    }
  }

  Future<Test> duplicateTest(String testId, {String? newName, String? newGroupId, DateTime? newDateTime}) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated to duplicate tests');
      }

      // Get original test
      final originalTest = await getTestById(testId);
      if (originalTest == null) {
        throw Exception('Original test not found');
      }

      // Get original questions
      final originalQuestions = await getQuestions(testId);

      // Create new test
      final newTest = originalTest.copyWith(
        id: '', // Will be generated
        name: newName ?? '${originalTest.name} (Copy)',
        groupId: newGroupId ?? originalTest.groupId,
        dateTime: newDateTime ?? DateTime.now().add(const Duration(days: 1)),
        testMaker: currentUser.uid,
        createdAt: DateTime.now(),
        questionCount: 0, // Will be updated when questions are added
      );

      final createdTest = await createTest(newTest);

      // Add questions to new test
      for (final question in originalQuestions) {
        final newQuestion = question.copyWith(
          id: '', // Will be generated
          createdAt: DateTime.now(),
        );
        await addQuestion(createdTest.id, newQuestion);
      }

      return createdTest;
    } catch (e) {
      throw Exception('Failed to duplicate test: $e');
    }
  }
}