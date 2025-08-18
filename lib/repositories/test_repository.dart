import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:testpoint/models/test_model.dart';
import 'package:testpoint/models/question_model.dart';
import 'package:testpoint/models/group_model.dart';
import 'package:testpoint/models/test_session_model.dart';

class TestRepository {
  final FirebaseFirestore _firestore;
  final auth.FirebaseAuth _auth;

  TestRepository({
    FirebaseFirestore? firestore,
    auth.FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = firebaseAuth ?? auth.FirebaseAuth.instance;

  // Collection references
  CollectionReference get _testsCollection => _firestore.collection('tests');
  CollectionReference get _groupsCollection => _firestore.collection('groups');
  CollectionReference get _testSessionsCollection =>
      _firestore.collection('test_sessions');

  // Test CRUD operations
  Future<String> createTest(Test test) async {
    try {
      final docRef = await _testsCollection.add(test.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create test: $e');
    }
  }

  Future<void> updateTest(Test test) async {
    try {
      await _testsCollection.doc(test.id).update(test.toMap());
    } catch (e) {
      throw Exception('Failed to update test: $e');
    }
  }

  Future<Test?> getTest(String testId) async {
    try {
      final doc = await _testsCollection.doc(testId).get();
      if (!doc.exists) return null;
      
      final test = Test.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      
      // Fetch group information if groupId exists
      Group? group;
      if (test.groupId.isNotEmpty) {
        try {
          group = await getGroup(test.groupId);
        } catch (e) {
          // If group fetch fails, continue without group info
          print('Failed to fetch group ${test.groupId}: $e');
        }
      }
      
      return test.copyWith(group: group);
    } catch (e) {
      throw Exception('Failed to get test: $e');
    }
  }

  Future<List<Test>> getTestsByCreator(String creatorId) async {
    try {
      final querySnapshot = await _testsCollection
          .where('test_maker', isEqualTo: creatorId)
          .get();

      final tests = <Test>[];
      
      // Process each test and populate group information
      for (final doc in querySnapshot.docs) {
        final test = Test.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        
        // Fetch group information if groupId exists
        Group? group;
        if (test.groupId.isNotEmpty) {
          try {
            group = await getGroup(test.groupId);
          } catch (e) {
            // If group fetch fails, continue without group info
            print('Failed to fetch group ${test.groupId}: $e');
          }
        }
        
        // Add test with populated group
        tests.add(test.copyWith(group: group));
      }
      
      // Sort by created_at in memory to avoid composite index requirement
      tests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return tests;
    } catch (e) {
      throw Exception('Failed to get tests by creator: $e');
    }
  }

  Future<List<Test>> getTestsByGroup(String groupId) async {
    try {
      print('DEBUG: Getting tests for group: $groupId');
      
      final querySnapshot = await _testsCollection
          .where('group_id', isEqualTo: groupId)
          .orderBy('date_time', descending: false)
          .get();

      print('DEBUG: Found ${querySnapshot.docs.length} tests for group $groupId');

      final tests = <Test>[];
      
      // Get the group information once since all tests belong to the same group
      Group? group;
      try {
        group = await getGroup(groupId);
      } catch (e) {
        print('Failed to fetch group $groupId: $e');
      }
      
      // Process each test and add the group information
      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print('DEBUG: Test doc ${doc.id}: $data');
        
        final test = Test.fromMap(doc.id, data);
        print('DEBUG: Parsed test: ${test.name} - Status: ${test.status} - Published: ${test.isPublished}');
        
        tests.add(test.copyWith(group: group));
      }
      
      return tests;
    } catch (e) {
      print('DEBUG: Error getting tests by group: $e');
      throw Exception('Failed to get tests by group: $e');
    }
  }

  Future<void> deleteTest(String testId) async {
    try {
      // First delete all questions in the subcollection
      final questionsSnapshot = await _testsCollection
          .doc(testId)
          .collection('questions')
          .get();

      final batch = _firestore.batch();
      
      // Delete all questions
      for (final questionDoc in questionsSnapshot.docs) {
        batch.delete(questionDoc.reference);
      }
      
      // Delete the test document
      batch.delete(_testsCollection.doc(testId));
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete test: $e');
    }
  }

  // Question CRUD operations
  Future<String> addQuestion(String testId, Question question) async {
    try {
      final docRef = await _testsCollection
          .doc(testId)
          .collection('questions')
          .add(question.toMap());

      // Update question count in the test document
      await _updateQuestionCount(testId);
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add question: $e');
    }
  }

  Future<void> updateQuestion(String testId, String questionId, Question question) async {
    try {
      await _testsCollection
          .doc(testId)
          .collection('questions')
          .doc(questionId)
          .update(question.toMap());
    } catch (e) {
      throw Exception('Failed to update question: $e');
    }
  }

  Future<void> deleteQuestion(String testId, String questionId) async {
    try {
      await _testsCollection
          .doc(testId)
          .collection('questions')
          .doc(questionId)
          .delete();

      // Update question count in the test document
      await _updateQuestionCount(testId);
    } catch (e) {
      throw Exception('Failed to delete question: $e');
    }
  }

  Future<List<Question>> getQuestions(String testId) async {
    try {
      print('DEBUG: TestRepository.getQuestions called for testId: $testId');
      final querySnapshot = await _testsCollection
          .doc(testId)
          .collection('questions')
          .orderBy('created_at')
          .get();

      final questions = querySnapshot.docs
          .map((doc) => Question.fromMap(doc.id, doc.data()))
          .toList();
      print('DEBUG: TestRepository.getQuestions fetched ${questions.length} questions.');
      return questions;
    } catch (e) {
      print('DEBUG: Error in TestRepository.getQuestions: $e');
      throw Exception('Failed to get questions: $e');
    }
  }

  // Helper method to update question count
  Future<void> _updateQuestionCount(String testId) async {
    try {
      final questionsSnapshot = await _testsCollection
          .doc(testId)
          .collection('questions')
          .get();

      await _testsCollection.doc(testId).update({
        'question_count': questionsSnapshot.docs.length,
      });
    } catch (e) {
      throw Exception('Failed to update question count: $e');
    }
  }

  // Group operations
  Future<List<Group>> getGroups() async {
    try {
      final querySnapshot = await _groupsCollection
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => Group.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get groups: $e');
    }
  }

  Future<Group?> getGroup(String groupId) async {
    try {
      final doc = await _groupsCollection.doc(groupId).get();
      if (!doc.exists) return null;
      
      return Group.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get group: $e');
    }
  }

  // Stream methods for real-time updates
  Stream<List<Test>> watchTestsByCreator(String creatorId) {
    return _testsCollection
        .where('test_maker', isEqualTo: creatorId)
        .snapshots()
        .asyncMap((snapshot) async {
          final tests = <Test>[];
          
          // Process each test and populate group information
          for (final doc in snapshot.docs) {
            final test = Test.fromMap(doc.id, doc.data() as Map<String, dynamic>);
            
            // Fetch group information if groupId exists
            Group? group;
            if (test.groupId.isNotEmpty) {
              try {
                group = await getGroup(test.groupId);
              } catch (e) {
                // If group fetch fails, continue without group info
                print('Failed to fetch group ${test.groupId}: $e');
              }
            }
            
            // Add test with populated group
            tests.add(test.copyWith(group: group));
          }
          
          // Sort by created_at in memory to avoid composite index requirement
          tests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          return tests;
        });
  }

  Stream<List<Question>> watchQuestions(String testId) {
    return _testsCollection
        .doc(testId)
        .collection('questions')
        .orderBy('created_at')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Question.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<Test?> watchTest(String testId) {
    return _testsCollection
        .doc(testId)
        .snapshots()
        .asyncMap((snapshot) async {
          if (!snapshot.exists) return null;
          
          final test = Test.fromMap(snapshot.id, snapshot.data() as Map<String, dynamic>);
          
          // Fetch group information if groupId exists
          Group? group;
          if (test.groupId.isNotEmpty) {
            try {
              group = await getGroup(test.groupId);
            } catch (e) {
              // If group fetch fails, continue without group info
              print('Failed to fetch group ${test.groupId}: $e');
            }
          }
          
          return test.copyWith(group: group);
        });
  }

  // Validation methods
  Future<bool> validateTestOwnership(String testId, String userId) async {
    try {
      final test = await getTest(testId);
      return test?.testMaker == userId;
    } catch (e) {
      return false;
    }
  }

  Future<bool> canEditTest(String testId, String userId) async {
    try {
      final test = await getTest(testId);
      if (test == null) return false;
      
      // Check ownership
      if (test.testMaker != userId) return false;
      
      // Check if test is not yet published (can still edit)
      return !test.isPublished;
    } catch (e) {
      return false;
    }
  }

  Future<bool> canDeleteTest(String testId, String userId) async {
    try {
      final test = await getTest(testId);
      if (test == null) return false;
      
      // Check ownership
      if (test.testMaker != userId) return false;
      
      // Check if test is not yet published (can still delete)
      return !test.isPublished;
    } catch (e) {
      return false;
    }
  }

  // Test session operations
  Future<TestSession?> getTestSession(String testId, String studentId) async {
    try {
      final querySnapshot = await _testSessionsCollection
          .where('test_id', isEqualTo: testId)
          .where('student_id', isEqualTo: studentId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      return TestSession.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get test session: $e');
    }
  }

  Future<void> submitTestSession(TestSession session) async {
    try {
      await _testSessionsCollection.doc(session.id).set(session.toMap());
    } catch (e) {
      throw Exception('Failed to submit test session: $e');
    }
  }

  Future<List<TestSession>> getTestSubmissions(String testId) async {
    try {
      print('DEBUG: TestRepository.getTestSubmissions called for testId: $testId');
      final querySnapshot = await _testSessionsCollection
          .where('test_id', isEqualTo: testId)
          .get();

      final submissions = querySnapshot.docs
          .map((doc) => TestSession.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      print('DEBUG: TestRepository.getTestSubmissions fetched ${submissions.length} submissions.');
      return submissions;
    } catch (e) {
      print('DEBUG: Error in TestRepository.getTestSubmissions: $e');
      throw Exception('Failed to get test submissions: $e');
    }
  }

  // Delete all test sessions for a test
  Future<void> deleteTestSessions(String testId) async {
    try {
      print('DEBUG: TestRepository.deleteTestSessions called for testId: $testId');
      
      // Get all test sessions for the test
      final querySnapshot = await _testSessionsCollection
          .where('test_id', isEqualTo: testId)
          .get();
      
      // Delete each session
      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('DEBUG: TestRepository.deleteTestSessions deleted ${querySnapshot.docs.length} sessions for testId: $testId');
    } catch (e) {
      print('DEBUG: Error in TestRepository.deleteTestSessions: $e');
      throw Exception('Failed to delete test sessions: $e');
    }
  }
}