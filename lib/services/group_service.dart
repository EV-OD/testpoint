import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:testpoint/models/group_model.dart';
import 'package:testpoint/models/user_model.dart';

class GroupService {
  final FirebaseFirestore _firestore;
  final auth.FirebaseAuth _auth;

  GroupService({
    FirebaseFirestore? firestore,
    auth.FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = firebaseAuth ?? auth.FirebaseAuth.instance;

  // Collection references
  CollectionReference get _groupsCollection => _firestore.collection('groups');
  CollectionReference get _usersCollection => _firestore.collection('users');

  /// Get all available groups
  /// For teachers and admins, returns all groups
  /// For students, returns only groups they belong to
  Future<List<Group>> getAvailableGroups(String userId) async {
    try {
      // Get user to check their role
      final userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final user = User.fromMap(userId, userDoc.data() as Map<String, dynamic>);

      QuerySnapshot querySnapshot;

      if (user.isStudent) {
        // Students can only see groups they belong to
        querySnapshot = await _groupsCollection
            .where('userIds', arrayContains: userId)
            .get();
      } else {
        // Teachers and admins can see all groups
        querySnapshot = await _groupsCollection
            .orderBy('name')
            .get();
      }

      return querySnapshot.docs
          .map((doc) => Group.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList()
          ..sort((a, b) => a.name.compareTo(b.name)); // Client-side sorting
    } catch (e) {
      throw Exception('Failed to get available groups: $e');
    }
  }

  /// Get a specific group by ID
  Future<Group?> getGroupById(String groupId) async {
    try {
      final doc = await _groupsCollection.doc(groupId).get();
      if (!doc.exists) return null;
      
      return Group.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get group: $e');
    }
  }

  /// Get all members of a group
  Future<List<User>> getGroupMembers(String groupId) async {
    try {
      final group = await getGroupById(groupId);
      if (group == null) {
        throw Exception('Group not found');
      }

      if (group.userIds.isEmpty) {
        return [];
      }

      // Get all users in the group
      final List<User> members = [];
      
      // Firestore 'in' queries are limited to 10 items, so we need to batch
      const batchSize = 10;
      for (int i = 0; i < group.userIds.length; i += batchSize) {
        final batch = group.userIds.skip(i).take(batchSize).toList();
        
        final querySnapshot = await _usersCollection
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        final batchMembers = querySnapshot.docs
            .map((doc) => User.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList();
        
        members.addAll(batchMembers);
      }

      return members;
    } catch (e) {
      throw Exception('Failed to get group members: $e');
    }
  }

  /// Get groups that a specific user belongs to
  Future<List<Group>> getUserGroups(String userId) async {
    try {
      print('DEBUG: Getting groups for user: $userId');
      
      final querySnapshot = await _groupsCollection
          .where('userIds', arrayContains: userId)
          .get();

      print('DEBUG: Found ${querySnapshot.docs.length} groups for user');
      
      final groups = querySnapshot.docs
          .map((doc) => Group.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList()
          ..sort((a, b) => a.name.compareTo(b.name)); // Client-side sorting

      for (var group in groups) {
        print('DEBUG: Group - ${group.name} (${group.id}) - Users: ${group.userIds}');
      }

      return groups;
    } catch (e) {
      print('DEBUG: Error getting user groups: $e');
      throw Exception('Failed to get user groups: $e');
    }
  }

  /// Check if a user belongs to a specific group
  Future<bool> isUserInGroup(String userId, String groupId) async {
    try {
      final group = await getGroupById(groupId);
      return group?.containsUser(userId) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Get groups with populated member information
  Future<List<Group>> getGroupsWithMembers() async {
    try {
      final groups = await getAvailableGroups(_auth.currentUser?.uid ?? '');
      
      final List<Group> groupsWithMembers = [];
      
      for (final group in groups) {
        final members = await getGroupMembers(group.id);
        final groupWithMembers = group.copyWith(members: members);
        groupsWithMembers.add(groupWithMembers);
      }
      
      return groupsWithMembers;
    } catch (e) {
      throw Exception('Failed to get groups with members: $e');
    }
  }

  /// Stream methods for real-time updates
  Stream<List<Group>> watchAvailableGroups(String userId) {
    return _groupsCollection
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Group.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<Group?> watchGroup(String groupId) {
    return _groupsCollection
        .doc(groupId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          return Group.fromMap(snapshot.id, snapshot.data() as Map<String, dynamic>);
        });
  }

  /// Validation methods
  Future<bool> canUserAccessGroup(String userId, String groupId) async {
    try {
      // Get user to check their role
      final userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists) return false;

      final user = User.fromMap(userId, userDoc.data() as Map<String, dynamic>);

      // Admins and teachers can access all groups
      if (user.isAdmin || user.isTeacher) {
        return true;
      }

      // Students can only access groups they belong to
      return await isUserInGroup(userId, groupId);
    } catch (e) {
      return false;
    }
  }

  /// Get student groups for test assignment
  /// Returns groups that contain students (for teachers creating tests)
  Future<List<Group>> getStudentGroups() async {
    try {
      final querySnapshot = await _groupsCollection
          .orderBy('name')
          .get();

      final List<Group> studentGroups = [];

      for (final doc in querySnapshot.docs) {
        final group = Group.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        
        // Check if group has any students
        if (group.userIds.isNotEmpty) {
          // Get a sample of users to check if any are students
          final members = await getGroupMembers(group.id);
          final hasStudents = members.any((user) => user.isStudent);
          
          if (hasStudents) {
            studentGroups.add(group);
          }
        }
      }

      return studentGroups;
    } catch (e) {
      throw Exception('Failed to get student groups: $e');
    }
  }
}