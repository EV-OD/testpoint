# Firebase Firestore Data Structure

This document outlines the current data structure used in Firestore for the TestPoint application. This guide reflects the implemented system and is intended to help developers understand how data is stored and managed.

## Root Collections

The database consists of four primary root collections:

1. `users` - User profiles and authentication data
2. `groups` - Class/group management 
3. `tests` - Test definitions with questions subcollection
4. `test_sessions` - Individual student test-taking sessions

---

## 1. `users` Collection

This collection stores user profile information. The document ID for each user is their Firebase Authentication UID.

### Document Structure: `users/{userId}`

```json
{
  "name": "String",
  "email": "String", 
  "role": "String"
}
```

### Field Descriptions:

- **`name`**: (String) The full name of the user (e.g., "John Doe").
- **`email`**: (String) The user's email address. Unique identifier from Firebase Auth.
- **`role`**: (String) User permission level. Possible values:
  - `"admin"`: Full system access and management capabilities
  - `"teacher"`: Can create groups, tests, and view student results
  - `"student"`: Can take assigned tests and view results

### Implementation Status: ✅ COMPLETED
- User authentication via Firebase Auth
- Role-based access control implemented
- User profile management in place

---

## 2. `groups` Collection

This collection stores class/group information for organizing students and assigning tests.

### Document Structure: `groups/{groupId}`

```json
{
  "name": "String",
  "userIds": ["Array<String>"],
  "created_at": "Timestamp"
}
```

### Field Descriptions:

- **`name`**: (String) The name of the group (e.g., "Grade 10 Math Class", "Advanced Physics").
- **`userIds`**: (Array of Strings) List of Firebase Authentication UIDs of group members.
- **`created_at`**: (Timestamp) When the group was created.

### Implementation Status: ✅ COMPLETED
- Group creation and management
- Student assignment to groups
- Group-based test filtering
- Real-time group updates

### Required Firebase Indexes:
- Composite index for: `userIds (array-contains)` + `name (ascending)` + `__name__ (ascending)`

---

## 3. `tests` Collection

This collection stores test definitions created by teachers.

### Document Structure: `tests/{testId}`

```json
{
  "name": "String",
  "group_id": "String", 
  "time_limit": "Number",
  "question_count": "Number",
  "date_time": "Timestamp",
  "test_maker": "String",
  "created_at": "Timestamp",
  "status": "String"
}
```

### Field Descriptions:

- **`name`**: (String) Test title (e.g., "Final Exam - Algebra II").
- **`group_id`**: (String) Reference to `groups` collection document ID.
- **`time_limit`**: (Number) Test duration in minutes (5-300 range).
- **`question_count`**: (Number) Total questions in test (auto-calculated).
- **`date_time`**: (Timestamp) Scheduled test start date and time.
- **`test_maker`**: (String) Firebase UID of the teacher who created the test.
- **`created_at`**: (Timestamp) Test creation timestamp.
- **`status`**: (String) Test lifecycle status:
  - `"draft"`: Being created/edited, not visible to students
  - `"published"`: Available to students at scheduled time
  - `"completed"`: Past end time, results available

### Test Lifecycle: ✅ IMPLEMENTED
1. **Draft**: Teacher creates and edits test freely
2. **Published**: Test becomes available to assigned students
3. **Completed**: Automatic transition after time limit expires

### Implementation Status: ✅ COMPLETED
- Multi-step test creation wizard
- Test editing and publishing
- Real-time test management
- Group-based test assignment

### Subcollections

#### `questions` Subcollection: ✅ IMPLEMENTED

Each test document contains a `questions` subcollection with MCQ data.

##### Document Structure: `tests/{testId}/questions/{questionId}`

```json
{
  "text": "String",
  "options": [
    {
      "id": "String", 
      "text": "String",
      "isCorrect": "Boolean"
    }
  ],
  "created_at": "Timestamp"
}
```

##### Field Descriptions:

- **`text`**: (String) Question text (10-500 characters).
- **`options`**: (Array of Objects) Four answer choices:
  - **`id`**: (String) Unique option identifier
  - **`text`**: (String) Answer option text
  - **`isCorrect`**: (Boolean) True for correct answer (exactly one per question)
- **`created_at`**: (Timestamp) Question creation time

##### Implementation Features:
- Question creation and editing interface
- Validation for unique options and single correct answer
- Real-time question management
- Question preview with answer highlighting

---

## 4. `test_sessions` Collection

This collection tracks individual student test-taking sessions with comprehensive monitoring.

### Document Structure: `test_sessions/{sessionId}`

```json
{
  "test_id": "String",
  "student_id": "String", 
  "start_time": "Timestamp",
  "end_time": "Timestamp",
  "time_limit": "Number",
  "answers": {
    "questionId1": {
      "selected_answer_index": "Number",
      "answered_at": "Timestamp", 
      "is_correct": "Boolean"
    }
  },
  "question_order": ["Array<String>"],
  "status": "String",
  "violations": [
    {
      "id": "String",
      "timestamp": "Timestamp", 
      "type": "String",
      "description": "String",
      "metadata": "Object"
    }
  ],
  "final_score": "Number",
  "created_at": "Timestamp"
}
```

### Field Descriptions:

- **`test_id`**: (String) Reference to parent test document
- **`student_id`**: (String) Firebase UID of test taker
- **`start_time`**: (Timestamp) Test session start time
- **`end_time`**: (Timestamp) Test completion/submission time
- **`time_limit`**: (Number) Session time limit in minutes
- **`answers`**: (Object) Student responses mapped by question ID
- **`question_order`**: (Array) Randomized question sequence for this session
- **`status`**: (String) Session state:
  - `"not_started"`: Session created but not begun
  - `"in_progress"`: Student actively taking test
  - `"completed"`: Test finished normally
  - `"submitted"`: Manual submission by student
  - `"violation_submitted"`: Auto-submitted due to violations
- **`violations`**: (Array) Anti-cheat violations detected
- **`final_score`**: (Number) Calculated score percentage (0-100)
- **`created_at`**: (Timestamp) Session creation time

### Implementation Status: 🚧 PARTIAL
- ✅ Basic models and structure defined
- ✅ Test-taking interface with timer
- ✅ Answer collection and scoring
- ✅ Basic anti-cheat monitoring (app switches)
- ⏳ Firebase persistence layer
- ⏳ Session recovery and offline support
- ⏳ Comprehensive violation tracking

---

## Implementation Overview

### ✅ Completed Features

#### Teacher Dashboard & Test Management
- Multi-step test creation wizard with validation
- Test editing and publishing workflow  
- Real-time test list with status filtering
- Question management with preview
- Group-based test assignment
- Beautiful Material 3 UI with dark mode

#### Student Test-Taking System
- Test instructions and readiness confirmation
- Single-question interface with navigation
- Timer with visual warnings
- Answer selection and progress tracking
- Automatic scoring and results display
- Basic anti-cheat monitoring (app switches)

#### Firebase Integration
- User authentication and role management
- Real-time data synchronization
- Group management with user assignment
- Test and question CRUD operations
- Proper security rules implementation

### 🚧 In Progress

#### Test Session Persistence
- Basic models implemented
- Firebase repository layer needed
- Real-time answer saving
- Session recovery after app crashes

#### Enhanced Anti-Cheat System
- App lifecycle monitoring implemented
- Platform-specific features (screen pinning) needed
- Advanced violation detection
- Violation reporting for teachers

### ⏳ Planned Features

#### Advanced Timer System
- Background timer persistence
- Server-side time validation
- Automatic submission on timeout
- Time synchronization

#### Comprehensive Analytics
- Student performance tracking
- Test difficulty analysis
- Detailed violation reporting
- Export functionality

---

## Firebase Security Rules

### Current Implementation Status: ✅ BASIC RULES

```javascript
// Basic security rules implemented
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Teachers can manage tests they created
    match /tests/{testId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource == null || resource.data.test_maker == request.auth.uid);
    }
    
    // Questions are managed by test creators
    match /tests/{testId}/questions/{questionId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/tests/$(testId)).data.test_maker == request.auth.uid;
    }
    
    // Groups are readable by all authenticated users
    match /groups/{groupId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null; // TODO: Restrict to admins/teachers
    }
    
    // Test sessions managed by students
    match /test_sessions/{sessionId} {
      allow read, write: if request.auth != null && 
        resource.data.student_id == request.auth.uid;
    }
  }
}
```

---

## Required Firebase Indexes

### Composite Indexes Created:
1. **groups collection**: 
   - Fields: `userIds` (array-contains), `name` (ascending)
   - Purpose: Student group membership queries

### Single Field Indexes (Auto-created):
- `tests.test_maker` - Filter tests by creator
- `tests.group_id` - Filter tests by group
- `tests.status` - Filter by test status
- `tests.date_time` - Sort by scheduled time
- `groups.userIds` - Group membership queries

---

## Development Status Summary

| Feature | Status | Implementation |
|---------|--------|----------------|
| User Authentication | ✅ Complete | Firebase Auth + role-based access |
| Group Management | ✅ Complete | CRUD with real-time updates |
| Test Creation | ✅ Complete | Multi-step wizard with validation |
| Question Management | ✅ Complete | MCQ with preview and editing |
| Test Taking Interface | ✅ Complete | Student-facing test experience |
| Results & Scoring | ✅ Complete | Automatic calculation and display |
| Basic Anti-Cheat | ✅ Complete | App switch detection |
| Test Session Persistence | 🚧 Partial | Models ready, Firebase integration needed |
| Advanced Anti-Cheat | 🚧 Partial | Platform-specific features pending |
| Analytics Dashboard | ⏳ Planned | Teacher insights and reporting |
| Offline Support | ⏳ Planned | Answer caching and sync |

The current implementation provides a complete end-to-end test creation and taking experience with real-time Firebase integration. The foundation is solid for adding advanced features like comprehensive anti-cheat systems, detailed analytics, and offline support.