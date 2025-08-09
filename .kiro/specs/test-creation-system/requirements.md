# Requirements Document

## Introduction

The Test Creation System enables teachers to create, manage, and configure multiple-choice question (MCQ) tests for students. This system provides a comprehensive interface for test creation, question management, scheduling, and preview functionality. Teachers can create tests with customizable settings including time limits, question randomization, and group assignments.

## Requirements

### Requirement 1

**User Story:** As a teacher, I want to create a new test with basic information, so that I can set up the test structure and configuration.

#### Acceptance Criteria

1. WHEN a teacher clicks the "Create Test" floating action button THEN the system SHALL display a test creation form
2. WHEN a teacher fills in test name, group selection, time limit, and scheduled date/time THEN the system SHALL validate all required fields
3. WHEN a teacher selects a group THEN the system SHALL load available groups from Firebase where the teacher has access
4. WHEN a teacher submits valid test information THEN the system SHALL create a new test document in Firebase and navigate to question creation
5. IF any required field is empty THEN the system SHALL display appropriate validation errors
6. WHEN a teacher sets a time limit THEN the system SHALL accept values between 5 and 300 minutes

### Requirement 2

**User Story:** As a teacher, I want to add multiple-choice questions to my test, so that students can answer them during the exam.

#### Acceptance Criteria

1. WHEN a teacher is in question creation mode THEN the system SHALL display a form to add MCQ questions
2. WHEN a teacher enters a question text and 4 answer options THEN the system SHALL validate that all fields are filled
3. WHEN a teacher selects the correct answer option THEN the system SHALL mark it with isCorrect: true
4. WHEN a teacher saves a question THEN the system SHALL add it to the questions subcollection in Firebase and update question_count
5. WHEN a teacher tries to save a test THEN the system SHALL require at least 1 question to be added
6. WHEN a teacher adds questions THEN the system SHALL display a running count synchronized with Firebase question_count field

### Requirement 3

**User Story:** As a teacher, I want to preview my test before publishing, so that I can verify the content and format are correct.

#### Acceptance Criteria

1. WHEN a teacher clicks "Preview Test" THEN the system SHALL display the test in student view format
2. WHEN previewing a test THEN the system SHALL show questions in the same randomized order students will see
3. WHEN in preview mode THEN the system SHALL display all questions with their answer options
4. WHEN in preview mode THEN the system SHALL highlight correct answers for teacher reference
5. WHEN a teacher finishes previewing THEN the system SHALL provide options to edit or publish the test

### Requirement 4

**User Story:** As a teacher, I want to edit existing unpublished tests, so that I can make corrections and improvements before students take them.

#### Acceptance Criteria

1. WHEN a teacher views pending tests THEN the system SHALL display an "Edit" option for unpublished tests
2. WHEN a teacher clicks "Edit" on a test THEN the system SHALL open the test in edit mode
3. WHEN editing a test THEN the system SHALL allow modification of test details and questions
4. WHEN a teacher modifies questions THEN the system SHALL save changes and update the test
5. WHEN a test has been taken by students THEN the system SHALL NOT allow editing
6. WHEN editing a test THEN the system SHALL preserve the original creation date

### Requirement 5

**User Story:** As a teacher, I want to manage my test library, so that I can organize and reuse test content efficiently.

#### Acceptance Criteria

1. WHEN a teacher views their dashboard THEN the system SHALL display only tests where they are the test_maker in organized tabs
2. WHEN viewing pending tests THEN the system SHALL show tests that haven't been completed yet, filtered by test_maker field
3. WHEN viewing completed tests THEN the system SHALL show tests that have finished and display results summary for tests they created
4. WHEN a teacher searches tests THEN the system SHALL filter tests by name, group, or date within their own created tests
5. WHEN a teacher deletes a test THEN the system SHALL require confirmation and only allow deletion of tests where they are the test_maker and test is unpublished

### Requirement 6

**User Story:** As a teacher, I want to ensure test ownership is properly tracked, so that only I can edit my tests and access is controlled appropriately.

#### Acceptance Criteria

1. WHEN a teacher creates a test THEN the system SHALL automatically set the test_maker field to their Firebase Auth UID
2. WHEN a teacher attempts to edit a test THEN the system SHALL verify they are the test_maker before allowing modifications
3. WHEN displaying test lists THEN the system SHALL show the creator's name populated from the test_maker field
4. WHEN a teacher tries to access another teacher's test THEN the system SHALL deny access and display appropriate error message
5. WHEN an admin views tests THEN the system SHALL display all tests regardless of test_maker for administrative purposes