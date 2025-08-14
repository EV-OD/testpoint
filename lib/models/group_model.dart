import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testpoint/models/user_model.dart';

class Group {
  final String id; // Firebase document ID
  final String name;
  final List<String> userIds; // Firebase Auth UIDs
  final DateTime createdAt;

  // Additional local fields (not stored in Firebase)
  final List<User>? members; // Populated from userIds

  const Group({
    required this.id,
    required this.name,
    required this.userIds,
    required this.createdAt,
    this.members,
  });

  // Computed properties
  int get memberCount => userIds.length;
  bool get isEmpty => userIds.isEmpty;
  bool get isNotEmpty => userIds.isNotEmpty;

  // Check if a user is a member of this group
  bool containsUser(String userId) {
    return userIds.contains(userId);
  }

  // Firebase serialization methods
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'userIds': userIds,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  static Group fromMap(String id, Map<String, dynamic> map) {
    return Group(
      id: id,
      name: map['name'] ?? '',
      userIds: List<String>.from(map['userIds'] ?? []),
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
  Group copyWith({
    String? id,
    String? name,
    List<String>? userIds,
    DateTime? createdAt,
    List<User>? members,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      userIds: userIds ?? this.userIds,
      createdAt: createdAt ?? this.createdAt,
      members: members ?? this.members,
    );
  }

  // Add a user to the group
  Group addUser(String userId) {
    if (userIds.contains(userId)) {
      return this; // User already in group
    }
    return copyWith(userIds: [...userIds, userId]);
  }

  // Remove a user from the group
  Group removeUser(String userId) {
    if (!userIds.contains(userId)) {
      return this; // User not in group
    }
    return copyWith(userIds: userIds.where((id) => id != userId).toList());
  }

  // Validation methods
  bool isValid() {
    return name.trim().isNotEmpty &&
        name.trim().length >= 3 &&
        name.trim().length <= 100;
  }

  List<String> getValidationErrors() {
    List<String> errors = [];

    if (name.trim().isEmpty) {
      errors.add('Group name is required');
    }
    if (name.trim().length < 3) {
      errors.add('Group name must be at least 3 characters');
    }
    if (name.trim().length > 100) {
      errors.add('Group name cannot exceed 100 characters');
    }

    return errors;
  }

  @override
  String toString() {
    return 'Group(id: $id, name: $name, userIds: $userIds, createdAt: $createdAt, memberCount: $memberCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Group && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}