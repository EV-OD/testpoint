import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testpoint/models/question_model.dart';
import 'package:testpoint/models/group_model.dart';
import 'package:testpoint/models/user_model.dart';

class Test {
  final String id; // Firebase document ID
  final String name;
  final String groupId; // Reference to groups collection
  final int timeLimit; // in minutes
  final int questionCount; // auto-updated by Firebase
  final DateTime dateTime; // scheduled date/time
  final String testMaker; // Firebase Auth UID of teacher who created the test
  final DateTime createdAt;

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
    this.group,
    this.questions,
    this.creator,
  });

  // Computed properties
  bool get isPublished => DateTime.now().isAfter(dateTime);
  bool get isExpired => DateTime.now().isAfter(dateTime.add(Duration(minutes: timeLimit)));
  bool get isAvailable => DateTime.now().isAfter(dateTime) && !isExpired;

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
    };
  }

  static Test fromMap(String id, Map<String, dynamic> map) {
    return Test(
      id: id,
      name: map['name'] ?? '',
      groupId: map['group_id'] ?? '',
      timeLimit: map['time_limit'] ?? 0,
      questionCount: map['question_count'] ?? 0,
      dateTime: (map['date_time'] as Timestamp).toDate(),
      testMaker: map['test_maker'] ?? '',
      createdAt: (map['created_at'] as Timestamp).toDate(),
    );
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