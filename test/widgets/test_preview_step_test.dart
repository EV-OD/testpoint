import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:testpoint/features/teacher/widgets/test_preview_step.dart';
import 'package:testpoint/providers/test_provider.dart';
import 'package:testpoint/models/test_model.dart';
import 'package:testpoint/models/question_model.dart';
import 'package:testpoint/models/group_model.dart';
import 'package:testpoint/services/test_service.dart';

// Generate mocks
@GenerateMocks([TestService, auth.FirebaseAuth, auth.User, TestProvider])
import 'test_preview_step_test.mocks.dart';

void main() {
  group('TestPreviewStep Widget Tests', () {
    late MockTestProvider mockTestProvider;

    setUp(() {
      mockTestProvider = MockTestProvider();
      
      // Set up default mock behavior
      when(mockTestProvider.currentTest).thenReturn(null);
      when(mockTestProvider.questions).thenReturn([]);
      when(mockTestProvider.availableGroups).thenReturn([]);
      when(mockTestProvider.selectedGroup).thenReturn(null);
      when(mockTestProvider.isSaving).thenReturn(false);
      when(mockTestProvider.currentStep).thenReturn(2);
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<TestProvider>.value(
            value: mockTestProvider,
            child: const TestPreviewStep(),
          ),
        ),
      );
    }

    testWidgets('displays no test data message when currentTest is null', (tester) async {
      // currentTest is already null from setUp
      await tester.pumpWidget(createTestWidget());

      expect(find.text('No test data available'), findsOneWidget);
    });

    testWidgets('displays no questions message when questions list is empty', (tester) async {
      // Set up test with no questions
      final test = Test(
        id: 'test1',
        name: 'Sample Test',
        groupId: 'group1',
        timeLimit: 60,
        questionCount: 0,
        dateTime: DateTime.now().add(const Duration(days: 1)),
        testMaker: 'teacher_123',
        createdAt: DateTime.now(),
      );

      when(mockTestProvider.currentTest).thenReturn(test);
      when(mockTestProvider.questions).thenReturn([]); // Empty questions list

      await tester.pumpWidget(createTestWidget());

      expect(find.text('No questions added yet'), findsOneWidget);
      expect(find.text('Add questions in the previous step to preview your test'), findsOneWidget);
      expect(find.byIcon(Icons.quiz_outlined), findsOneWidget);
    });

    testWidgets('displays test summary with correct information', (tester) async {
      // Set up test with basic info
      final test = Test(
        id: 'test1',
        name: 'Math Final Exam',
        groupId: 'group1',
        timeLimit: 90,
        questionCount: 2,
        dateTime: DateTime(2024, 12, 15, 10, 30),
        testMaker: 'teacher_123',
        createdAt: DateTime.now(),
      );

      final group = Group(
        id: 'group1',
        name: 'Grade 10 Math',
        userIds: ['student1', 'student2'],
        createdAt: DateTime.now(),
      );

      // Set up questions
      final questions = [
        Question(
          id: 'q1',
          text: 'What is 2 + 2?',
          options: [
            const QuestionOption(id: 'opt1', text: '3', isCorrect: false),
            const QuestionOption(id: 'opt2', text: '4', isCorrect: true),
            const QuestionOption(id: 'opt3', text: '5', isCorrect: false),
            const QuestionOption(id: 'opt4', text: '6', isCorrect: false),
          ],
          createdAt: DateTime.now(),
        ),
        Question(
          id: 'q2',
          text: 'What is 3 × 3?',
          options: [
            const QuestionOption(id: 'opt1', text: '6', isCorrect: false),
            const QuestionOption(id: 'opt2', text: '9', isCorrect: true),
            const QuestionOption(id: 'opt3', text: '12', isCorrect: false),
            const QuestionOption(id: 'opt4', text: '15', isCorrect: false),
          ],
          createdAt: DateTime.now(),
        ),
      ];

      when(mockTestProvider.currentTest).thenReturn(test);
      when(mockTestProvider.questions).thenReturn(questions);
      when(mockTestProvider.availableGroups).thenReturn([group]);
      when(mockTestProvider.selectedGroup).thenReturn(group);

      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Allow for async operations

      // Verify test summary is displayed
      expect(find.text('Test Summary'), findsOneWidget);
      expect(find.text('Math Final Exam'), findsOneWidget);
      expect(find.text('90 minutes'), findsOneWidget);
      expect(find.text('2 questions'), findsOneWidget);
      expect(find.text('15 Dec 2024 at 10:30'), findsOneWidget);
    });

    testWidgets('displays preview controls with shuffle button', (tester) async {
      // Set up test with questions
      final test = Test(
        id: 'test1',
        name: 'Test',
        groupId: 'group1',
        timeLimit: 60,
        questionCount: 1,
        dateTime: DateTime.now().add(const Duration(days: 1)),
        testMaker: 'teacher_123',
        createdAt: DateTime.now(),
      );

      final question = Question(
        id: 'q1',
        text: 'Question 1',
        options: [
          const QuestionOption(id: 'opt1', text: 'A', isCorrect: true),
          const QuestionOption(id: 'opt2', text: 'B', isCorrect: false),
          const QuestionOption(id: 'opt3', text: 'C', isCorrect: false),
          const QuestionOption(id: 'opt4', text: 'D', isCorrect: false),
        ],
        createdAt: DateTime.now(),
      );

      when(mockTestProvider.currentTest).thenReturn(test);
      when(mockTestProvider.questions).thenReturn([question]);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify preview controls
      expect(find.text('Preview shows questions in randomized order as students will see them'), findsOneWidget);
      expect(find.text('Shuffle'), findsOneWidget);
      expect(find.byIcon(Icons.shuffle), findsOneWidget);
    });

    testWidgets('displays action buttons for edit and publish when test has questions', (tester) async {
      // Set up test with questions
      final test = Test(
        id: 'test1',
        name: 'Test',
        groupId: 'group1',
        timeLimit: 60,
        questionCount: 1,
        dateTime: DateTime.now().add(const Duration(days: 1)),
        testMaker: 'teacher_123',
        createdAt: DateTime.now(),
      );

      final question = Question(
        id: 'q1',
        text: 'Sample question',
        options: [
          const QuestionOption(id: 'opt1', text: 'Option A', isCorrect: true),
          const QuestionOption(id: 'opt2', text: 'Option B', isCorrect: false),
          const QuestionOption(id: 'opt3', text: 'Option C', isCorrect: false),
          const QuestionOption(id: 'opt4', text: 'Option D', isCorrect: false),
        ],
        createdAt: DateTime.now(),
      );

      when(mockTestProvider.currentTest).thenReturn(test);
      when(mockTestProvider.questions).thenReturn([question]);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify action buttons
      expect(find.text('Edit Questions'), findsOneWidget);
      expect(find.text('Publish Test'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.publish), findsOneWidget);
    });

    testWidgets('displays questions in preview format with correct answer highlighting', (tester) async {
      // Set up test with a question
      final test = Test(
        id: 'test1',
        name: 'Test',
        groupId: 'group1',
        timeLimit: 60,
        questionCount: 1,
        dateTime: DateTime.now().add(const Duration(days: 1)),
        testMaker: 'teacher_123',
        createdAt: DateTime.now(),
      );

      final question = Question(
        id: 'q1',
        text: 'What is the capital of France?',
        options: [
          const QuestionOption(id: 'opt1', text: 'London', isCorrect: false),
          const QuestionOption(id: 'opt2', text: 'Paris', isCorrect: true),
          const QuestionOption(id: 'opt3', text: 'Berlin', isCorrect: false),
          const QuestionOption(id: 'opt4', text: 'Madrid', isCorrect: false),
        ],
        createdAt: DateTime.now(),
      );

      when(mockTestProvider.currentTest).thenReturn(test);
      when(mockTestProvider.questions).thenReturn([question]);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify question preview
      expect(find.text('Test Questions Preview'), findsOneWidget);
      expect(find.text('What is the capital of France?'), findsOneWidget);
      expect(find.text('Q1'), findsOneWidget);
      
      // Verify all options are displayed
      expect(find.text('London'), findsOneWidget);
      expect(find.text('Paris'), findsOneWidget);
      expect(find.text('Berlin'), findsOneWidget);
      expect(find.text('Madrid'), findsOneWidget);
      
      // Verify option letters
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);
      
      // Verify correct answer highlighting (check icon should be present)
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}