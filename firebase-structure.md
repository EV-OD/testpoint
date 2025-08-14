# Firebase Firestore Data Structure

This document outlines the data structure used in Firestore for the TestPoint application. This guide is intended to help backend and mobile (Android) developers understand how data is stored and managed.

## Root Collections

The database consists of three primary root collections:

1.  `users`
2.  `groups`
3.  `tests`

---

## 1. `users` Collection

This collection stores information about individual users. The document ID for each user is their Firebase Authentication UID.

### Document Structure: `users/{userId}`

```json
{
  "name": "String",
  "email": "String",
  "role": "String"
}
```

### Field Descriptions:

-   **`name`**: (String) The full name of the user (e.g., "John Doe").
-   **`email`**: (String) The user's email address. This is unique for each user.
-   **`role`**: (String) Defines the user's permissions and role in the system. Can be one of the following values:
    -   `"admin"`: Has full access to the admin dashboard.
    -   `"teacher"`: Can create and manage groups and tests.
    -   `"student"`: Can take tests they are assigned to.

**Note on Firebase Authentication:**
User identity (UID, email, display name) is managed by Firebase Authentication. The `users` collection in Firestore stores additional app-specific metadata like the `role`.

---

## 2. `groups` Collection

This collection stores groups of users, typically created by teachers or admins to assign tests to a specific set of students.

### Document Structure: `groups/{groupId}`

```json
{
  "name": "String",
  "userIds": ["Array<String>"],
  "created_at": "Timestamp"
}
```

### Field Descriptions:

-   **`name`**: (String) The name of the group (e.g., "Grade 10 Math Class").
-   **`userIds`**: (Array of Strings) A list of Firebase Authentication UIDs of the users who are members of this group.
-   **`created_at`**: (Timestamp) The date and time the group was created.

---

## 3. `tests` Collection

This collection stores all the tests created by teachers or admins.

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

-   **`name`**: (String) The name of the test (e.g., "Final Exam - Algebra II").
-   **`group_id`**: (String) The ID of the group from the `groups` collection that this test is assigned to.
-   **`time_limit`**: (Number) The duration of the test in minutes.
-   **`question_count`**: (Number) The total number of questions in the test. This is updated via server-side logic when questions are added or removed.
-   **`date_time`**: (Timestamp) The scheduled start date and time for the test.
-   **`test_maker`**: (String) The Firebase Authentication UID of the teacher who created this test.
-   **`created_at`**: (Timestamp) The date and time the test was created.
-   **`status`**: (String) The current status of the test. Can be one of the following values:
    -   `"draft"`: Test is being created/edited and not yet available to students.
    -   `"published"`: Test is published and available to students at the scheduled time.
    -   `"completed"`: Test has finished and is no longer available for taking.

### Test Status Workflow

Tests follow a specific lifecycle managed by the `status` field:

1. **Draft Phase** (`status: "draft"`)
   - Test is being created or edited by the teacher
   - Not visible to students
   - Can be modified, deleted, or published
   - Must have at least one question to be published

2. **Published Phase** (`status: "published"`)
   - Test is available to students at the scheduled `date_time`
   - Cannot be deleted
   - Can be restored to draft status if the test hasn't started yet
   - Automatically becomes available when `date_time` is reached

3. **Completed Phase** (`status: "completed"`)
   - Test has finished (past `date_time` + `time_limit`)
   - Read-only for viewing results and analytics
   - Cannot be modified or deleted

### Subcollections

#### `questions` Subcollection

Each document in the `tests` collection has a subcollection named `questions`.

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

-   **`text`**: (String) The question text itself.
-   **`options`**: (Array of Objects) A list of possible answers for the question.
    -   **`id`**: (String) A unique identifier for the option.
    -   **`text`**: (String) The text for the answer option.
    -   **`isCorrect`**: (Boolean) `true` if this is the correct answer, otherwise `false`. Only one option should be correct.
-   **`created_at`**: (Timestamp) The date and time the question was created.

---

## 4. `test_sessions` Collection

This collection stores individual test-taking sessions when students take tests.

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

-   **`test_id`**: (String) Reference to the test document ID from the `tests` collection.
-   **`student_id`**: (String) Firebase Authentication UID of the student taking the test.
-   **`start_time`**: (Timestamp) When the student started the test.
-   **`end_time`**: (Timestamp) When the student completed/submitted the test.
-   **`time_limit`**: (Number) Duration of the test in minutes (copied from test for consistency).
-   **`answers`**: (Object) Map of question IDs to student answers.
-   **`question_order`**: (Array of Strings) Randomized order of question IDs for this session.
-   **`status`**: (String) Current status of the test session: `"in_progress"`, `"completed"`, `"submitted"`, `"violation_submitted"`.
-   **`violations`**: (Array of Objects) List of anti-cheating violations detected during the session.
-   **`final_score`**: (Number) Calculated score as a percentage (0-100).
-   **`created_at`**: (Timestamp) When the test session was created.

---

## Teacher Dashboard Features

The teacher dashboard provides comprehensive test management capabilities organized by test status:

### Dashboard Tabs

1. **Drafts Tab**
   - Shows all tests with `status: "draft"`
   - Actions available: Edit, Publish (if questions exist), Delete
   - Tests can be freely modified and deleted

2. **Published Tab**
   - Shows all tests with `status: "published"`
   - Actions available: View Details, Restore to Draft (if not started)
   - Tests become read-only once students can access them

3. **Completed Tab**
   - Shows all tests with `status: "completed"`
   - Actions available: View Results, Analytics
   - All tests are read-only for historical reference

### Real-time Updates

The dashboard uses Firebase real-time listeners to automatically update when:
- New tests are created
- Test status changes
- Tests are deleted or modified
- Questions are added/removed

### Firebase Indexes

The following single-field indexes are automatically created by Firebase:
- `tests.test_maker` (for filtering by teacher)
- `tests.group_id` (for filtering by group)
- `tests.status` (for filtering by status)
- `tests.created_at` (for sorting)
- `tests.date_time` (for sorting)

**Note**: Composite indexes are avoided by sorting results in memory rather than in the database query to prevent index requirements that would need manual creation in the Firebase Console.

### Test Management Actions

- **Create Test**: Starts a new test in draft status
- **Edit Test**: Modify test details and questions (only available for drafts)
- **Publish Test**: Change status from draft to published (requires at least one question)
- **Delete Test**: Remove test completely (only available for drafts)
- **Restore to Draft**: Change published test back to draft status (only if test hasn't started)
- **View Details**: See test information and student results