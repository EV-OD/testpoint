# Test Creation System Design

## Overview

The Test Creation System is a comprehensive Flutter-based solution that enables teachers to create, manage, and configure MCQ tests. The system follows the existing app architecture using Provider for state management, Go Router for navigation, and Material 3 design principles. The design emphasizes user experience with intuitive workflows, proper validation, and seamless integration with the existing teacher dashboard.

## Architecture

### State Management
- **TestProvider**: Manages test creation state, question lists, and form validation
- **TestRepository**: Handles data persistence and retrieval operations
- **TestService**: Provides business logic for test operations and validation

### Navigation Flow
```
Teacher Dashboard → Create Test FAB → Test Creation Wizard
├── Step 1: Basic Test Information
├── Step 2: Question Creation
├── Step 3: Test Preview
└── Step 4: Publish/Save
```

### Data Flow
1. User interactions trigger Provider methods
2. Provider validates input and updates UI state
3. Repository handles data persistence
4. Service layer manages business rules and validation

## Components and Interfaces

### Core Models

#### Test Model (Firebase Document)
```dart
class Test {
  final String id; // Firebase document ID
  final String name;
  final String groupId; // Reference to groups collection
  final int timeLimit; // in minutes
  final int questionCount; // auto-updated by Firebase
  final DateTime dateTime; // scheduled date/time
  final String testMaker; // Firebase Auth UID of teacher who created the test
  final DateTime createdAt;
  
  // Additional local fields
  final Group? group; // Populated from groupId
  final List<Question>? questions; // Loaded from subcollection
  final bool isPublished; // Derived from dateTime vs current time
  final User? creator; // Populated from testMaker UID
}
```

#### Question Model (Firebase Subcollection Document)
```dart
class Question {
  final String id; // Firebase document ID
  final String text;
  final List<QuestionOption> options; // 4 options
  final DateTime createdAt;
}

class QuestionOption {
  final String id;
  final String text;
  final bool isCorrect; // Only one should be true
}
```

#### Group Model (Firebase Document)
```dart
class Group {
  final String id; // Firebase document ID
  final String name;
  final List<String> userIds; // Firebase Auth UIDs
  final DateTime createdAt;
  
  // Additional local fields
  final List<User>? members; // Populated from userIds
}
```

### Screen Components

#### CreateTestScreen
- Multi-step wizard interface using PageView
- Form validation with real-time feedback
- Progress indicator showing current step
- Navigation controls (Next, Previous, Save Draft)

#### TestBasicInfoStep
- Test name input field
- Group/class selection dropdown
- Duration picker (5-300 minutes)
- Scheduled date/time picker
- Form validation with error messages

#### QuestionCreationStep
- Question text input (multiline)
- Four answer option inputs
- Correct answer selection (radio buttons)
- Question counter and navigation
- Add/Remove question functionality
- Question list preview

#### TestPreviewStep
- Read-only test display in student format
- Question randomization preview
- Correct answer highlighting for teacher
- Edit/Publish action buttons
- Test summary information

### Service Layer

#### TestService
```dart
class TestService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  
  Future<Test> createTest(Test test);
  Future<Test> updateTest(Test test);
  Future<void> deleteTest(String testId);
  Future<List<Test>> getTestsByTeacher(String teacherId);
  Future<List<Test>> getTestsByGroup(String groupId);
  Future<Test?> getTestById(String testId);
  Future<List<Group>> getAvailableGroups(String teacherId);
  Future<bool> validateTestOwnership(String testId, String teacherId);
  Future<bool> canEditTest(String testId, String teacherId);
  Future<bool> canDeleteTest(String testId, String teacherId);
  bool validateTest(Test test);
  List<Question> randomizeQuestions(List<Question> questions);
}
```

#### TestRepository (Firebase Integration)
```dart
class TestRepository {
  final FirebaseFirestore _firestore;
  
  // Test CRUD operations
  Future<String> createTest(Test test);
  Future<void> updateTest(Test test);
  Future<Test?> getTest(String testId);
  Future<List<Test>> getTestsByCreator(String creatorId);
  Future<void> deleteTest(String testId);
  
  // Question CRUD operations
  Future<String> addQuestion(String testId, Question question);
  Future<void> updateQuestion(String testId, String questionId, Question question);
  Future<void> deleteQuestion(String testId, String questionId);
  Future<List<Question>> getQuestions(String testId);
  
  // Group operations
  Future<List<Group>> getGroups();
  Future<Group?> getGroup(String groupId);
}
```

#### GroupService
```dart
class GroupService {
  final FirebaseFirestore _firestore;
  
  Future<List<Group>> getAvailableGroups(String teacherId);
  Future<Group?> getGroupById(String groupId);
  Future<List<User>> getGroupMembers(String groupId);
}
```

### Provider Architecture

#### TestProvider
```dart
class TestProvider extends ChangeNotifier {
  // State variables
  Test? _currentTest;
  List<Question> _questions;
  int _currentStep;
  bool _isLoading;
  String? _errorMessage;
  
  // Form controllers and validation
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final groupController = TextEditingController();
  
  // Methods
  void createNewTest();
  void addQuestion(Question question);
  void removeQuestion(int index);
  void updateQuestion(int index, Question question);
  Future<bool> saveTest();
  Future<bool> publishTest();
  void nextStep();
  void previousStep();
  bool validateCurrentStep();
}
```

## Data Models

### Firebase Test Document Structure
```json
{
  "name": "Final Exam - Algebra II",
  "group_id": "group_uuid",
  "time_limit": 60,
  "question_count": 25,
  "date_time": "2024-02-15T10:00:00Z",
  "test_maker": "teacher_firebase_uid",
  "created_at": "2024-02-01T09:00:00Z"
}
```

### Firebase Question Subcollection Structure
```json
{
  "text": "What is the solution to 2x + 5 = 15?",
  "options": [
    {
      "id": "opt1",
      "text": "x = 5",
      "isCorrect": true
    },
    {
      "id": "opt2", 
      "text": "x = 10",
      "isCorrect": false
    },
    {
      "id": "opt3",
      "text": "x = 7.5",
      "isCorrect": false
    },
    {
      "id": "opt4",
      "text": "x = 2.5",
      "isCorrect": false
    }
  ],
  "created_at": "2024-02-01T09:15:00Z"
}
```

### Firebase Group Document Structure
```json
{
  "name": "Grade 10 Math Class",
  "userIds": ["student_uid1", "student_uid2", "student_uid3"],
  "created_at": "2024-01-15T08:00:00Z"
}
```

### Question Validation Rules
- Question text: 10-500 characters
- Each option: 1-100 characters
- All 4 options must be unique
- Exactly one correct answer required
- Minimum 1 question per test

## Error Handling

### Validation Errors
- Real-time form validation with immediate feedback
- Step-by-step validation before navigation
- Comprehensive error messages for user guidance
- Visual indicators for invalid fields

### Network Errors
- Retry mechanisms for failed operations
- Offline capability with local storage
- User-friendly error messages
- Loading states during operations

### Data Integrity
- Duplicate question detection
- Test name uniqueness validation
- Scheduled date validation (future dates only)
- Question order consistency

## Testing Strategy

### Unit Tests
- Test model validation logic
- Provider state management
- Service layer business rules
- Repository data operations

### Widget Tests
- Form validation behavior
- Step navigation functionality
- Question creation workflow
- Preview screen rendering

### Integration Tests
- Complete test creation flow
- Data persistence verification
- Navigation between screens
- Error handling scenarios

### Test Data
- Mock test objects for development
- Validation test cases
- Edge case scenarios
- Performance test data sets

## UI/UX Considerations

### Design Principles
- Consistent with existing Material 3 theme
- Intuitive step-by-step workflow
- Clear visual hierarchy and feedback
- Responsive design for different screen sizes

### Accessibility
- Screen reader support
- Keyboard navigation
- High contrast mode compatibility
- Font scaling support

### Performance
- Lazy loading of test data
- Efficient question list rendering
- Optimized form validation
- Memory management for large tests

### User Experience
- Auto-save functionality for drafts
- Confirmation dialogs for destructive actions
- Progress indicators for long operations
- Contextual help and tooltips