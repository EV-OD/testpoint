import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionMigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Migration utility to add correctOptionIndex to existing questions
  /// that only have isCorrect boolean flags in options
  Future<void> migrateQuestionsToCorrectOptionIndex() async {
    try {
      print('Starting question migration...');
      
      // Get all test collections
      final testsSnapshot = await _firestore.collection('tests').get();
      
      int testsProcessed = 0;
      int questionsUpdated = 0;
      
      for (final testDoc in testsSnapshot.docs) {
        try {
          final questionsSnapshot = await testDoc.reference
              .collection('questions')
              .get();
          
          for (final questionDoc in questionsSnapshot.docs) {
            final data = questionDoc.data();
            
            // Check if question already has correctOptionIndex
            if (data.containsKey('correctOptionIndex')) {
              continue; // Skip, already migrated
            }
            
            // Check if options array exists
            final options = data['options'] as List<dynamic>?;
            if (options == null || options.isEmpty) {
              print('Warning: Question ${questionDoc.id} has no options');
              continue;
            }
            
            // Find the correct answer index from isCorrect flags
            int? correctIndex;
            for (int i = 0; i < options.length; i++) {
              final option = options[i] as Map<String, dynamic>?;
              if (option != null && option['isCorrect'] == true) {
                correctIndex = i;
                break;
              }
            }
            
            if (correctIndex != null) {
              // Update the question with correctOptionIndex
              await questionDoc.reference.update({
                'correctOptionIndex': correctIndex,
              });
              questionsUpdated++;
              print('Updated question ${questionDoc.id} with correctOptionIndex: $correctIndex');
            } else {
              print('Warning: Question ${questionDoc.id} has no correct answer');
            }
          }
          
          testsProcessed++;
        } catch (e) {
          print('Error processing test ${testDoc.id}: $e');
        }
      }
      
      print('Migration completed:');
      print('- Tests processed: $testsProcessed');
      print('- Questions updated: $questionsUpdated');
    } catch (e) {
      print('Migration failed: $e');
      rethrow;
    }
  }

  /// Validate that all questions have valid correct answers
  Future<Map<String, dynamic>> validateAllQuestions() async {
    try {
      final testsSnapshot = await _firestore.collection('tests').get();
      
      List<Map<String, dynamic>> invalidQuestions = [];
      int totalQuestions = 0;
      int validQuestions = 0;
      
      for (final testDoc in testsSnapshot.docs) {
        final questionsSnapshot = await testDoc.reference
            .collection('questions')
            .get();
        
        for (final questionDoc in questionsSnapshot.docs) {
          totalQuestions++;
          final data = questionDoc.data();
          
          // Check correctOptionIndex method
          final correctOptionIndex = data['correctOptionIndex'] as int?;
          final options = data['options'] as List<dynamic>?;
          
          bool isValid = false;
          String validationMessage = '';
          
          if (correctOptionIndex != null && 
              options != null && 
              correctOptionIndex >= 0 && 
              correctOptionIndex < options.length) {
            isValid = true;
            validQuestions++;
          } else {
            // Fallback: check isCorrect flags
            if (options != null) {
              int correctCount = 0;
              for (final option in options) {
                final optionMap = option as Map<String, dynamic>?;
                if (optionMap != null && optionMap['isCorrect'] == true) {
                  correctCount++;
                }
              }
              
              if (correctCount == 1) {
                isValid = true;
                validQuestions++;
                validationMessage = 'Has isCorrect flag but missing correctOptionIndex';
              } else if (correctCount == 0) {
                validationMessage = 'No correct answer found';
              } else {
                validationMessage = 'Multiple correct answers found: $correctCount';
              }
            } else {
              validationMessage = 'No options array found';
            }
          }
          
          if (!isValid) {
            invalidQuestions.add({
              'testId': testDoc.id,
              'testName': testDoc.data()['name'] ?? 'Unknown Test',
              'questionId': questionDoc.id,
              'questionText': data['text'] ?? 'Unknown Question',
              'issue': validationMessage,
              'correctOptionIndex': correctOptionIndex,
              'optionsCount': options?.length ?? 0,
            });
          }
        }
      }
      
      return {
        'totalQuestions': totalQuestions,
        'validQuestions': validQuestions,
        'invalidQuestions': invalidQuestions,
        'validationPercentage': totalQuestions > 0 
            ? (validQuestions / totalQuestions * 100).toStringAsFixed(1)
            : '0',
      };
    } catch (e) {
      print('Validation failed: $e');
      rethrow;
    }
  }
}
