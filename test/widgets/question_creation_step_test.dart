import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:testpoint/features/teacher/widgets/question_creation_step.dart';
import 'package:testpoint/providers/test_provider.dart';
import 'package:testpoint/models/question_model.dart';
import 'package:testpoint/models/test_model.dart';

import '../mocks/mock_test_service.dart';
import '../mocks/mock_firebase_auth.dart';

void main() {
  group('QuestionCreationStep Core Functionality Tests', () {
    late TestProvider testProvider;
    late MockTestService mockTestService;
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockTestService = MockTestService();
      mockAuth = MockFirebaseAuth();
      testProvider = TestProvider(
        testService: mockTestService,
        firebaseAuth: mockAuth,
      );
    });

    tearDown(() {
      testProvider.dispose();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 1000,
            width: 1400,
            child: ChangeNotifierProvider<TestProvider>.value(
              value: testProvider,
              child: const QuestionCreationStep(),
            ),
          ),
        ),
      );
    }

    testWidgets('displays all required form elements', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check header elements
      expect(find.text('Create Questions'), findsOneWidget);
      expect(find.text('Questions added: 0'), findsOneWidget);
      expect(find.byIcon(Icons.quiz), findsOneWidget);

      // Check form title
      expect(find.text('Add New Question'), findsOneWidget);

      // Check all form fields are present
      expect(find.byType(TextFormField), findsNWidgets(5)); // 1 question + 4 options
      
      // Check specific field labels
      expect(find.text('Question Text *'), findsOneWidget);
      expect(find.text('Option 1 *'), findsOneWidget);
      expect(find.text('Option 2 *'), findsOneWidget);
      expect(find.text('Option 3 *'), findsOneWidget);
      expect(find.text('Option 4 *'), findsOneWidget);

      // Check radio buttons for correct answer selection
      expect(find.byType(Radio<int>), findsNWidgets(4));

      // Check add question button
      expect(find.text('Add Question'), findsOneWidget);

      // Check questions list section
      expect(find.text('Questions'), findsOneWidget);
      expect(find.text('No questions added yet'), findsOneWidget);
    });

    testWidgets('shows correct answer selection with radio buttons', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initially, first option should be selected (index 0)
      expect(testProvider.selectedCorrectAnswer, equals(0));

      // Find and tap second radio button
      final radioButtons = find.byType(Radio<int>);
      expect(radioButtons, findsNWidgets(4));

      // Tap second radio button (index 1)
      await tester.tap(radioButtons.at(1));
      await tester.pumpAndSettle();
      expect(testProvider.selectedCorrectAnswer, equals(1));

      // Tap third radio button (index 2)
      await tester.tap(radioButtons.at(2));
      await tester.pumpAndSettle();
      expect(testProvider.selectedCorrectAnswer, equals(2));
    });

    testWidgets('displays question counter correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initially should show 0 questions
      expect(find.text('Questions added: 0'), findsOneWidget);

      // Add a mock question to the provider
      final mockQuestion = Question(
        id: 'q1',
        text: 'What is 2 + 2?',
        options: [
          const QuestionOption(id: 'opt1', text: '3', isCorrect: false),
          const QuestionOption(id: 'opt2', text: '4', isCorrect: true),
          const QuestionOption(id: 'opt3', text: '5', isCorrect: false),
          const QuestionOption(id: 'opt4', text: '6', isCorrect: false),
        ],
        createdAt: DateTime.now(),
      );

      // Simulate adding a question through the provider
      mockTestService.setMockQuestions([mockQuestion]);
      testProvider.loadTestForEditing(Test(
        id: 'test123',
        name: 'Test Name',
        groupId: 'group123',
        timeLimit: 60,
        questionCount: 1,
        dateTime: DateTime.now().add(const Duration(days: 1)),
        testMaker: 'teacher123',
        createdAt: DateTime.now(),
      ));

      await tester.pumpAndSettle();

      // Should now show 1 question
      expect(find.text('Questions added: 1'), findsOneWidget);
    });

    testWidgets('displays questions list when questions exist', (tester) async {
      // Set up mock test with questions
      final mockQuestions = [
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
          text: 'What is the capital of France?',
          options: [
            const QuestionOption(id: 'opt1', text: 'London', isCorrect: false),
            const QuestionOption(id: 'opt2', text: 'Paris', isCorrect: true),
            const QuestionOption(id: 'opt3', text: 'Berlin', isCorrect: false),
            const QuestionOption(id: 'opt4', text: 'Madrid', isCorrect: false),
          ],
          createdAt: DateTime.now(),
        ),
      ];

      mockTestService.setMockQuestions(mockQuestions);
      testProvider.loadTestForEditing(Test(
        id: 'test123',
        name: 'Test Name',
        groupId: 'group123',
        timeLimit: 60,
        questionCount: 2,
        dateTime: DateTime.now().add(const Duration(days: 1)),
        testMaker: 'teacher123',
        createdAt: DateTime.now(),
      ));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify questions list display
      expect(find.text('Questions added: 2'), findsOneWidget);
      expect(find.text('Q1'), findsOneWidget);
      expect(find.text('Q2'), findsOneWidget);
      expect(find.text('What is 2 + 2?'), findsOneWidget);
      expect(find.text('What is the capital of France?'), findsOneWidget);
      
      // Verify correct answers are shown
      expect(find.text('4'), findsOneWidget); // Correct answer for Q1
      expect(find.text('Paris'), findsOneWidget); // Correct answer for Q2

      // Verify delete buttons are present
      expect(find.byIcon(Icons.delete_outline), findsNWidgets(2));

      // Should not show empty state
      expect(find.text('No questions added yet'), findsNothing);
    });

    testWidgets('shows validation hints and character limits', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check question text field helper text
      expect(find.text('Minimum 10 characters, maximum 500 characters'), findsOneWidget);

      // Check that character counter is shown for question field
      expect(find.text('0/500'), findsOneWidget);
    });

    testWidgets('handles form validation correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Test question text validation
      final questionField = find.widgetWithText(TextFormField, 'Question Text *');
      
      // Enter text that's too short
      await tester.enterText(questionField, 'Short');
      await tester.pumpAndSettle();
      
      // Manually trigger validation
      final formState = tester.state<FormState>(find.byType(Form));
      final isValid = formState.validate();
      expect(isValid, isFalse);

      // Enter valid text
      await tester.enterText(questionField, 'This is a valid question with enough characters?');
      await tester.pumpAndSettle();
      
      // Fill in all option fields
      await tester.enterText(find.widgetWithText(TextFormField, 'Option 1 *'), 'Option A');
      await tester.enterText(find.widgetWithText(TextFormField, 'Option 2 *'), 'Option B');
      await tester.enterText(find.widgetWithText(TextFormField, 'Option 3 *'), 'Option C');
      await tester.enterText(find.widgetWithText(TextFormField, 'Option 4 *'), 'Option D');
      await tester.pumpAndSettle();

      // Now validation should pass
      final isValidNow = formState.validate();
      expect(isValidNow, isTrue);
    });

    testWidgets('detects duplicate options correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Fill in question text
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Question Text *'),
        'What is 2 + 2?',
      );

      // Fill in options with duplicates
      await tester.enterText(find.widgetWithText(TextFormField, 'Option 1 *'), 'Same Answer');
      await tester.enterText(find.widgetWithText(TextFormField, 'Option 2 *'), 'Different Answer');
      await tester.enterText(find.widgetWithText(TextFormField, 'Option 3 *'), 'Another Answer');
      await tester.enterText(find.widgetWithText(TextFormField, 'Option 4 *'), 'Same Answer'); // Duplicate
      
      await tester.pumpAndSettle();

      // Manually trigger validation
      final formState = tester.state<FormState>(find.byType(Form));
      final isValid = formState.validate();
      expect(isValid, isFalse); // Should fail due to duplicate options
    });

    testWidgets('shows correct answer indicator', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Select third option as correct
      final radioButtons = find.byType(Radio<int>);
      await tester.tap(radioButtons.at(2)); // Select index 2 (Option 3)
      await tester.pumpAndSettle();

      // Verify the check icon appears for the selected option
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}