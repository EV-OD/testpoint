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
  "created_at": "Timestamp"
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