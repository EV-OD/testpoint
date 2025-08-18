class AntiCheatViolation {
  final String id;
  final DateTime timestamp;
  final ViolationType type;
  final String description;
  final Map<String, dynamic> metadata;
  final int severity; // 1 = warning, 2 = serious, 3 = critical (auto-submit)

  const AntiCheatViolation({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.description,
    required this.metadata,
    required this.severity,
  });

  factory AntiCheatViolation.fromMap(Map<String, dynamic> map) {
    return AntiCheatViolation(
      id: map['id'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      type: ViolationType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => ViolationType.unknown,
      ),
      description: map['description'] as String,
      metadata: Map<String, dynamic>.from(map['metadata'] as Map),
      severity: map['severity'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'description': description,
      'metadata': metadata,
      'severity': severity,
    };
  }

  factory AntiCheatViolation.appSwitch({
    required String appName,
    required Duration duration,
  }) {
    return AntiCheatViolation(
      id: 'violation_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      type: ViolationType.appSwitch,
      description: 'Student switched to $appName for ${duration.inSeconds} seconds',
      metadata: {
        'app_name': appName,
        'duration_ms': duration.inMilliseconds,
        'duration_seconds': duration.inSeconds,
      },
      severity: duration.inSeconds > 10 ? 3 : 2, // Auto-submit after 10 seconds
    );
  }

  factory AntiCheatViolation.screenPinDisabled() {
    return AntiCheatViolation(
      id: 'violation_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      type: ViolationType.screenPinDisabled,
      description: 'Screen pinning was disabled during test',
      metadata: {},
      severity: 3, // Critical - auto submit
    );
  }

  factory AntiCheatViolation.screenshotAttempt() {
    return AntiCheatViolation(
      id: 'violation_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      type: ViolationType.screenshotAttempt,
      description: 'Student attempted to take a screenshot',
      metadata: {},
      severity: 2, // Serious warning
    );
  }

  factory AntiCheatViolation.screenRecordingDetected() {
    return AntiCheatViolation(
      id: 'violation_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      type: ViolationType.screenRecording,
      description: 'Screen recording was detected during test',
      metadata: {},
      severity: 3, // Critical - auto submit
    );
  }

  factory AntiCheatViolation.suspiciousActivity({
    required String activity,
    required Map<String, dynamic> details,
  }) {
    return AntiCheatViolation(
      id: 'violation_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      type: ViolationType.suspiciousActivity,
      description: 'Suspicious activity detected: $activity',
      metadata: details,
      severity: 2,
    );
  }
}

enum ViolationType {
  appSwitch,
  screenPinDisabled,
  screenshotAttempt,
  screenRecording,
  suspiciousActivity,
  unknown,
}

extension ViolationTypeExtension on ViolationType {
  String get displayName {
    switch (this) {
      case ViolationType.appSwitch:
        return 'App Switch';
      case ViolationType.screenPinDisabled:
        return 'Screen Pin Disabled';
      case ViolationType.screenshotAttempt:
        return 'Screenshot Attempt';
      case ViolationType.screenRecording:
        return 'Screen Recording';
      case ViolationType.suspiciousActivity:
        return 'Suspicious Activity';
      case ViolationType.unknown:
        return 'Unknown Violation';
    }
  }

  String get icon {
    switch (this) {
      case ViolationType.appSwitch:
        return '🔄';
      case ViolationType.screenPinDisabled:
        return '📌';
      case ViolationType.screenshotAttempt:
        return '📸';
      case ViolationType.screenRecording:
        return '🎥';
      case ViolationType.suspiciousActivity:
        return '⚠️';
      case ViolationType.unknown:
        return '❓';
    }
  }
}
