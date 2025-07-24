enum UserRole { student, teacher }

class User {
  final String id;
  final String name;
  final String email;
  final String password; // Added password field
  final UserRole role;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.password, // Added to constructor
    required this.role,
  });
}
