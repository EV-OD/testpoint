import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:testpoint/features/teacher/widgets/test_basic_info_step.dart';
import 'package:testpoint/providers/test_provider.dart';
import 'package:testpoint/models/group_model.dart';

// Generate mocks
@GenerateMocks([TestProvider])
import 'test_basic_info_step_test.mocks.dart';

void main() {
  group('TestBasicInfoStep Widget Tests', () {
    late MockTestProvider mockTestProvider;

    setUp(() {
      mockTestProvider = MockTestProvider();
      
      // Setup default mock behavior
      when(mockTestProvider.formKey).thenReturn(GlobalKey<FormState>());
      when(mockTestProvider.nameController).thenReturn(TextEditingController());
      when(mockTestProvider.timeLimitController).thenReturn(TextEditingController(text: '60'));
      when(mockTestProvider.dateController).thenReturn(TextEditingController());
      when(mockTestProvider.timeController).thenReturn(TextEditingController());
      when(mockTestProvider.availableGroups).thenReturn([]);
      when(mockTestProvider.selectedGroupId).thenReturn(null);
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<TestProvider>.value(
            value: mockTestProvider,
            child: const TestBasicInfoStep(),
          ),
        ),
      );
    }

    testWidgets('should display all form fields', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Test Information'), findsOneWidget);
      expect(find.text('Enter the basic information for your test'), findsOneWidget);
      
      // Check for form fields
      expect(find.byType(TextFormField), findsNWidgets(4)); // Name, Time Limit, Date, Time
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget); // Group selection
      
      // Check field labels
      expect(find.text('Test Name *'), findsOneWidget);
      expect(find.text('Select Group *'), findsOneWidget);
      expect(find.text('Time Limit (minutes) *'), findsOneWidget);
      expect(find.text('Test Date *'), findsOneWidget);
      expect(find.text('Test Time *'), findsOneWidget);
    });

    testWidgets('should display available groups in dropdown', (WidgetTester tester) async {
      // Arrange
      final groups = [
        Group(
          id: 'group1',
          name: 'Grade 10A',
          userIds: ['user1', 'user2'],
          createdAt: DateTime.now(),
        ),
        Group(
          id: 'group2',
          name: 'Grade 11B',
          userIds: ['user3', 'user4', 'user5'],
          createdAt: DateTime.now(),
        ),
      ];
      when(mockTestProvider.availableGroups).thenReturn(groups);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Grade 10A'), findsOneWidget);
      expect(find.text('Grade 11B'), findsOneWidget);
      expect(find.text('2 members'), findsOneWidget);
      expect(find.text('3 members'), findsOneWidget);
    });

    testWidgets('should call selectGroup when group is selected', (WidgetTester tester) async {
      // Arrange
      final groups = [
        Group(
          id: 'group1',
          name: 'Grade 10A',
          userIds: ['user1', 'user2'],
          createdAt: DateTime.now(),
        ),
      ];
      when(mockTestProvider.availableGroups).thenReturn(groups);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Grade 10A'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockTestProvider.selectGroup('group1')).called(1);
    });

    testWidgets('should show date picker when date field is tapped', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.widgetWithText(TextFormField, 'Test Date *'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('should show time picker when time field is tapped', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.widgetWithText(TextFormField, 'Test Time *'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(TimePickerDialog), findsOneWidget);
    });

    testWidgets('should display instructions card', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Instructions'), findsOneWidget);
      expect(find.text('Choose a descriptive name for your test'), findsOneWidget);
      expect(find.text('Select the group of students who will take this test'), findsOneWidget);
      expect(find.text('Set an appropriate time limit (5-300 minutes)'), findsOneWidget);
      expect(find.text('Schedule the test for a future date and time'), findsOneWidget);
      expect(find.text('You can edit test details until it\'s published'), findsOneWidget);
    });

    group('Form Validation', () {
      testWidgets('should show error for empty test name', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        
        // Find the test name field and trigger validation
        final testNameField = find.widgetWithText(TextFormField, 'Test Name *');
        await tester.tap(testNameField);
        await tester.enterText(testNameField, '');
        await tester.pump();

        // Trigger validation by tapping away from the field
        await tester.tap(find.text('Instructions'));
        await tester.pump();

        // Assert - look for validation error message
        expect(find.text('Test name is required'), findsOneWidget);
      });

      testWidgets('should show error for short test name', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        
        // Find the test name field and enter short text
        final testNameField = find.widgetWithText(TextFormField, 'Test Name *');
        await tester.tap(testNameField);
        await tester.enterText(testNameField, 'AB'); // Too short
        await tester.pump();

        // Trigger validation by tapping away from the field
        await tester.tap(find.text('Instructions'));
        await tester.pump();

        // Assert - look for validation error message
        expect(find.text('Test name must be at least 3 characters'), findsOneWidget);
      });

      testWidgets('should show error for invalid time limit', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        
        // Find the time limit field and enter invalid value
        final timeLimitField = find.widgetWithText(TextFormField, 'Time Limit (minutes) *');
        await tester.tap(timeLimitField);
        await tester.enterText(timeLimitField, '3'); // Too short
        await tester.pump();

        // Trigger validation by tapping away from the field
        await tester.tap(find.text('Instructions'));
        await tester.pump();

        // Assert - look for validation error message
        expect(find.text('Time limit must be at least 5 minutes'), findsOneWidget);
      });

      testWidgets('should display form fields correctly', (WidgetTester tester) async {
        // Arrange
        final groups = [
          Group(
            id: 'group1',
            name: 'Grade 10A',
            userIds: ['user1', 'user2'],
            createdAt: DateTime.now(),
          ),
        ];
        when(mockTestProvider.availableGroups).thenReturn(groups);
        when(mockTestProvider.selectedGroupId).thenReturn('group1');

        // Act
        await tester.pumpWidget(createTestWidget());
        
        // Assert - check that all fields are present and functional
        expect(find.byType(TextFormField), findsNWidgets(4));
        expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
        
        // Test that we can enter text in the name field
        await tester.enterText(find.widgetWithText(TextFormField, 'Test Name *'), 'Valid Test Name');
        await tester.pump();
        expect(find.text('Valid Test Name'), findsOneWidget);
      });
    });
  });
}