import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:testpoint/models/anti_cheat_violation_model.dart';
import 'package:testpoint/models/anti_cheat_config_model.dart';

class AntiCheatService {
  static AntiCheatService? _instance;
  static AntiCheatService get instance => _instance ??= AntiCheatService._();
  AntiCheatService._();

  // Configuration
  AntiCheatConfig _config = const AntiCheatConfig();
  
  // State tracking
  bool _isActive = false;
  bool _isScreenPinned = false;
  DateTime? _lastAppSwitchTime;
  DateTime? _lastViolationTime;
  int _violationCount = 0;
  final List<AntiCheatViolation> _violations = [];
  
  // Callbacks
  Function(AntiCheatViolation)? _onViolation;
  Function(List<AntiCheatViolation>)? _onAutoSubmit;
  Function(String)? _onWarning;

  // Platform-specific channels
  static const MethodChannel _platform = MethodChannel('testpoint/anti_cheat');
  
  // Getters
  bool get isActive => _isActive;
  bool get isScreenPinned => _isScreenPinned;
  List<AntiCheatViolation> get violations => List.unmodifiable(_violations);
  int get violationCount => _violationCount;
  AntiCheatConfig get config => _config;

  /// Initialize the anti-cheat system with configuration
  Future<void> initialize({
    AntiCheatConfig? config,
    Function(AntiCheatViolation)? onViolation,
    Function(List<AntiCheatViolation>)? onAutoSubmit,
    Function(String)? onWarning,
  }) async {
    _config = config ?? const AntiCheatConfig();
    _onViolation = onViolation;
    _onAutoSubmit = onAutoSubmit;
    _onWarning = onWarning;
    
    // Setup platform-specific monitoring
    await _setupPlatformMonitoring();
  }

  /// Start anti-cheat monitoring for a test session
  Future<void> startMonitoring() async {
    if (_isActive) return;
    
    _isActive = true;
    _violationCount = 0;
    _violations.clear();
    _lastAppSwitchTime = null;
    _lastViolationTime = null;
    
    print('🛡️ Anti-cheat monitoring started');
    
    // Enable platform-specific features
    if (_config.enableScreenPinning) {
      await _enableScreenPinning();
    }
    
    if (_config.enableScreenshotPrevention) {
      await _enableScreenshotPrevention();
    }
    
    if (_config.enableScreenRecordingDetection) {
      await _enableScreenRecordingDetection();
    }
    
    // Start app lifecycle monitoring
    await _startAppLifecycleMonitoring();
  }

  /// Stop anti-cheat monitoring
  Future<void> stopMonitoring() async {
    if (!_isActive) return;
    
    _isActive = false;
    
    print('🛡️ Anti-cheat monitoring stopped');
    
    // Disable all monitoring features
    await _disableScreenPinning();
    await _disableScreenshotPrevention();
    await _disableScreenRecordingDetection();
    await _stopAppLifecycleMonitoring();
  }

  /// Record a violation and check if auto-submit should trigger
  void _recordViolation(AntiCheatViolation violation) {
    // Check cooldown to prevent spam violations
    if (_lastViolationTime != null && 
        DateTime.now().difference(_lastViolationTime!) < _config.violationCooldown) {
      return;
    }
    
    _lastViolationTime = DateTime.now();
    _violations.add(violation);
    _violationCount++;
    
    print('🚨 Violation recorded: ${violation.description}');
    print('🚨 Total violations: $_violationCount/${_config.maxWarnings}');
    
    _onViolation?.call(violation);
    
    // Check if we should auto-submit
    if (violation.severity >= 3 || _violationCount >= _config.maxWarnings) {
      print('🚨 AUTO-SUBMIT TRIGGERED');
      _onAutoSubmit?.call(_violations);
    } else {
      // Show warning
      final remainingWarnings = _config.maxWarnings - _violationCount;
      _onWarning?.call(
        '${violation.type.displayName} detected. $remainingWarnings warnings remaining before test submission.'
      );
    }
  }

  /// Setup platform-specific monitoring
  Future<void> _setupPlatformMonitoring() async {
    try {
      _platform.setMethodCallHandler(_handlePlatformCall);
    } catch (e) {
      print('Failed to setup platform monitoring: $e');
    }
  }

  /// Handle platform-specific method calls
  Future<dynamic> _handlePlatformCall(MethodCall call) async {
    switch (call.method) {
      case 'onAppSwitch':
        final arguments = call.arguments as Map<String, dynamic>;
        _handleAppSwitch(
          arguments['appName'] as String? ?? 'Unknown App',
          Duration(milliseconds: arguments['duration'] as int? ?? 0),
        );
        break;
      case 'onScreenPinDisabled':
        _handleScreenPinDisabled();
        break;
      case 'onScreenshotAttempt':
        _handleScreenshotAttempt();
        break;
      case 'onScreenRecordingDetected':
        _handleScreenRecordingDetected();
        break;
    }
  }

  /// Handle app switch detection
  void _handleAppSwitch(String appName, Duration duration) {
    if (!_isActive) return;
    
    final violation = AntiCheatViolation.appSwitch(
      appName: appName,
      duration: duration,
    );
    
    _recordViolation(violation);
  }

  /// Handle screen pin disabled
  void _handleScreenPinDisabled() {
    if (!_isActive) return;
    
    _isScreenPinned = false;
    final violation = AntiCheatViolation.screenPinDisabled();
    _recordViolation(violation);
  }

  /// Handle screenshot attempt
  void _handleScreenshotAttempt() {
    if (!_isActive) return;
    
    final violation = AntiCheatViolation.screenshotAttempt();
    _recordViolation(violation);
  }

  /// Handle screen recording detected
  void _handleScreenRecordingDetected() {
    if (!_isActive) return;
    
    final violation = AntiCheatViolation.screenRecordingDetected();
    _recordViolation(violation);
  }

  /// Enable screen pinning (Android)
  Future<bool> _enableScreenPinning() async {
    try {
      if (Platform.isAndroid) {
        final result = await _platform.invokeMethod('enableScreenPinning');
        _isScreenPinned = result as bool? ?? false;
        print('📌 Screen pinning ${_isScreenPinned ? 'enabled' : 'failed to enable'}');
        return _isScreenPinned;
      }
      return false;
    } catch (e) {
      print('Failed to enable screen pinning: $e');
      return false;
    }
  }

  /// Disable screen pinning
  Future<void> _disableScreenPinning() async {
    try {
      if (Platform.isAndroid && _isScreenPinned) {
        await _platform.invokeMethod('disableScreenPinning');
        _isScreenPinned = false;
        print('📌 Screen pinning disabled');
      }
    } catch (e) {
      print('Failed to disable screen pinning: $e');
    }
  }

  /// Enable screenshot prevention
  Future<void> _enableScreenshotPrevention() async {
    try {
      await _platform.invokeMethod('enableScreenshotPrevention');
      print('📸 Screenshot prevention enabled');
    } catch (e) {
      print('Failed to enable screenshot prevention: $e');
    }
  }

  /// Disable screenshot prevention
  Future<void> _disableScreenshotPrevention() async {
    try {
      await _platform.invokeMethod('disableScreenshotPrevention');
      print('📸 Screenshot prevention disabled');
    } catch (e) {
      print('Failed to disable screenshot prevention: $e');
    }
  }

  /// Enable screen recording detection
  Future<void> _enableScreenRecordingDetection() async {
    try {
      await _platform.invokeMethod('enableScreenRecordingDetection');
      print('🎥 Screen recording detection enabled');
    } catch (e) {
      print('Failed to enable screen recording detection: $e');
    }
  }

  /// Disable screen recording detection
  Future<void> _disableScreenRecordingDetection() async {
    try {
      await _platform.invokeMethod('disableScreenRecordingDetection');
      print('🎥 Screen recording detection disabled');
    } catch (e) {
      print('Failed to disable screen recording detection: $e');
    }
  }

  /// Start app lifecycle monitoring
  Future<void> _startAppLifecycleMonitoring() async {
    try {
      await _platform.invokeMethod('startAppLifecycleMonitoring');
      print('👁️ App lifecycle monitoring started');
    } catch (e) {
      print('Failed to start app lifecycle monitoring: $e');
    }
  }

  /// Stop app lifecycle monitoring
  Future<void> _stopAppLifecycleMonitoring() async {
    try {
      await _platform.invokeMethod('stopAppLifecycleMonitoring');
      print('👁️ App lifecycle monitoring stopped');
    } catch (e) {
      print('Failed to stop app lifecycle monitoring: $e');
    }
  }

  /// Manual violation reporting (for custom violations)
  void reportViolation(AntiCheatViolation violation) {
    _recordViolation(violation);
  }

  /// Get violation summary for reporting
  Map<String, dynamic> getViolationSummary() {
    final summary = <String, int>{};
    for (final violation in _violations) {
      final type = violation.type.displayName;
      summary[type] = (summary[type] ?? 0) + 1;
    }
    
    return {
      'total_violations': _violationCount,
      'violations_by_type': summary,
      'violations': _violations.map((v) => v.toMap()).toList(),
      'auto_submitted': _violationCount >= _config.maxWarnings,
    };
  }

  /// Clear all violations (for testing purposes)
  void clearViolations() {
    _violations.clear();
    _violationCount = 0;
    _lastViolationTime = null;
  }

  /// Check if test should be auto-submitted based on current violations
  bool shouldAutoSubmit() {
    return _violationCount >= _config.maxWarnings || 
           _violations.any((v) => v.severity >= 3);
  }
}
