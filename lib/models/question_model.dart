import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String id; // Firebase document ID
  final String text;
  final List<QuestionOption> options; // 4 options
  final DateTime createdAt;

  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.createdAt,
  });

  // Get the correct answer option
  QuestionOption? get correctOption {
    try {
      return options.firstWhere((option) => option.isCorrect);
    } catch (e) {
      return null;
    }
  }

  // Get the index of the correct answer (0-3)
  int get correctAnswerIndex {
    for (int i = 0; i < options.length; i++) {
      if (options[i].isCorrect) {
        return i;
      }
    }
    return -1; // No correct answer found
  }

  // Firebase serialization methods
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'options': options.map((option) => option.toMap()).toList(),
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  static Question fromMap(String id, Map<String, dynamic> map) {
    return Question(
      id: id,
      text: map['text'] ?? '',
      options: (map['options'] as List<dynamic>?)
              ?.map((optionMap) => QuestionOption.fromMap(optionMap))
              .toList() ??
          [],
      createdAt: _parseDateTime(map['created_at']),
    );
  }

  // Helper method to parse DateTime from various formats
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }
    
    if (value is Timestamp) {
      return value.toDate();
    }
    
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        // If parsing fails, return current time
        return DateTime.now();
      }
    }
    
    if (value is int) {
      // Assume it's milliseconds since epoch
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    
    // Fallback to current time
    return DateTime.now();
  }

  // Copy with method for updates
  Question copyWith({
    String? id,
    String? text,
    List<QuestionOption>? options,
    DateTime? createdAt,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      options: options ?? this.options,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Validation methods
  bool isValid() {
    return text.trim().isNotEmpty &&
        options.length == 4 &&
        options.every((option) => option.isValid()) &&
        _hasExactlyOneCorrectAnswer() &&
        _allOptionsAreUnique();
  }

  bool _hasExactlyOneCorrectAnswer() {
    int correctCount = options.where((option) => option.isCorrect).length;
    return correctCount == 1;
  }

  bool _allOptionsAreUnique() {
    Set<String> uniqueTexts = options.map((option) => option.text.trim().toLowerCase()).toSet();
    return uniqueTexts.length == options.length;
  }

  List<String> getValidationErrors() {
    List<String> errors = [];

    if (text.trim().isEmpty) {
      errors.add('Question text is required');
    }
    if (text.trim().length < 10) {
      errors.add('Question text must be at least 10 characters');
    }
    if (text.trim().length > 500) {
      errors.add('Question text cannot exceed 500 characters');
    }
    if (options.length != 4) {
      errors.add('Question must have exactly 4 options');
    }
    if (!_hasExactlyOneCorrectAnswer()) {
      errors.add('Question must have exactly one correct answer');
    }
    if (!_allOptionsAreUnique()) {
      errors.add('All answer options must be unique');
    }

    // Validate individual options
    for (int i = 0; i < options.length; i++) {
      List<String> optionErrors = options[i].getValidationErrors();
      for (String error in optionErrors) {
        errors.add('Option ${i + 1}: $error');
      }
    }

    return errors;
  }

  @override
  String toString() {
    return 'Question(id: $id, text: $text, options: $options, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Question && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class QuestionOption {
  final String id;
  final String text;
  final bool isCorrect; // Only one should be true per question

  const QuestionOption({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  // Firebase serialization methods
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isCorrect': isCorrect,
    };
  }

  static QuestionOption fromMap(Map<String, dynamic> map) {
    return QuestionOption(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      isCorrect: map['isCorrect'] ?? false,
    );
  }

  // Copy with method for updates
  QuestionOption copyWith({
    String? id,
    String? text,
    bool? isCorrect,
  }) {
    return QuestionOption(
      id: id ?? this.id,
      text: text ?? this.text,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }

  // Validation methods
  bool isValid() {
    return text.trim().isNotEmpty &&
        text.trim().length >= 1 &&
        text.trim().length <= 100 &&
        id.isNotEmpty;
  }

  List<String> getValidationErrors() {
    List<String> errors = [];

    if (text.trim().isEmpty) {
      errors.add('Option text is required');
    }
    if (text.trim().length > 100) {
      errors.add('Option text cannot exceed 100 characters');
    }
    if (id.isEmpty) {
      errors.add('Option ID is required');
    }

    return errors;
  }

  @override
  String toString() {
    return 'QuestionOption(id: $id, text: $text, isCorrect: $isCorrect)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuestionOption && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}