import 'package:testpoint/services/test_service.dart';
import 'package:testpoint/models/test_model.dart';
import 'package:testpoint/models/question_model.dart';
import 'package:testpoint/models/group_model.dart';

class MockTestService implements TestService {
  List<Test> _tests = [];
  List<Question> _questions = [];
  List<Group> _groups = [];
  Question? _mockQuestion;
  Duration? _delay;

  void setMockTests(List<Test> tests) {
    _tests = tests;
  }

  void setMockQuestions(List<Question> questions) {
    _questions = questions;
  }

  void setMockGroups(List<Group> groups) {
    _groups = groups;
  }

  void setMockQuestion(Question question) {
    _mockQuestion = question;
  }

  void setDelay(Duration delay) {
    _delay = delay;
  }

  Future<void> _simulateDelay() async {
    if (_delay != null) {
      await Future.delayed(_delay!);
    }
  }

  @override
  Future<Test> createTest(Test test) async {
    await _simulateDelay();
    final newTest = test.copyWith(id: 'test_${_tests.length + 1}');
    _tests.add(newTest);
    return newTest;
  }

  @override
  Future<Test> updateTest(Test test) async {
    await _simulateDelay();
    final index = _tests.indexWhere((t) => t.id == test.id);
    if (index != -1) {
      _tests[index] = test;
    }
    return test;
  }

  @override
  Future<Test> updateTestStatus(Test test) async {
    await _simulateDelay();
    final index = _tests.indexWhere((t) => t.id == test.id);
    if (index != -1) {
      _tests[index] = test;
    }
    return test;
  }

  @override
  Future<void> deleteTest(String testId) async {
    await _simulateDelay();
    _tests.removeWhere((test) => test.id == testId);
  }

  @override
  Future<List<Test>> getTestsByTeacher(String teacherId) async {
    await _simulateDelay();
    return _tests.where((test) => test.testMaker == teacherId).toList();
  }

  @override
  Future<List<Test>> getTestsByGroup(String groupId) async {
    await _simulateDelay();
    return _tests.where((test) => test.groupId == groupId).toList();
  }

  @override
  Future<Test?> getTestById(String testId) async {
    await _simulateDelay();
    try {
      return _tests.firstWhere((test) => test.id == testId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Group>> getAvailableGroups(String teacherId) async {
    await _simulateDelay();
    return _groups;
  }

  @override
  Future<Question> addQuestion(String testId, Question question) async {
    await _simulateDelay();
    final newQuestion = _mockQuestion ?? question.copyWith(id: 'q_${_questions.length + 1}');
    _questions.add(newQuestion);
    return newQuestion;
  }

  @override
  Future<void> updateQuestion(String testId, Question question) async {
    await _simulateDelay();
    final index = _questions.indexWhere((q) => q.id == question.id);
    if (index != -1) {
      _questions[index] = question;
    }
  }

  @override
  Future<void> deleteQuestion(String testId, String questionId) async {
    await _simulateDelay();
    _questions.removeWhere((question) => question.id == questionId);
  }

  @override
  Future<List<Question>> getQuestions(String testId) async {
    await _simulateDelay();
    return List.from(_questions);
  }

  @override
  Future<bool> validateTestOwnership(String testId, String teacherId) async {
    await _simulateDelay();
    final test = await getTestById(testId);
    return test?.testMaker == teacherId;
  }

  @override
  Future<bool> canEditTest(String testId, String teacherId) async {
    await _simulateDelay();
    final test = await getTestById(testId);
    if (test == null) return false;
    return test.testMaker == teacherId && !test.isPublished;
  }

  @override
  Future<bool> canDeleteTest(String testId, String teacherId) async {
    await _simulateDelay();
    final test = await getTestById(testId);
    if (test == null) return false;
    return test.testMaker == teacherId && !test.isPublished;
  }

  @override
  bool validateTest(Test test) {
    return test.isValid();
  }

  @override
  List<Question> randomizeQuestions(List<Question> questions) {
    final shuffled = List<Question>.from(questions);
    shuffled.shuffle();
    return shuffled;
  }

  @override
  Future<void> addMultipleQuestions(String testId, List<Question> questions) async {
    await _simulateDelay();
    for (final question in questions) {
      await addQuestion(testId, question);
    }
  }

  @override
  Future<Test> duplicateTest(String testId, {String? newName, String? newGroupId, DateTime? newDateTime}) async {
    await _simulateDelay();
    final originalTest = await getTestById(testId);
    if (originalTest == null) {
      throw Exception('Test not found');
    }
    
    final duplicatedTest = originalTest.copyWith(
      id: 'test_${_tests.length + 1}',
      name: newName ?? '${originalTest.name} (Copy)',
      groupId: newGroupId ?? originalTest.groupId,
      dateTime: newDateTime ?? originalTest.dateTime,
      createdAt: DateTime.now(),
    );
    
    _tests.add(duplicatedTest);
    return duplicatedTest;
  }

  @override
  Future<Map<String, dynamic>> getTestStatistics(String testId) async {
    await _simulateDelay();
    return {
      'totalQuestions': _questions.length,
      'averageScore': 0.0,
      'completionRate': 0.0,
    };
  }

  @override
  bool isTestAvailable(Test test) {
    return DateTime.now().isAfter(test.dateTime) && 
           DateTime.now().isBefore(test.dateTime.add(Duration(minutes: test.timeLimit)));
  }

  @override
  Stream<List<Test>> watchTestsByTeacher(String teacherId) {
    return Stream.value(_tests.where((test) => test.testMaker == teacherId).toList());
  }

  @override
  Stream<List<Question>> watchQuestions(String testId) {
    return Stream.value(List.from(_questions));
  }

  @override
  Stream<Test?> watchTest(String testId) {
    try {
      final test = _tests.firstWhere((test) => test.id == testId);
      return Stream.value(test);
    } catch (e) {
      return Stream.value(null);
    }
  }
}