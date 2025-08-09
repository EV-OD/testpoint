# Anti-Cheating System Design

## Overview

The Anti-Cheating System is a comprehensive security framework that monitors student behavior during online tests to maintain academic integrity. The system uses platform-specific APIs and Flutter's lifecycle management to detect suspicious activities, implement preventive measures, and provide detailed violation reporting. The design emphasizes real-time monitoring, configurable thresholds, and seamless integration with the existing test-taking infrastructure.

## Architecture

### Core Components
- **AntiCheatMonitor**: Central monitoring service coordinating all security measures
- **ViolationDetector**: Detects and classifies different types of violations
- **SecurityEnforcer**: Implements preventive measures like screen pinning and screenshot blocking
- **ViolationLogger**: Records and manages violation data
- **ConfigurationManager**: Handles anti-cheat settings and thresholds

### Platform Integration
- **Android**: App usage stats, screen pinning, screenshot prevention
- **iOS**: App state monitoring, guided access recommendations
- **Web**: Page visibility API, focus detection
- **Desktop**: Window focus monitoring, system event detection

### Data Flow
```
Student Action → Platform Detection → Violation Classification → 
Response Decision → Security Action → Logging → Teacher Notification
```

## Components and Interfaces

### Core Models

#### AntiCheatConfiguration
```dart
class AntiCheatConfiguration {
  final bool appSwitchDetectionEnabled;
  final bool screenPinningRequired;
  final bool screenshotPreventionEnabled;
  final int maxWarnings;
  final Duration violationTimeout;
  final ViolationSeverity autoSubmitThreshold;
  final Map<ViolationType, ViolationResponse> responseMap;
}
```

#### ViolationRecord (Firebase Document Field)
```dart
class ViolationRecord {
  final String id;
  final String sessionId; // Reference to test_sessions document
  final String studentId; // Firebase Auth UID
  final ViolationType type;
  final ViolationSeverity severity;
  final DateTime timestamp;
  final Duration duration;
  final Map<String, dynamic> metadata;
  final String description;
  final ViolationResponse response;
  
  // Firebase serialization methods
  Map<String, dynamic> toMap();
  static ViolationRecord fromMap(Map<String, dynamic> map);
}

enum ViolationType {
  appSwitch,
  screenPinningDisabled,
  screenshotAttempt,
  screenRecordingDetected,
  suspiciousActivity,
  timeManipulation,
  networkAnomaly
}

enum ViolationSeverity {
  low,
  medium,
  high,
  critical
}

enum ViolationResponse {
  warning,
  pauseTest,
  submitTest,
  blockAction
}
```

#### SecurityState
```dart
class SecurityState {
  final bool isScreenPinned;
  final bool isScreenshotBlocked;
  final bool isMonitoringActive;
  final List<ViolationRecord> activeViolations;
  final int warningCount;
  final SecurityLevel currentLevel;
}

enum SecurityLevel {
  normal,
  elevated,
  high,
  critical
}
```

### Service Layer

#### AntiCheatMonitor
```dart
class AntiCheatMonitor {
  final ViolationDetector _detector;
  final SecurityEnforcer _enforcer;
  final ViolationLogger _logger;
  final ConfigurationManager _config;
  
  Future<void> startMonitoring(String sessionId);
  Future<void> stopMonitoring();
  Stream<ViolationRecord> get violationStream;
  Future<void> handleViolation(ViolationRecord violation);
  SecurityState get currentState;
  Future<void> updateConfiguration(AntiCheatConfiguration config);
}
```

#### ViolationDetector
```dart
class ViolationDetector {
  Stream<AppLifecycleState> get appStateStream;
  Stream<bool> get screenPinningStream;
  Stream<SystemEvent> get systemEventStream;
  
  Future<void> startDetection();
  Future<void> stopDetection();
  ViolationRecord? classifyEvent(SystemEvent event);
  bool isViolationCritical(ViolationRecord violation);
}
```

#### SecurityEnforcer
```dart
class SecurityEnforcer {
  Future<bool> enableScreenPinning();
  Future<void> disableScreenPinning();
  Future<bool> enableScreenshotPrevention();
  Future<void> disableScreenshotPrevention();
  Future<void> showViolationWarning(ViolationRecord violation);
  Future<void> pauseTest(String sessionId);
  Future<void> submitTest(String sessionId, String reason);
}
```

#### ViolationLogger
```dart
class ViolationLogger {
  final FirebaseFirestore _firestore;
  
  Future<void> logViolation(ViolationRecord violation);
  Future<void> updateTestSessionViolations(String sessionId, ViolationRecord violation);
  Future<List<ViolationRecord>> getViolationsBySession(String sessionId);
  Future<ViolationReport> generateReport(String sessionId);
  Future<void> exportViolations(String sessionId, ExportFormat format);
  Stream<ViolationRecord> get realtimeViolations;
  
  // Firebase-specific methods
  Future<void> syncViolationsToFirebase(String sessionId, List<ViolationRecord> violations);
  Stream<List<ViolationRecord>> watchSessionViolations(String sessionId);
}
```

### Platform-Specific Implementations

#### Android Implementation
```dart
class AndroidAntiCheat implements PlatformAntiCheat {
  static const MethodChannel _channel = MethodChannel('anti_cheat/android');
  
  @override
  Future<bool> enableScreenPinning() async {
    return await _channel.invokeMethod('enableScreenPinning');
  }
  
  @override
  Future<void> startAppUsageMonitoring() async {
    await _channel.invokeMethod('startUsageMonitoring');
  }
  
  @override
  Stream<String> get foregroundAppStream {
    return EventChannel('anti_cheat/foreground_app')
        .receiveBroadcastStream()
        .cast<String>();
  }
}
```

#### iOS Implementation
```dart
class IOSAntiCheat implements PlatformAntiCheat {
  @override
  Future<bool> enableScreenPinning() async {
    // iOS uses Guided Access - provide instructions
    return await _showGuidedAccessInstructions();
  }
  
  @override
  Stream<AppLifecycleState> get appStateStream {
    return WidgetsBinding.instance.lifecycleStateStream;
  }
}
```

### UI Components

#### ViolationWarningDialog
```dart
class ViolationWarningDialog extends StatelessWidget {
  final ViolationRecord violation;
  final int remainingWarnings;
  final VoidCallback onAcknowledge;
  
  // Displays violation details and consequences
  // Shows remaining warnings before auto-submission
  // Provides educational content about the violation
}
```

#### AntiCheatSetupScreen
```dart
class AntiCheatSetupScreen extends StatelessWidget {
  final AntiCheatConfiguration config;
  final VoidCallback onSetupComplete;
  
  // Explains anti-cheat measures to students
  // Guides through screen pinning setup
  // Confirms student understanding and consent
}
```

#### SecurityStatusIndicator
```dart
class SecurityStatusIndicator extends StatelessWidget {
  final SecurityState state;
  
  // Shows current security level
  // Displays active monitoring status
  // Indicates any security issues
}
```

## Data Models

### Violation Storage Schema
```dart
{
  "id": "violation_uuid",
  "sessionId": "session_uuid",
  "studentId": "student_uuid",
  "type": "appSwitch",
  "severity": "medium",
  "timestamp": "2024-02-15T10:15:30Z",
  "duration": 5000, // milliseconds
  "metadata": {
    "previousApp": "com.example.calculator",
    "switchDuration": 5000,
    "returnedVoluntarily": true,
    "systemEvent": "app_paused"
  },
  "description": "Student switched to calculator app for 5 seconds",
  "response": "warning"
}
```

### Configuration Schema
```dart
{
  "appSwitchDetectionEnabled": true,
  "screenPinningRequired": true,
  "screenshotPreventionEnabled": true,
  "maxWarnings": 3,
  "violationTimeout": 300000, // 5 minutes
  "autoSubmitThreshold": "high",
  "responseMap": {
    "appSwitch": {
      "first": "warning",
      "second": "warning",
      "third": "submitTest"
    },
    "screenshotAttempt": {
      "first": "blockAction",
      "subsequent": "warning"
    }
  }
}
```

## Error Handling

### Platform Limitations
- Graceful degradation when features are unavailable
- Clear messaging about security limitations
- Alternative monitoring methods when primary fails
- User education about platform-specific requirements

### Detection Failures
- Fallback detection mechanisms
- False positive handling and filtering
- Network connectivity issues during logging
- Recovery from monitoring service crashes

### Security Bypasses
- Multiple detection layers for redundancy
- Behavioral analysis for sophisticated attempts
- Regular security assessment and updates
- Incident response procedures

## Testing Strategy

### Unit Tests
- Violation detection accuracy
- Configuration management
- Platform-specific implementations
- Security state transitions

### Integration Tests
- End-to-end monitoring workflow
- Platform API integration
- Real-time violation handling
- Cross-platform compatibility

### Security Tests
- Bypass attempt detection
- False positive/negative rates
- Performance under attack scenarios
- Privacy and data protection compliance

### User Experience Tests
- Warning dialog usability
- Setup process clarity
- Performance impact measurement
- Accessibility compliance

## Security Considerations

### Privacy Protection
- Minimal data collection principles
- Encrypted violation storage
- Secure transmission of security events
- GDPR/COPPA compliance measures

### Data Integrity
- Tamper-proof violation logging
- Cryptographic signatures for critical events
- Audit trail maintenance
- Secure configuration storage

### Performance Impact
- Lightweight monitoring implementation
- Battery usage optimization
- Memory footprint minimization
- CPU usage monitoring

### Ethical Considerations
- Transparent communication with students
- Proportional response to violations
- Appeal and review processes
- Accessibility accommodations

## Platform-Specific Features

### Android
- Screen pinning API integration
- App usage statistics monitoring
- Screenshot prevention via FLAG_SECURE
- Background app detection
- Device administrator policies (optional)

### iOS
- App lifecycle state monitoring
- Guided Access mode instructions
- Screen recording detection
- Focus/blur event handling
- Restricted mode recommendations

### Web
- Page Visibility API integration
- Focus/blur event monitoring
- Fullscreen API enforcement
- Browser extension detection
- Network request monitoring

### Desktop
- Window focus detection
- System event monitoring
- Screen capture prevention
- Process monitoring (where permitted)
- Virtual machine detection

## Performance Optimization

### Monitoring Efficiency
- Event batching and throttling
- Selective monitoring activation
- Resource usage limits
- Background processing optimization

### Battery Conservation
- Adaptive monitoring frequency
- Sleep mode handling
- Power state awareness
- Efficient event processing

### Memory Management
- Violation record cleanup
- Stream subscription management
- Cache size limitations
- Garbage collection optimization