import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testpoint/models/user_model.dart';

class AuthService {
  final auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthService({
    auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Sign in with email and password
  Future<User?> login(String email, String password) async {
    try {
      // Authenticate with Firebase Auth
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Get user data from Firestore
        return await _getUserFromFirestore(credential.user!.uid);
      }
      return null;
    } on auth.FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Sign out current user
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  /// Get current authenticated user
  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        return await _getUserFromFirestore(firebaseUser.uid);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser != null) {
        return await _getUserFromFirestore(firebaseUser.uid);
      }
      return null;
    });
  }

  /// Get user data from Firestore users collection
  Future<User?> _getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return User.fromMap(uid, doc.data()!);
      }
      
      // If user doesn't exist in Firestore but exists in Firebase Auth,
      // create a default profile (this handles manually created users)
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        final defaultUser = User(
          id: uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          role: UserRole.student, // Default role, can be changed later
        );
        
        // Save to Firestore
        await _firestore.collection('users').doc(uid).set(defaultUser.toMap());
        return defaultUser;
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  /// Create user profile in Firestore (for registration)
  Future<User> createUserProfile({
    required String uid,
    required String name,
    required String email,
    required UserRole role,
  }) async {
    try {
      final user = User(
        id: uid,
        name: name,
        email: email,
        role: role,
      );

      await _firestore.collection('users').doc(uid).set(user.toMap());
      return user;
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  /// Register new user with email and password
  Future<User?> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    try {
      // Create Firebase Auth user
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(name);

        // Create user profile in Firestore
        return await createUserProfile(
          uid: credential.user!.uid,
          name: name,
          email: email,
          role: role,
        );
      }
      return null;
    } on auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Handle Firebase Auth exceptions
  String _handleAuthException(auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials.';
      default:
        return 'Authentication failed: ${e.message ?? 'Unknown error'}';
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _firebaseAuth.currentUser != null;

  /// Get current Firebase user
  auth.User? get currentFirebaseUser => _firebaseAuth.currentUser;
}
