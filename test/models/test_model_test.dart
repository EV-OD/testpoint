import 'package:flutter_test/flutter_test.dart';
import 'package:testpoint/models/test_model.dart';
import 'package:testpoint/models/question_model.dart';
import 'package:testpoint/models/group_model.dart';
import 'package:testpoint/models/user_model.dart';

void main() {
  group('Test Model Tests', () {
    late Test validTest;
    late DateTime testDateTime;
    late DateTime createdAt;

    setUp(() {
      testDateTime = DateTime.now().add(const Duration(days: 1));
      createdAt = DateTime.now();
      validTest = Test(
        id: 'test_123',
        name: 'Mathematics Test',
        groupId: 'group_456',
        timeLimit: 60,
        questionCount: 10,
        dateTime: testDateTime,
        testMaker: 'teacher_789',
        createdAt: createdAt,
      );
    });

    test('should create a valid test instance', () {
      expect(validTest.id, equals('test_123'));
      expect(validTest.name, equals('Mathematics Test'));
      expect(validTest.groupId, equals('group_456'));
      expect(validTest.timeLimit, equals(60));
      expect(validTest.questionCount, equals(10));
      expect(validTest.testMaker, equals('teacher_789'));
    });

    test('should validate correctly for valid test', () {
      expect(validTest.isValid(), isTrue);
      expect(validTest.getValidationErrors(), isEmpty);
    });

    test('should fail validation for invalid test', () {
      final invalidTest = Test(
        id: 'test_123',
        name: '', // Empty name
        groupId: '', // Empty group ID
        timeLimit: 3, // Too short
        questionCount: 0,
        dateTime: DateTime.now().subtract(const Duration(days: 1)), // Past date
        testMaker: '', // Empty test maker
        createdAt: createdAt,
      );

      expect(invalidTest.isValid(), isFalse);
      final errors = invalidTest.getValidationErrors();
      expect(errors, contains('Test name is required'));
      expect(errors, contains('Group selection is required'));
      expect(errors, contains('Time limit must be at least 5 minutes'));
      expect(errors, contains('Test maker is required'));
      expect(errors, contains('Test date must be in the future'));
    });

    test('should serialize to and from Firebase map correctly', () {
      final map = validTest.toMap();
      
      expect(map['name'], equals('Mathematics Test'));
      expect(map['group_id'], equals('group_456'));
      expect(map['time_limit'], equals(60));
      expect(map['question_count'], equals(10));
      expect(map['test_maker'], equals('teacher_789'));
      expect(map['date_time'], isNotNull);
      expect(map['created_at'], isNotNull);

      // Test deserialization
      final deserializedTest = Test.fromMap('test_123', map);
      expect(deserializedTest.id, equals('test_123'));
      expect(deserializedTest.name, equals('Mathematics Test'));
      expect(deserializedTest.groupId, equals('group_456'));
      expect(deserializedTest.timeLimit, equals(60));
      expect(deserializedTest.testMaker, equals('teacher_789'));
    });

    test('should compute properties correctly', () {
      // Test for future test (not published yet)
      final futureTest = validTest.copyWith(
        dateTime: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(futureTest.isPublished, isFalse);
      expect(futureTest.isExpired, isFalse);
      expect(futureTest.isAvailable, isFalse);

      // Test for current test (published and available)
      final currentTest = validTest.copyWith(
        dateTime: DateTime.now().subtract(const Duration(minutes: 30)),
      );
      expect(currentTest.isPublished, isTrue);
      expect(currentTest.isExpired, isFalse);
      expect(currentTest.isAvailable, isTrue);

      // Test for expired test
      final expiredTest = validTest.copyWith(
        dateTime: DateTime.now().subtract(const Duration(hours: 2)),
        timeLimit: 60,
      );
      expect(expiredTest.isPublished, isTrue);
      expect(expiredTest.isExpired, isTrue);
      expect(expiredTest.isAvailable, isFalse);
    });

    test('should support copyWith method', () {
      final updatedTest = validTest.copyWith(
        name: 'Updated Test Name',
        timeLimit: 90,
      );

      expect(updatedTest.name, equals('Updated Test Name'));
      expect(updatedTest.timeLimit, equals(90));
      expect(updatedTest.id, equals(validTest.id)); // Unchanged
      expect(updatedTest.groupId, equals(validTest.groupId)); // Unchanged
    });

    test('should implement equality correctly', () {
      final sameTest = Test(
        id: 'test_123',
        name: 'Different Name',
        groupId: 'different_group',
        timeLimit: 30,
        questionCount: 5,
        dateTime: DateTime.now(),
        testMaker: 'different_teacher',
        createdAt: DateTime.now(),
      );

      expect(validTest == sameTest, isTrue); // Same ID
      expect(validTest.hashCode, equals(sameTest.hashCode));

      final differentTest = validTest.copyWith(id: 'different_id');
      expect(validTest == differentTest, isFalse);
    });
  });
}