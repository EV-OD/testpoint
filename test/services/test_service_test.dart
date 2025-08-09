import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:testpoint/services/test_service.dart';
import 'package:testpoint/repositories/test_repository.dart';
import 'package:testpoint/services/group_service.dart';
import 'package:testpoint/models/test_model.dart';
import 'package:testpoint/models/question_model.dart';
import 'package:testpoint/models/group_model.dart';

// Generate mocks
@GenerateMocks([TestRepository, GroupService, auth.FirebaseAuth, auth.User])
import 'test_service_test.mocks.dart';

void main() {
  group('TestService Tests', () {
    late TestService testService;
    late MockTestRepository mockTestRepository;
    late MockGroupService mockGroupService;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;

    setUp(() {
      mockTestRepository = MockTestRepository();
      mockGroupService = MockGroupService();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();

      testService = TestService(
        testRepository: mockTestRepository,
        groupService: mockGroupService,
        firebaseAuth: mockAuth,
      );

      // Setup default auth mock
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('teacher_123');
    });

    group('createTest', () {
      test('should create test successfully with valid data', () async {
        // Arrange
        final test = Test(
          id: '',
          name: 'Math Test',
          groupId: 'group_123',
          timeLimit: 60,
          questionCount: 0,
          dateTime: DateTime.now().add(const Duration(days: 1)),
          testMaker: 'teacher_123', // Valid test maker
          createdAt: DateTime.now(),
        );

        when(mockTestRepository.createTest(any))
            .thenAnswer((_) async => 'test_456');

        // Act
        final result = await testService.createTest(test);

        // Assert
        expect(result.id, equals('test_456'));
        expect(result.testMaker, equals('teacher_123'));
        verify(mockTestRepository.createTest(any)).called(1);
      });

      test('should throw exception when user is not authenticated', () async {
        // Arrange
        when(mockAuth.currentUser).thenReturn(null);
        
        final test = Test(
          id: '',
          name: 'Math Test',
          groupId: 'group_123',
          timeLimit: 60,
          questionCount: 0,
          dateTime: DateTime.now().add(const Duration(days: 1)),
          testMaker: '',
          createdAt: DateTime.now(),
        );

        // Act & Assert
        expect(
          () => testService.createTest(test),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('User must be authenticated'),
          )),
        );
      });

      test('should throw exception with invalid test data', () async {
        // Arrange
        final invalidTest = Test(
          id: '',
          name: '', // Invalid: empty name
          groupId: 'group_123',
          timeLimit: 60,
          questionCount: 0,
          dateTime: DateTime.now().add(const Duration(days: 1)),
          testMaker: '',
          createdAt: DateTime.now(),
        );

        // Act & Assert
        expect(
          () => testService.createTest(invalidTest),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid test data'),
          )),
        );
      });
    });

    group('updateTest', () {
      test('should update test successfully when user owns it', () async {
        // Arrange
        final test = Test(
          id: 'test_123',
          name: 'Updated Math Test',
          groupId: 'group_123',
          timeLimit: 90,
          questionCount: 5,
          dateTime: DateTime.now().add(const Duration(days: 1)),
          testMaker: 'teacher_123',
          createdAt: DateTime.now(),
        );

        when(mockTestRepository.validateTestOwnership('test_123', 'teacher_123'))
            .thenAnswer((_) async => true);
        when(mockTestRepository.canEditTest('test_123', 'teacher_123'))
            .thenAnswer((_) async => true);
        when(mockTestRepository.updateTest(test))
            .thenAnswer((_) async => {});

        // Act
        final result = await testService.updateTest(test);

        // Assert
        expect(result, equals(test));
        verify(mockTestRepository.updateTest(test)).called(1);
      });

      test('should throw exception when user does not own test', () async {
        // Arrange
        final test = Test(
          id: 'test_123',
          name: 'Updated Math Test',
          groupId: 'group_123',
          timeLimit: 90,
          questionCount: 5,
          dateTime: DateTime.now().add(const Duration(days: 1)),
          testMaker: 'other_teacher',
          createdAt: DateTime.now(),
        );

        when(mockTestRepository.validateTestOwnership('test_123', 'teacher_123'))
            .thenAnswer((_) async => false);

        // Act & Assert
        expect(
          () => testService.updateTest(test),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('does not have permission'),
          )),
        );
      });
    });

    group('addQuestion', () {
      test('should add question successfully to owned test', () async {
        // Arrange
        final question = Question(
          id: '',
          text: 'What is 2 + 2?',
          options: [
            const QuestionOption(id: 'opt1', text: '3', isCorrect: false),
            const QuestionOption(id: 'opt2', text: '4', isCorrect: true),
            const QuestionOption(id: 'opt3', text: '5', isCorrect: false),
            const QuestionOption(id: 'opt4', text: '6', isCorrect: false),
          ],
          createdAt: DateTime.now(),
        );

        when(mockTestRepository.validateTestOwnership('test_123', 'teacher_123'))
            .thenAnswer((_) async => true);
        when(mockTestRepository.canEditTest('test_123', 'teacher_123'))
            .thenAnswer((_) async => true);
        when(mockTestRepository.addQuestion('test_123', question))
            .thenAnswer((_) async => 'question_456');

        // Act
        final result = await testService.addQuestion('test_123', question);

        // Assert
        expect(result.id, equals('question_456'));
        verify(mockTestRepository.addQuestion('test_123', question)).called(1);
      });

      test('should throw exception when adding invalid question', () async {
        // Arrange
        final invalidQuestion = Question(
          id: '',
          text: 'Short', // Too short
          options: [], // No options
          createdAt: DateTime.now(),
        );

        when(mockTestRepository.validateTestOwnership('test_123', 'teacher_123'))
            .thenAnswer((_) async => true);
        when(mockTestRepository.canEditTest('test_123', 'teacher_123'))
            .thenAnswer((_) async => true);

        // Act & Assert
        expect(
          () => testService.addQuestion('test_123', invalidQuestion),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid question data'),
          )),
        );
      });
    });

    group('validateTest', () {
      test('should return true for valid test', () {
        // Arrange
        final validTest = Test(
          id: 'test_123',
          name: 'Math Test',
          groupId: 'group_123',
          timeLimit: 60,
          questionCount: 5,
          dateTime: DateTime.now().add(const Duration(days: 1)),
          testMaker: 'teacher_123',
          createdAt: DateTime.now(),
        );

        // Act
        final result = testService.validateTest(validTest);

        // Assert
        expect(result, isTrue);
      });

      test('should return false for invalid test', () {
        // Arrange
        final invalidTest = Test(
          id: 'test_123',
          name: '', // Invalid: empty name
          groupId: 'group_123',
          timeLimit: 60,
          questionCount: 5,
          dateTime: DateTime.now().add(const Duration(days: 1)),
          testMaker: 'teacher_123',
          createdAt: DateTime.now(),
        );

        // Act
        final result = testService.validateTest(invalidTest);

        // Assert
        expect(result, isFalse);
      });
    });

    group('randomizeQuestions', () {
      test('should return shuffled list of questions', () {
        // Arrange
        final questions = [
          Question(
            id: 'q1',
            text: 'Question 1',
            options: [],
            createdAt: DateTime.now(),
          ),
          Question(
            id: 'q2',
            text: 'Question 2',
            options: [],
            createdAt: DateTime.now(),
          ),
          Question(
            id: 'q3',
            text: 'Question 3',
            options: [],
            createdAt: DateTime.now(),
          ),
        ];

        // Act
        final result = testService.randomizeQuestions(questions);

        // Assert
        expect(result.length, equals(questions.length));
        expect(result.toSet(), equals(questions.toSet())); // Same elements
        // Note: We can't test the actual randomization reliably in unit tests
      });
    });

    group('isTestAvailable', () {
      test('should return true when test is currently available', () {
        // Arrange
        final availableTest = Test(
          id: 'test_123',
          name: 'Math Test',
          groupId: 'group_123',
          timeLimit: 60,
          questionCount: 5,
          dateTime: DateTime.now().subtract(const Duration(minutes: 30)), // Started 30 min ago
          testMaker: 'teacher_123',
          createdAt: DateTime.now(),
        );

        // Act
        final result = testService.isTestAvailable(availableTest);

        // Assert
        expect(result, isTrue);
      });

      test('should return false when test has not started yet', () {
        // Arrange
        final futureTest = Test(
          id: 'test_123',
          name: 'Math Test',
          groupId: 'group_123',
          timeLimit: 60,
          questionCount: 5,
          dateTime: DateTime.now().add(const Duration(hours: 1)), // Starts in 1 hour
          testMaker: 'teacher_123',
          createdAt: DateTime.now(),
        );

        // Act
        final result = testService.isTestAvailable(futureTest);

        // Assert
        expect(result, isFalse);
      });

      test('should return false when test has expired', () {
        // Arrange
        final expiredTest = Test(
          id: 'test_123',
          name: 'Math Test',
          groupId: 'group_123',
          timeLimit: 60,
          questionCount: 5,
          dateTime: DateTime.now().subtract(const Duration(hours: 2)), // Started 2 hours ago
          testMaker: 'teacher_123',
          createdAt: DateTime.now(),
        );

        // Act
        final result = testService.isTestAvailable(expiredTest);

        // Assert
        expect(result, isFalse);
      });
    });
  });
}