import 'package:testpoint/models/user_model.dart';

final List<User> dummyUsers = [
  const User(
    id: 's1',
    name: 'Alice Student',
    email: 'student@test.com',
    password: 'studentpass',
    role: UserRole.student,
  ),
  const User(
    id: 't1',
    name: 'Bob Teacher',
    email: 'teacher@test.com',
    password: 'teacherpass',
    role: UserRole.teacher,
  ),
];
