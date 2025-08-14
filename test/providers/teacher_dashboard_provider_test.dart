import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:testpoint/providers/teacher_dashboard_provider.dart';
import 'package:testpoint/models/test_model.dart';
import '../mocks/mock_test_service.dart';
import '../mocks/mock_firebase_auth.dart';

void main() {
  group('TeacherDashboardProvider', () {
    late TeacherDashboardProvider provider;
    late MockTestService mockTestService;
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockTestService = MockTestService();
      mockAuth = MockFirebaseAuth();
      provider = TeacherDashboardProvider(
        testService: mockTestService,
        firebaseAuth: mockAuth,
      );
    });

    test('should filter tests by status correctly', () {
      // Arrange
      final tests = [
        Test(
          id: '1',
          name: 'Draft Test',
          groupId: 'group1',
          timeLimit: 60,
          questionCount: 5,
          dateTime: DateTime.now().add(const Duration(days: 1)),
          testMaker: 'teacher1',
          createdAt: DateTime.now(),
          status: TestStatus.draft,
        ),
        Test(
          id: '2',
          name: 'Published Test',
          groupId: 'group1',
          timeLimit: 45,
          questionCount: 10,
          dateTime: DateTime.now().add(const Duration(days: 2)),
          testMaker: 'teacher1',
          createdAt: DateTime.now(),
          status: TestStatus.published,
        ),
        Test(
          id: '3',
          name: 'Completed Test',
          groupId: 'group1',
          timeLimit: 30,
          questionCount: 8,
          dateTime: DateTime.now().subtract(const Duration(days: 1)),
          testMaker: 'teacher1',
          createdAt: DateTime.now(),
          status: TestStatus.completed,
        ),
      ];

      // Set the tests directly for testing
      provider.setTestsForTesting(tests);

      // Act & Assert
      expect(provider.draftTests.length, equals(1));
      expect(provider.draftTests.first.name, equals('Draft Test'));
      
      expect(provider.publishedTests.length, equals(1));
      expect(provider.publishedTests.first.name, equals('Published Test'));
      
      expect(provider.completedTests.length, equals(1));
      expect(provider.completedTests.first.name, equals('Completed Test'));
    });

    test('should return correct test statistics', () {
      // Arrange
      final tests = [
        Test(
          id: '1',
          name: 'Draft Test',
          groupId: 'group1',
          timeLimit: 60,
          questionCount: 5,
          dateTime: DateTime.now().add(const Duration(days: 1)),
          testMaker: 'teacher1',
          createdAt: DateTime.now(),
          status: TestStatus.draft,
        ),
        Test(
          id: '2',
          name: 'Published Test',
          groupId: 'group1',
          timeLimit: 45,
          questionCount: 10,
          dateTime: DateTime.now().add(const Duration(days: 2)),
          testMaker: 'teacher1',
          createdAt: DateTime.now(),
          status: TestStatus.published,
        ),
      ];

      provider.setTestsForTesting(tests);

      // Act
      final stats = provider.getTestStatistics();

      // Assert
      expect(stats['total'], equals(2));
      expect(stats['drafts'], equals(1));
      expect(stats['published'], equals(1));
      expect(stats['completed'], equals(0));
    });

    test('should validate test permissions correctly', () {
      // Arrange
      final draftTest = Test(
        id: '1',
        name: 'Draft Test',
        groupId: 'group1',
        timeLimit: 60,
        questionCount: 5,
        dateTime: DateTime.now().add(const Duration(days: 1)),
        testMaker: 'teacher1',
        createdAt: DateTime.now(),
        status: TestStatus.draft,
      );

      final publishedTest = Test(
        id: '2',
        name: 'Published Test',
        groupId: 'group1',
        timeLimit: 45,
        questionCount: 10,
        dateTime: DateTime.now().add(const Duration(days: 2)),
        testMaker: 'teacher1',
        createdAt: DateTime.now(),
        status: TestStatus.published,
      );

      final completedTest = Test(
        id: '3',
        name: 'Completed Test',
        groupId: 'group1',
        timeLimit: 30,
        questionCount: 8,
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
        testMaker: 'teacher1',
        createdAt: DateTime.now(),
        status: TestStatus.completed,
      );

      // Act & Assert
      expect(provider.canEditTest(draftTest), isTrue);
      expect(provider.canDeleteTest(draftTest), isTrue);
      expect(provider.canPublishTest(draftTest), isTrue);

      expect(provider.canEditTest(publishedTest), isTrue); // Can edit if not started
      expect(provider.canDeleteTest(publishedTest), isFalse);
      expect(provider.canPublishTest(publishedTest), isFalse);

      expect(provider.canEditTest(completedTest), isFalse);
      expect(provider.canDeleteTest(completedTest), isFalse);
      expect(provider.canPublishTest(completedTest), isFalse);
    });
  });
}