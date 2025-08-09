# Test Taking Interface Design

## Overview

The Test Taking Interface is a secure, user-friendly system that enables students to take MCQ tests with proper timing, anti-cheating measures, and automatic scoring. The design emphasizes security, usability, and academic integrity while providing a smooth testing experience. The system integrates with the existing Flutter architecture and includes platform-specific anti-cheating features.

## Architecture

### State Management
- **TestTakingProvider**: Manages test session state, answers, timing, and anti-cheating
- **TestSessionRepository**: Handles test session data and answer persistence
- **AntiCheatService**: Monitors app state and implements security measures
- **TimerService**: Manages test countdown and automatic submission

### Navigation Flow
```
Student Dashboard → Take Test → Test Instructions → Test Session
├── Question Navigation (1 per screen)
├── Answer Review (optional)
├── Final Submission
└── Results Display
```

### Security Architecture
- App lifecycle monitoring for switch detection
- Screen pinning implementation (Android)
- Kiosk mode considerations (iOS)
- Violation logging and automatic submission
- Secure answer storage during test session

## Components and Interfaces

### Core Models

#### TestSession Model (Firebase Document)
```dart
class TestSession {
  final String id; // Firebase document ID
  final String testId; // Reference to tests collection
  final String studentId; // Firebase Auth UID
  final DateTime startTime;
  final DateTime? endTime;
  final int timeLimit; // copied from test for consistency
  final Map<String, StudentAnswer> answers; // questionId -> answer
  final List<String> questionOrder; // randomized question IDs
  final TestSessionStatus status;
  final List<AntiCheatViolation> violations;
  final int? finalScore;
  final DateTime createdAt;
  
  // Additional local fields populated from Firebase
  final Test? test; // Populated from testId (includes test_maker)
  final List<Question>? questions; // Loaded from test subcollection
  final User? testCreator; // Populated from test.testMaker for display purposes
}

enum TestSessionStatus {
  notStarted,
  inProgress,
  completed,
  submitted,
  violationSubmitted
}
```

#### StudentAnswer Model
```dart
class StudentAnswer {
  final String questionId;
  final int? selectedAnswerIndex; // null if not answered
  final DateTime? answeredAt;
  final bool isCorrect; // calculated after submission
}
```

#### AntiCheatViolation Model
```dart
class AntiCheatViolation {
  final String id;
  final DateTime timestamp;
  final AntiCheatViolationType type;
  final String description;
  final Map<String, dynamic> metadata;
}

enum AntiCheatViolationType {
  appSwitch,
  screenPinningDisabled,
  suspiciousActivity,
  timeManipulation
}
```

### Screen Components

#### TestInstructionsScreen
- Test overview and rules display
- Duration and question count information
- Anti-cheating warnings and requirements
- Readiness confirmation dialog
- Screen pinning activation

#### TestTakingScreen
- Single question display with four options
- Timer display with visual warnings
- Progress indicator and question counter
- Navigation controls (Previous/Next/Submit)
- Anti-cheat monitoring overlay

#### TestReviewScreen
- All questions and answers overview
- Unanswered question highlighting
- Navigation to specific questions
- Final submission confirmation
- Time remaining display

#### TestResultsScreen
- Score display with percentage
- Correct/incorrect answer breakdown
- Time taken and completion statistics
- Answer review with correct solutions
- Return to dashboard navigation

### Service Layer

#### TestTakingService
```dart
class TestTakingService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  
  Future<TestSession> startTestSession(String testId, String studentId);
  Future<void> saveAnswer(String sessionId, String questionId, int answerIndex);
  Future<TestSession> submitTest(String sessionId);
  Future<int> calculateScore(TestSession session);
  Future<List<Test>> getAvailableTests(String studentId);
  Future<List<Test>> getCompletedTests(String studentId);
  Future<bool> hasStudentTakenTest(String testId, String studentId);
  List<Question> randomizeQuestions(List<Question> questions);
  bool isTestAvailable(Test test);
}
```

#### AntiCheatService
```dart
class AntiCheatService {
  Stream<AppLifecycleState> get appStateStream;
  Future<bool> enableScreenPinning();
  Future<void> disableScreenPinning();
  void startMonitoring(String sessionId);
  void stopMonitoring();
  Future<void> logViolation(AntiCheatViolation violation);
  Future<void> triggerViolationSubmission(String sessionId);
}
```

#### TimerService
```dart
class TimerService {
  Stream<Duration> startTimer(Duration duration);
  void pauseTimer();
  void resumeTimer();
  void stopTimer();
  Duration get remainingTime;
  bool get isExpired;
}
```

### Provider Architecture

#### TestTakingProvider
```dart
class TestTakingProvider extends ChangeNotifier {
  // State variables
  TestSession? _currentSession;
  int _currentQuestionIndex;
  Duration _remainingTime;
  bool _isSubmitting;
  bool _antiCheatEnabled;
  List<AntiCheatViolation> _violations;
  
  // Navigation and answers
  void selectAnswer(int answerIndex);
  void nextQuestion();
  void previousQuestion();
  void goToQuestion(int index);
  
  // Test management
  Future<void> startTest(String testId);
  Future<void> submitTest();
  Future<void> handleViolation(AntiCheatViolation violation);
  
  // Timer management
  void startTimer();
  void handleTimeExpired();
}
```

## Data Models

### Firebase Test Session Document Structure
```json
{
  "test_id": "test_uuid",
  "student_id": "student_firebase_uid",
  "start_time": "2024-02-15T10:00:00Z",
  "end_time": "2024-02-15T11:00:00Z",
  "time_limit": 60,
  "answers": {
    "question_id_1": {
      "selected_answer_index": 1,
      "answered_at": "2024-02-15T10:05:00Z",
      "is_correct": true
    },
    "question_id_2": {
      "selected_answer_index": 2,
      "answered_at": "2024-02-15T10:08:00Z",
      "is_correct": false
    }
  },
  "question_order": ["question_id_1", "question_id_2", "question_id_3"],
  "status": "completed",
  "violations": [
    {
      "id": "violation_1",
      "timestamp": "2024-02-15T10:10:00Z",
      "type": "app_switch",
      "description": "Student switched to calculator app",
      "metadata": {
        "duration": 5000,
        "app_name": "Calculator"
      }
    }
  ],
  "final_score": 85,
  "created_at": "2024-02-15T10:00:00Z"
}
```

### Answer Validation
- Answer selection validation (0-3 range)
- Question existence verification
- Session state consistency checks
- Time boundary validation

## Error Handling

### Network Errors
- Offline answer caching with sync on reconnection
- Retry mechanisms for submission failures
- Local storage backup for critical data
- Connection status monitoring

### Anti-Cheat Violations
- Immediate test submission on violation
- Violation logging with detailed metadata
- Teacher notification system
- Student warning and explanation

### Timer Issues
- System time validation
- Background timer continuation
- Time synchronization with server
- Graceful handling of time discrepancies

### Session Recovery
- Auto-save functionality for answers
- Session restoration after app crashes
- Progress preservation during interruptions
- Data integrity validation

## Testing Strategy

### Unit Tests
- Answer selection and validation logic
- Timer functionality and expiration handling
- Score calculation algorithms
- Anti-cheat detection mechanisms

### Widget Tests
- Question navigation and display
- Answer selection interactions
- Timer display and warnings
- Review screen functionality

### Integration Tests
- Complete test-taking workflow
- Anti-cheat system integration
- Timer and auto-submission
- Results calculation and display

### Security Tests
- App switch detection accuracy
- Screen pinning effectiveness
- Violation logging completeness
- Data encryption and storage

## Security Considerations

### Anti-Cheating Measures
- App lifecycle monitoring with immediate detection
- Screen recording prevention (where supported)
- Screenshot blocking during test sessions
- Network activity monitoring for suspicious behavior

### Data Protection
- Encrypted local storage for test data
- Secure transmission of answers and results
- Session token validation
- Answer tampering prevention

### Platform-Specific Features
- Android: Screen pinning, app usage monitoring
- iOS: Guided Access mode recommendations
- Web: Focus monitoring and visibility API
- Desktop: Window focus detection

## Performance Optimization

### Memory Management
- Efficient question loading and caching
- Answer state optimization
- Timer resource management
- Background task cleanup

### Battery Optimization
- Efficient anti-cheat monitoring
- Optimized timer implementation
- Minimal background processing
- Screen brightness management

### Network Efficiency
- Batch answer synchronization
- Compressed data transmission
- Offline capability with sync
- Minimal API calls during test

## Accessibility Features

### Screen Reader Support
- Question and option announcements
- Timer status announcements
- Navigation assistance
- Answer confirmation feedback

### Visual Accessibility
- High contrast mode support
- Font size scaling
- Color-blind friendly design
- Clear visual indicators

### Motor Accessibility
- Large touch targets
- Alternative input methods
- Voice control compatibility
- Gesture customization