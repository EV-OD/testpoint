import 'package:firebase_auth/firebase_auth.dart' as auth;

class MockFirebaseAuth implements auth.FirebaseAuth {
  auth.User? _currentUser;

  void setCurrentUser(auth.User? user) {
    _currentUser = user;
  }

  @override
  auth.User? get currentUser => _currentUser;

  @override
  Stream<auth.User?> authStateChanges() {
    return Stream.value(_currentUser);
  }

  @override
  Stream<auth.User?> idTokenChanges() {
    return Stream.value(_currentUser);
  }

  @override
  Stream<auth.User?> userChanges() {
    return Stream.value(_currentUser);
  }

  @override
  Future<auth.UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final user = MockUser(uid: 'test_uid', email: email);
    _currentUser = user;
    return MockUserCredential(user: user);
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  @override
  Future<auth.UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final user = MockUser(uid: 'test_uid', email: email);
    _currentUser = user;
    return MockUserCredential(user: user);
  }

  // Implement other required methods with default/empty implementations
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockUser implements auth.User {
  @override
  final String uid;
  
  @override
  final String? email;

  MockUser({required this.uid, this.email});

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockUserCredential implements auth.UserCredential {
  @override
  final auth.User? user;

  MockUserCredential({this.user});

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}