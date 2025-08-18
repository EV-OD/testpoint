import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testpoint/models/question_model.dart';
import 'package:testpoint/models/group_model.dart';
import 'package:testpoint/models/user_model.dart';

enum TestStatus { draft, published, completed }

class Test {
  final String id; // Firebase document ID
  final String name;
  final String groupId; // Reference to groups collection
  final int timeLimit; // in minutes
  final int questionCount; // auto-updated by Firebase
  final DateTime dateTime; // scheduled date/time
  final String testMaker; // Firebase Auth UID of teacher who created the test
  final DateTime createdAt;
  final TestStatus status; // draft, published, or completed

  // Additional local fields (not stored in Firebase)
  final Group? group; // Populated from groupId
  final List<Question>? questions; // Loaded from subcollection
  final User? creator; // Populated from testMaker UID

  const Test({
    required this.id,
    required this.name,
    required this.groupId,
    required this.timeLimit,
    required this.questionCount,
    required this.dateTime,
    required this.testMaker,
    required this.createdAt,
    this.status = TestStatus.draft,
    this.group,
    this.questions,
    this.creator,
  });

  // Computed properties
  bool get isDraft => status == TestStatus.draft;
  bool get isPublished => status == TestStatus.published;
  bool get isCompleted => status == TestStatus.completed;
  bool get isExpired => DateTime.now().isAfter(dateTime.add(Duration(minutes: timeLimit)));
  bool get isAvailable => isPublished && DateTime.now().isAfter(dateTime) && !isExpired;

  // Firebase serialization methods
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'group_id': groupId,
      'time_limit': timeLimit,
      'question_count': questionCount,
      'date_time': Timestamp.fromDate(dateTime),
      'test_maker': testMaker,
      'created_at': Timestamp.fromDate(createdAt),
      'status': status.name,
    };
  }

  static Test fromMap(String id, Map<String, dynamic> map) {
    return Test(
      id: id,
      name: map['name'] ?? '',
      groupId: map['group_id'] ?? '',
      timeLimit: map['time_limit'] ?? 0,
      questionCount: map['question_count'] ?? 0,
      dateTime: _parseDateTime(map['date_time']),
      testMaker: map['test_maker'] ?? '',
      createdAt: _parseDateTime(map['created_at']),
      status: _parseStatus(map['status']),
    );
  }

  // Helper method to parse TestStatus from string
  static TestStatus _parseStatus(dynamic value) {
    if (value == null) return TestStatus.draft;
    
    switch (value.toString().toLowerCase()) {
      case 'published':
        return TestStatus.published;
      case 'completed':
        return TestStatus.completed;
      case 'draft':
      default:
        return TestStatus.draft;
    }
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
  Test copyWith({
    String? id,
    String? name,
    String? groupId,
    int? timeLimit,
    int? questionCount,
    DateTime? dateTime,
    String? testMaker,
    DateTime? createdAt,
    TestStatus? status,
    Group? group,
    List<Question>? questions,
    User? creator,
  }) {
    return Test(
      id: id ?? this.id,
      name: name ?? this.name,
      groupId: groupId ?? this.groupId,
      timeLimit: timeLimit ?? this.timeLimit,
      questionCount: questionCount ?? this.questionCount,
      dateTime: dateTime ?? this.dateTime,
      testMaker: testMaker ?? this.testMaker,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      group: group ?? this.group,
      questions: questions ?? this.questions,
      creator: creator ?? this.creator,
    );
  }

  // Validation methods
  bool isValid() {
    return name.isNotEmpty &&
        groupId.isNotEmpty &&
        timeLimit >= 5 &&
        timeLimit <= 300 &&
        testMaker.isNotEmpty &&
        dateTime.isAfter(DateTime.now());
  }

  List<String> getValidationErrors() {
    List<String> errors = [];
    
    if (name.isEmpty) {
      errors.add('Test name is required');
    }
    if (groupId.isEmpty) {
      errors.add('Group selection is required');
    }
    if (timeLimit < 5) {
      errors.add('Time limit must be at least 5 minutes');
    }
    if (timeLimit > 300) {
      errors.add('Time limit cannot exceed 300 minutes');
    }
    if (testMaker.isEmpty) {
      errors.add('Test maker is required');
    }
    if (dateTime.isBefore(DateTime.now())) {
      errors.add('Test date must be in the future');
    }
    
    return errors;
  }

  // Time-based computed properties
  DateTime get testEndTime => dateTime.add(Duration(minutes: timeLimit));
  
  bool get isTimeUp => DateTime.now().isAfter(testEndTime);
  
  bool get areResultsAvailable => isTimeUp;
  
  // Check if the test is currently active (started but not ended)
  bool get isCurrentlyActive {
    final now = DateTime.now();
    return now.isAfter(dateTime) && now.isBefore(testEndTime);
  }

  @override
  String toString() {
    return 'Test(id: $id, name: $name, groupId: $groupId, timeLimit: $timeLimit, questionCount: $questionCount, dateTime: $dateTime, testMaker: $testMaker, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Test && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}