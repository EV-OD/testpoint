# Requirements Document

## Introduction

The Test Taking Interface provides students with a comprehensive system to take MCQ tests created by teachers. This system includes proper timing mechanisms, question randomization, anti-cheating features, and automatic submission capabilities. The interface ensures a secure and user-friendly testing environment that maintains academic integrity while providing a smooth testing experience.

## Requirements

### Requirement 1

**User Story:** As a student, I want to start a test from my dashboard, so that I can take scheduled exams when they are available.

#### Acceptance Criteria

1. WHEN a student views pending tests THEN the system SHALL query Firebase for tests assigned to their groups and display available tests with "Take Test" buttons
2. WHEN a student clicks "Take Test" THEN the system SHALL verify the test is within the scheduled time window using the date_time field from Firebase
3. WHEN a test is not yet available THEN the system SHALL display the scheduled start time from Firebase date_time field
4. WHEN a test has expired THEN the system SHALL disable the "Take Test" button and show "Expired" status
5. WHEN a student has already submitted a test THEN the system SHALL check Firebase test sessions and prevent retaking, showing "Completed" status

### Requirement 2

**User Story:** As a student, I want to see test instructions and confirm my readiness, so that I understand the test format and rules before starting.

#### Acceptance Criteria

1. WHEN a student starts a test THEN the system SHALL display test instructions and rules
2. WHEN showing instructions THEN the system SHALL display test duration, number of questions, and anti-cheating warnings
3. WHEN a student confirms readiness THEN the system SHALL start the test timer and navigate to the first question
4. WHEN a student cancels from instructions THEN the system SHALL return to the dashboard without starting the test
5. WHEN displaying instructions THEN the system SHALL require explicit confirmation before proceeding

### Requirement 3

**User Story:** As a student, I want to answer questions one at a time with clear navigation, so that I can focus on each question individually.

#### Acceptance Criteria

1. WHEN a test starts THEN the system SHALL display questions in randomized order
2. WHEN displaying a question THEN the system SHALL show one question per screen with four answer options
3. WHEN a student selects an answer THEN the system SHALL highlight the selected option and enable navigation
4. WHEN a student navigates between questions THEN the system SHALL preserve previously selected answers
5. WHEN on the last question THEN the system SHALL display a "Submit Test" button instead of "Next"
6. WHEN not on the last question THEN the system SHALL show "Next" and "Previous" buttons

### Requirement 4

**User Story:** As a student, I want to see a timer and question progress, so that I can manage my time effectively during the test.

#### Acceptance Criteria

1. WHEN taking a test THEN the system SHALL display a countdown timer showing remaining time
2. WHEN the timer shows less than 5 minutes THEN the system SHALL highlight the timer in warning colors
3. WHEN the timer reaches zero THEN the system SHALL automatically submit the test
4. WHEN taking a test THEN the system SHALL display current question number and total questions
5. WHEN taking a test THEN the system SHALL show a progress bar indicating completion percentage

### Requirement 5

**User Story:** As a student, I want the system to prevent cheating attempts, so that the test maintains academic integrity.

#### Acceptance Criteria

1. WHEN a student switches away from the test app THEN the system SHALL detect the app switch and trigger anti-cheating measures
2. WHEN anti-cheating is triggered THEN the system SHALL automatically submit the test and record the violation
3. WHEN a test starts THEN the system SHALL enable screen pinning to prevent navigation away from the app
4. WHEN screen pinning fails THEN the system SHALL display a warning and prevent test continuation
5. WHEN anti-cheating is triggered THEN the system SHALL log the incident with timestamp and reason

### Requirement 6

**User Story:** As a student, I want to review my answers before final submission, so that I can make any necessary changes.

#### Acceptance Criteria

1. WHEN a student reaches the last question THEN the system SHALL provide an option to review all answers
2. WHEN in review mode THEN the system SHALL display all questions with selected answers
3. WHEN reviewing answers THEN the system SHALL allow navigation to any question for changes
4. WHEN in review mode THEN the system SHALL show unanswered questions clearly marked
5. WHEN ready to submit THEN the system SHALL require final confirmation before submission

### Requirement 7

**User Story:** As a student, I want to see my test results immediately after submission, so that I can understand my performance.

#### Acceptance Criteria

1. WHEN a test is submitted THEN the system SHALL calculate the score automatically
2. WHEN displaying results THEN the system SHALL show total score, percentage, and time taken
3. WHEN showing results THEN the system SHALL display correct and incorrect answers for review
4. WHEN viewing results THEN the system SHALL show the correct answer for each question
5. WHEN results are displayed THEN the system SHALL save the results to the student's completed tests