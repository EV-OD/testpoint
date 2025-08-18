class AntiCheatConfig {
  final int maxWarnings; // Number of warnings before auto-submit
  final int maxAppSwitchDuration; // Max seconds allowed before auto-submit
  final bool enableScreenPinning;
  final bool enableScreenshotPrevention;
  final bool enableScreenRecordingDetection;
  final bool enableSuspiciousActivityDetection;
  final Duration violationCooldown; // Time between similar violations

  const AntiCheatConfig({
    this.maxWarnings = 3,
    this.maxAppSwitchDuration = 10,
    this.enableScreenPinning = true,
    this.enableScreenshotPrevention = true,
    this.enableScreenRecordingDetection = true,
    this.enableSuspiciousActivityDetection = true,
    this.violationCooldown = const Duration(seconds: 5),
  });

  factory AntiCheatConfig.fromMap(Map<String, dynamic> map) {
    return AntiCheatConfig(
      maxWarnings: map['max_warnings'] as int? ?? 3,
      maxAppSwitchDuration: map['max_app_switch_duration'] as int? ?? 10,
      enableScreenPinning: map['enable_screen_pinning'] as bool? ?? true,
      enableScreenshotPrevention: map['enable_screenshot_prevention'] as bool? ?? true,
      enableScreenRecordingDetection: map['enable_screen_recording_detection'] as bool? ?? true,
      enableSuspiciousActivityDetection: map['enable_suspicious_activity_detection'] as bool? ?? true,
      violationCooldown: Duration(
        milliseconds: map['violation_cooldown_ms'] as int? ?? 5000,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'max_warnings': maxWarnings,
      'max_app_switch_duration': maxAppSwitchDuration,
      'enable_screen_pinning': enableScreenPinning,
      'enable_screenshot_prevention': enableScreenshotPrevention,
      'enable_screen_recording_detection': enableScreenRecordingDetection,
      'enable_suspicious_activity_detection': enableSuspiciousActivityDetection,
      'violation_cooldown_ms': violationCooldown.inMilliseconds,
    };
  }

  // Default strict configuration for high-stakes tests
  factory AntiCheatConfig.strict() {
    return const AntiCheatConfig(
      maxWarnings: 2,
      maxAppSwitchDuration: 5,
      enableScreenPinning: true,
      enableScreenshotPrevention: true,
      enableScreenRecordingDetection: true,
      enableSuspiciousActivityDetection: true,
      violationCooldown: Duration(seconds: 3),
    );
  }

  // Lenient configuration for practice tests
  factory AntiCheatConfig.lenient() {
    return const AntiCheatConfig(
      maxWarnings: 5,
      maxAppSwitchDuration: 30,
      enableScreenPinning: false,
      enableScreenshotPrevention: false,
      enableScreenRecordingDetection: false,
      enableSuspiciousActivityDetection: false,
      violationCooldown: Duration(seconds: 10),
    );
  }

  // Balanced configuration for regular tests
  factory AntiCheatConfig.balanced() {
    return const AntiCheatConfig(
      maxWarnings: 3,
      maxAppSwitchDuration: 15,
      enableScreenPinning: true,
      enableScreenshotPrevention: true,
      enableScreenRecordingDetection: true,
      enableSuspiciousActivityDetection: true,
      violationCooldown: Duration(seconds: 5),
    );
  }
}
