import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { student, teacher, admin }

class User {
  final String id; // Firebase Auth UID
  final String name;
  final String email;
  final UserRole role;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  // Computed properties
  bool get isStudent => role == UserRole.student;
  bool get isTeacher => role == UserRole.teacher;
  bool get isAdmin => role == UserRole.admin;
  bool get canCreateTests => isTeacher || isAdmin;
  bool get canManageUsers => isAdmin;

  // Firebase serialization methods
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.toString().split('.').last, // Convert enum to string
    };
  }

  static User fromMap(String id, Map<String, dynamic> map) {
    return User(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: _parseRole(map['role'] ?? 'student'),
    );
  }

  static UserRole _parseRole(String roleString) {
    switch (roleString.toLowerCase()) {
      case 'teacher':
        return UserRole.teacher;
      case 'admin':
        return UserRole.admin;
      case 'student':
      default:
        return UserRole.student;
    }
  }

  // Copy with method for updates
  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }

  // Validation methods
  bool isValid() {
    return name.trim().isNotEmpty &&
        email.trim().isNotEmpty &&
        _isValidEmail(email) &&
        id.isNotEmpty;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  List<String> getValidationErrors() {
    List<String> errors = [];

    if (name.trim().isEmpty) {
      errors.add('Name is required');
    }
    if (name.trim().length < 2) {
      errors.add('Name must be at least 2 characters');
    }
    if (email.trim().isEmpty) {
      errors.add('Email is required');
    }
    if (!_isValidEmail(email)) {
      errors.add('Invalid email format');
    }
    if (id.isEmpty) {
      errors.add('User ID is required');
    }

    return errors;
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}