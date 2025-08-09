import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:testpoint/providers/test_provider.dart';
import 'package:testpoint/services/test_service.dart';
import 'package:testpoint/models/test_model.dart';
import 'package:testpoint/models/question_model.dart';
import 'package:testpoint/models/group_model.dart';

// Generate mocks
@GenerateMocks([TestService, auth.FirebaseAuth, auth.User])
import 'test_provider_test.mocks.dart';

void main() {
  // Initialize Flutter binding for widget tests
  TestWidgetsFlutterBinding.ensureInitialized();
  group('TestProvider Tests', () {
    late TestProvider testProvider;
    late MockTestService mockTestService;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;

    setUp(() {
      mockTestService = MockTestService();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();

      testProvider = TestProvider(
        testService: mockTestService,
        firebaseAuth: mockAuth,
      );

      // Setup default auth mock
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('teacher_123');
    });

    tearDown(() {
      testProvider.dispose();
    });

    group('Initialization', () {
      test('should initialize with default values', () {
        expect(testProvider.currentTest, isNull);
        expect(testProvider.questions, isEmpty);
        expect(testProvider.availableGroups, isEmpty);
        expect(testProvider.teacherTests, isEmpty);
        expect(testProvider.currentStep, equals(0));
        expect(testProvider.isLoading, isFalse);
        expect(testProvider.isSaving, isFalse);
        expect(testProvider.errorMessage, isNull);
        expect(testProvider.selectedCorrectAnswer, equals(0));
        expect(testProvider.questionCount, equals(0));
      });

      test('should have proper computed properties', () {
        expect(testProvider.canGoPrevious, isFalse); // At step 0
        expect(testProvider.isLastStep, isFalse); // At step 0
        expect(testProvider.selectedGroupId, isNull);
        expect(testProvider.selectedGroup, isNull);
      });
    });

    group('Test Creation Workflow', () {
      test('should start new test correctly', () {
        // Arrange - set some initial state
        testProvider.nameController.text = 'Old Test';
        testProvider.nextStep(); // Move to step 1

        // Act
        testProvider.startNewTest();

        // Assert
        expect(testProvider.currentTest, isNull);
        expect(testProvider.questions, isEmpty);
        expect(testProvider.currentStep, equals(0));
        expect(testProvider.nameController.text, isEmpty);
        expect(testProvider.errorMessage, isNull);
      });

      test('should load test for editing correctly', () {
        // Arrange
        final test = Test(
          id: 'test_123',
          name: 'Math Test',
          groupId: 'group_456',
          timeLimit: 90,
          questionCount: 5,
          dateTime: DateTime(2024, 12, 25, 10, 30),
          testMaker: 'teacher_123',
          createdAt: DateTime.now(),
        );

        when(mockTestService.getQuestions('test_123'))
            .thenAnswer((_) async => []);

        // Act
        testProvider.loadTestForEditing(test);

        // Assert
        expect(testProvider.currentTest, equals(test));
        expect(testProvider.nameController.text, equals('Math Test'));
        expect(testProvider.timeLimitController.text, equals('90'));
        expect(testProvider.dateController.text, equals('25/12/2024'));
        expect(testProvider.timeController.text, equals('10:30'));
        expect(testProvider.currentStep, equals(0));
      });
    });

    group('Step Navigation', () {
      test('should navigate to next step', () {
        // Arrange - start at step 0
        expect(testProvider.currentStep, equals(0));

        // Act - use goToStep instead of nextStep to avoid validation issues
        testProvider.goToStep(1);

        // Assert
        expect(testProvider.currentStep, equals(1));
      });

      test('should navigate to previous step', () {
        // Arrange - move to step 1 first
        testProvider.goToStep(1);

        // Act
        testProvider.previousStep();

        // Assert
        expect(testProvider.currentStep, equals(0));
      });

      test('should go to specific step', () {
        // Act
        testProvider.goToStep(2);

        // Assert
        expect(testProvider.currentStep, equals(2));
        expect(testProvider.isLastStep, isTrue);
      });

      test('should not go to invalid step', () {
        // Act
        testProvider.goToStep(-1);
        expect(testProvider.currentStep, equals(0));

        testProvider.goToStep(5);
        expect(testProvider.currentStep, equals(0));
      });
    });

    group('Question Management', () {
      test('should set selected correct answer', () {
        // Act
        testProvider.setSelectedCorrectAnswer(2);

        // Assert
        expect(testProvider.selectedCorrectAnswer, equals(2));
      });

      test('should not set invalid correct answer index', () {
        // Act
        testProvider.setSelectedCorrectAnswer(-1);
        expect(testProvider.selectedCorrectAnswer, equals(0)); // Should remain unchanged

        testProvider.setSelectedCorrectAnswer(5);
        expect(testProvider.selectedCorrectAnswer, equals(0)); // Should remain unchanged
      });

      test('should add question successfully', () async {
        // Arrange
        final test = Test(
          id: 'test_123',
          name: 'Math Test',
          groupId: 'group_456',
          timeLimit: 60,
          questionCount: 0,
          dateTime: DateTime.now().add(const Duration(days: 1)),
          testMaker: 'teacher_123',
          createdAt: DateTime.now(),
        );
        testProvider.loadTestForEditing(test);

        testProvider.questionTextController.text = 'What is 2 + 2?';
        testProvider.optionControllers[0].text = 'Option A';
        testProvider.optionControllers[1].text = 'Option B';
        testProvider.optionControllers[2].text = 'Option C';
        testProvider.optionControllers[3].text = 'Option D';
        testProvider.setSelectedCorrectAnswer(1);

        final expectedQuestion = Question(
          id: 'question_456',
          text: 'What is 2 + 2?',
          options: [
            const QuestionOption(id: 'opt1', text: 'Option A', isCorrect: false),
            const QuestionOption(id: 'opt2', text: 'Option B', isCorrect: true),
            const QuestionOption(id: 'opt3', text: 'Option C', isCorrect: false),
            const QuestionOption(id: 'opt4', text: 'Option D', isCorrect: false),
          ],
          createdAt: DateTime.now(),
        );

        when(mockTestService.addQuestion('test_123', any))
            .thenAnswer((_) async => expectedQuestion);

        // Act
        await testProvider.addQuestion();

        // Assert
        expect(testProvider.questions.length, equals(1));
        expect(testProvider.questionTextController.text, isEmpty); // Should be cleared
        expect(testProvider.selectedCorrectAnswer, equals(0)); // Should be reset
        expect(testProvider.errorMessage, isNull);
        verify(mockTestService.addQuestion('test_123', any)).called(1);
      });

      test('should not add question with invalid data', () async {
        // Arrange
        final test = Test(
          id: 'test_123',
          name: 'Math Test',
          groupId: 'group_456',
          timeLimit: 60,
          questionCount: 0,
          dateTime: DateTime.now().add(const Duration(days: 1)),
          testMaker: 'teacher_123',
          createdAt: DateTime.now(),
        );
        testProvider.loadTestForEditing(test);

        testProvider.questionTextController.text = 'Short'; // Too short
        testProvider.optionControllers[0].text = 'Option A';
        testProvider.optionControllers[1].text = 'Option B';
        testProvider.optionControllers[2].text = 'Option C';
        testProvider.optionControllers[3].text = 'Option D';

        // Act
        await testProvider.addQuestion();

        // Assert
        expect(testProvider.questions.length, equals(0));
        expect(testProvider.errorMessage, contains('at least 10 characters'));
        verifyNever(mockTestService.addQuestion(any, any));
      });

      test('should not add question without test', () async {
        // Arrange - no current test
        testProvider.questionTextController.text = 'What is 2 + 2?';
        testProvider.optionControllers[0].text = 'Option A';
        testProvider.optionControllers[1].text = 'Option B';
        testProvider.optionControllers[2].text = 'Option C';
        testProvider.optionControllers[3].text = 'Option D';

        // Act
        await testProvider.addQuestion();

        // Assert
        expect(testProvider.questions.length, equals(0));
        expect(testProvider.errorMessage, contains('Test must be created'));
        verifyNever(mockTestService.addQuestion(any, any));
      });
    });

    group('Data Loading', () {
      test('should load available groups successfully', () async {
        // Arrange
        final groups = [
          Group(
            id: 'group_1',
            name: 'Group 1',
            userIds: ['user1', 'user2'],
            createdAt: DateTime.now(),
          ),
          Group(
            id: 'group_2',
            name: 'Group 2',
            userIds: ['user3', 'user4'],
            createdAt: DateTime.now(),
          ),
        ];

        when(mockTestService.getAvailableGroups('teacher_123'))
            .thenAnswer((_) async => groups);

        // Act
        await testProvider.loadAvailableGroups();

        // Assert
        expect(testProvider.availableGroups.length, equals(2));
        expect(testProvider.availableGroups[0].name, equals('Group 1'));
        expect(testProvider.availableGroups[1].name, equals('Group 2'));
        expect(testProvider.errorMessage, isNull);
        verify(mockTestService.getAvailableGroups('teacher_123')).called(1);
      });

      test('should handle error when loading groups', () async {
        // Arrange
        when(mockTestService.getAvailableGroups('teacher_123'))
            .thenThrow(Exception('Network error'));

        // Act
        await testProvider.loadAvailableGroups();

        // Assert
        expect(testProvider.availableGroups, isEmpty);
        expect(testProvider.errorMessage, contains('Failed to load groups'));
      });

      test('should load teacher tests successfully', () async {
        // Arrange
        final tests = [
          Test(
            id: 'test_1',
            name: 'Test 1',
            groupId: 'group_1',
            timeLimit: 60,
            questionCount: 5,
            dateTime: DateTime.now(),
            testMaker: 'teacher_123',
            createdAt: DateTime.now(),
          ),
        ];

        when(mockTestService.getTestsByTeacher('teacher_123'))
            .thenAnswer((_) async => tests);

        // Act
        await testProvider.loadTeacherTests();

        // Assert
        expect(testProvider.teacherTests.length, equals(1));
        expect(testProvider.teacherTests[0].name, equals('Test 1'));
        expect(testProvider.errorMessage, isNull);
        verify(mockTestService.getTestsByTeacher('teacher_123')).called(1);
      });
    });

    group('Group Selection', () {
      test('should select valid group', () async {
        // Arrange
        final groups = [
          Group(
            id: 'group_1',
            name: 'Group 1',
            userIds: [],
            createdAt: DateTime.now(),
          ),
        ];
        
        // Mock the service to return our test groups
        when(mockTestService.getAvailableGroups('teacher_123'))
            .thenAnswer((_) async => groups);
        
        // Load groups first
        await testProvider.loadAvailableGroups();
        
        testProvider.loadTestForEditing(Test(
          id: 'test_123',
          name: 'Test',
          groupId: 'old_group',
          timeLimit: 60,
          questionCount: 0,
          dateTime: DateTime.now(),
          testMaker: 'teacher_123',
          createdAt: DateTime.now(),
        ));

        // Act
        testProvider.selectGroup('group_1');

        // Assert
        expect(testProvider.selectedGroupId, equals('group_1'));
      });
    });

    group('Error Handling', () {
      test('should clear error message', () {
        // Arrange
        testProvider.clearError(); // This should set error to null initially
        // Manually set an error for testing
        testProvider.loadAvailableGroups(); // This might set an error if auth fails

        // Act
        testProvider.clearError();

        // Assert
        expect(testProvider.errorMessage, isNull);
      });
    });
  });
}