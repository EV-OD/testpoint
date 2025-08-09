import 'package:flutter_test/flutter_test.dart';
import 'package:testpoint/models/question_model.dart';

void main() {
  group('Question Model Tests', () {
    late Question validQuestion;
    late List<QuestionOption> validOptions;

    setUp(() {
      validOptions = [
        const QuestionOption(id: 'opt1', text: 'Option A', isCorrect: false),
        const QuestionOption(id: 'opt2', text: 'Option B', isCorrect: true),
        const QuestionOption(id: 'opt3', text: 'Option C', isCorrect: false),
        const QuestionOption(id: 'opt4', text: 'Option D', isCorrect: false),
      ];

      validQuestion = Question(
        id: 'question_123',
        text: 'What is the capital of France?',
        options: validOptions,
        createdAt: DateTime.now(),
      );
    });

    test('should create a valid question instance', () {
      expect(validQuestion.id, equals('question_123'));
      expect(validQuestion.text, equals('What is the capital of France?'));
      expect(validQuestion.options.length, equals(4));
      expect(validQuestion.correctAnswerIndex, equals(1));
    });

    test('should find correct option', () {
      final correctOption = validQuestion.correctOption;
      expect(correctOption, isNotNull);
      expect(correctOption!.text, equals('Option B'));
      expect(correctOption.isCorrect, isTrue);
    });

    test('should validate correctly for valid question', () {
      expect(validQuestion.isValid(), isTrue);
      expect(validQuestion.getValidationErrors(), isEmpty);
    });

    test('should fail validation for invalid question', () {
      final invalidOptions = [
        const QuestionOption(id: 'opt1', text: '', isCorrect: false), // Empty text
        const QuestionOption(id: 'opt2', text: 'Option B', isCorrect: true),
        const QuestionOption(id: 'opt3', text: 'Option B', isCorrect: false), // Duplicate text
        const QuestionOption(id: 'opt4', text: 'Option D', isCorrect: true), // Two correct answers
      ];

      final invalidQuestion = Question(
        id: 'question_123',
        text: 'Short', // Too short
        options: invalidOptions,
        createdAt: DateTime.now(),
      );

      expect(invalidQuestion.isValid(), isFalse);
      final errors = invalidQuestion.getValidationErrors();
      expect(errors, contains('Question text must be at least 10 characters'));
      expect(errors, contains('Question must have exactly one correct answer'));
      expect(errors, contains('All answer options must be unique'));
    });

    test('should serialize to and from Firebase map correctly', () {
      final map = validQuestion.toMap();
      
      expect(map['text'], equals('What is the capital of France?'));
      expect(map['options'], isA<List>());
      expect(map['options'].length, equals(4));
      expect(map['created_at'], isNotNull);

      // Test deserialization
      final deserializedQuestion = Question.fromMap('question_123', map);
      expect(deserializedQuestion.id, equals('question_123'));
      expect(deserializedQuestion.text, equals('What is the capital of France?'));
      expect(deserializedQuestion.options.length, equals(4));
      expect(deserializedQuestion.correctAnswerIndex, equals(1));
    });

    test('should support copyWith method', () {
      final updatedQuestion = validQuestion.copyWith(
        text: 'Updated question text?',
      );

      expect(updatedQuestion.text, equals('Updated question text?'));
      expect(updatedQuestion.id, equals(validQuestion.id)); // Unchanged
      expect(updatedQuestion.options, equals(validQuestion.options)); // Unchanged
    });

    test('should implement equality correctly', () {
      final sameQuestion = Question(
        id: 'question_123',
        text: 'Different text',
        options: [],
        createdAt: DateTime.now(),
      );

      expect(validQuestion == sameQuestion, isTrue); // Same ID
      expect(validQuestion.hashCode, equals(sameQuestion.hashCode));

      final differentQuestion = validQuestion.copyWith(id: 'different_id');
      expect(validQuestion == differentQuestion, isFalse);
    });
  });

  group('QuestionOption Model Tests', () {
    late QuestionOption validOption;

    setUp(() {
      validOption = const QuestionOption(
        id: 'opt1',
        text: 'Option A',
        isCorrect: true,
      );
    });

    test('should create a valid option instance', () {
      expect(validOption.id, equals('opt1'));
      expect(validOption.text, equals('Option A'));
      expect(validOption.isCorrect, isTrue);
    });

    test('should validate correctly for valid option', () {
      expect(validOption.isValid(), isTrue);
      expect(validOption.getValidationErrors(), isEmpty);
    });

    test('should fail validation for invalid option', () {
      const invalidOption = QuestionOption(
        id: '', // Empty ID
        text: '', // Empty text
        isCorrect: false,
      );

      expect(invalidOption.isValid(), isFalse);
      final errors = invalidOption.getValidationErrors();
      expect(errors, contains('Option text is required'));
      expect(errors, contains('Option ID is required'));
    });

    test('should serialize to and from Firebase map correctly', () {
      final map = validOption.toMap();
      
      expect(map['id'], equals('opt1'));
      expect(map['text'], equals('Option A'));
      expect(map['isCorrect'], isTrue);

      // Test deserialization
      final deserializedOption = QuestionOption.fromMap(map);
      expect(deserializedOption.id, equals('opt1'));
      expect(deserializedOption.text, equals('Option A'));
      expect(deserializedOption.isCorrect, isTrue);
    });

    test('should support copyWith method', () {
      final updatedOption = validOption.copyWith(
        text: 'Updated Option',
        isCorrect: false,
      );

      expect(updatedOption.text, equals('Updated Option'));
      expect(updatedOption.isCorrect, isFalse);
      expect(updatedOption.id, equals(validOption.id)); // Unchanged
    });

    test('should implement equality correctly', () {
      const sameOption = QuestionOption(
        id: 'opt1',
        text: 'Different text',
        isCorrect: false,
      );

      expect(validOption == sameOption, isTrue); // Same ID
      expect(validOption.hashCode, equals(sameOption.hashCode));

      const differentOption = QuestionOption(
        id: 'different_id',
        text: 'Option A',
        isCorrect: true,
      );
      expect(validOption == differentOption, isFalse);
    });
  });
}