import 'package:cloud_firestore/cloud_firestore.dart';

enum TestSessionStatus {
  notStarted,
  inProgress,
  completed,
  submitted,
  expired,
}

class StudentAnswer {
  final int selectedAnswerIndex;
  final DateTime answeredAt;
  final bool isCorrect;

  const StudentAnswer({
    required this.selectedAnswerIndex,
    required this.answeredAt,
    required this.isCorrect,
  });

  Map<String, dynamic> toMap() {
    return {
      'selected_answer_index': selectedAnswerIndex,
      'answered_at': Timestamp.fromDate(answeredAt),
      'is_correct': isCorrect,
    };
  }

  static StudentAnswer fromMap(Map<String, dynamic> map) {
    return StudentAnswer(
      selectedAnswerIndex: map['selected_answer_index'] ?? 0,
      answeredAt: _parseDateTime(map['answered_at']),
      isCorrect: map['is_correct'] ?? false,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }
}

class AntiCheatViolation {
  final String id;
  final DateTime timestamp;
  final String type;
  final String description;
  final Map<String, dynamic> metadata;

  const AntiCheatViolation({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.description,
    required this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type,
      'description': description,
      'metadata': metadata,
    };
  }

  static AntiCheatViolation fromMap(Map<String, dynamic> map) {
    return AntiCheatViolation(
      id: map['id'] ?? '',
      timestamp: _parseDateTime(map['timestamp']),
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }
}

class TestSession {
  final String id; // Firebase document ID
  final String testId; // Reference to tests collection
  final String studentId; // Firebase Auth UID
  final DateTime startTime;
  final DateTime? endTime;
  final int timeLimit; // copied from test for consistency
  final Map<String, StudentAnswer> answers; // questionId -> answer
  final List<String> questionOrder; // randomized question IDs
  final TestSessionStatus status;
  final List<AntiCheatViolation> violations;
  final int? finalScore;
  final DateTime createdAt;

  const TestSession({
    required this.id,
    required this.testId,
    required this.studentId,
    required this.startTime,
    this.endTime,
    required this.timeLimit,
    required this.answers,
    required this.questionOrder,
    required this.status,
    required this.violations,
    this.finalScore,
    required this.createdAt,
  });

  // Computed properties
  bool get isCompleted => status == TestSessionStatus.completed || status == TestSessionStatus.submitted;
  bool get isInProgress => status == TestSessionStatus.inProgress;
  bool get isExpired => status == TestSessionStatus.expired;
  
  Duration get elapsedTime {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  Duration get remainingTime {
    final elapsed = elapsedTime;
    final totalTime = Duration(minutes: timeLimit);
    final remaining = totalTime - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  int get answeredQuestionsCount => answers.length;
  int get totalQuestionsCount => questionOrder.length;
  double get progressPercentage => totalQuestionsCount > 0 ? (answeredQuestionsCount / totalQuestionsCount) * 100 : 0;

  // Firebase serialization methods
  Map<String, dynamic> toMap() {
    return {
      'test_id': testId,
      'student_id': studentId,
      'start_time': Timestamp.fromDate(startTime),
      'end_time': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'time_limit': timeLimit,
      'answers': answers.map((key, value) => MapEntry(key, value.toMap())),
      'question_order': questionOrder,
      'status': status.name,
      'violations': violations.map((v) => v.toMap()).toList(),
      'final_score': finalScore,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  static TestSession fromMap(String id, Map<String, dynamic> map) {
    return TestSession(
      id: id,
      testId: map['test_id'] ?? '',
      studentId: map['student_id'] ?? '',
      startTime: _parseDateTime(map['start_time']),
      endTime: map['end_time'] != null ? _parseDateTime(map['end_time']) : null,
      timeLimit: map['time_limit'] ?? 0,
      answers: _parseAnswers(map['answers']),
      questionOrder: List<String>.from(map['question_order'] ?? []),
      status: _parseStatus(map['status']),
      violations: _parseViolations(map['violations']),
      finalScore: map['final_score'],
      createdAt: _parseDateTime(map['created_at']),
    );
  }

  static TestSessionStatus _parseStatus(dynamic value) {
    if (value == null) return TestSessionStatus.notStarted;
    
    switch (value.toString().toLowerCase()) {
      case 'inprogress':
      case 'in_progress':
        return TestSessionStatus.inProgress;
      case 'completed':
        return TestSessionStatus.completed;
      case 'submitted':
        return TestSessionStatus.submitted;
      case 'expired':
        return TestSessionStatus.expired;
      case 'notstarted':
      case 'not_started':
      default:
        return TestSessionStatus.notStarted;
    }
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  static Map<String, StudentAnswer> _parseAnswers(dynamic value) {
    if (value == null) return {};
    
    final Map<String, dynamic> answersMap = Map<String, dynamic>.from(value);
    return answersMap.map((key, value) => 
      MapEntry(key, StudentAnswer.fromMap(Map<String, dynamic>.from(value)))
    );
  }

  static List<AntiCheatViolation> _parseViolations(dynamic value) {
    if (value == null) return [];
    
    final List<dynamic> violationsList = List<dynamic>.from(value);
    return violationsList.map((v) => 
      AntiCheatViolation.fromMap(Map<String, dynamic>.from(v))
    ).toList();
  }

  // Copy with method for updates
  TestSession copyWith({
    String? id,
    String? testId,
    String? studentId,
    DateTime? startTime,
    DateTime? endTime,
    int? timeLimit,
    Map<String, StudentAnswer>? answers,
    List<String>? questionOrder,
    TestSessionStatus? status,
    List<AntiCheatViolation>? violations,
    int? finalScore,
    DateTime? createdAt,
  }) {
    return TestSession(
      id: id ?? this.id,
      testId: testId ?? this.testId,
      studentId: studentId ?? this.studentId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      timeLimit: timeLimit ?? this.timeLimit,
      answers: answers ?? this.answers,
      questionOrder: questionOrder ?? this.questionOrder,
      status: status ?? this.status,
      violations: violations ?? this.violations,
      finalScore: finalScore ?? this.finalScore,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'TestSession(id: $id, testId: $testId, studentId: $studentId, status: $status, progress: ${progressPercentage.toStringAsFixed(1)}%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
