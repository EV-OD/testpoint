import 'package:flutter/material.dart';
import 'package:testpoint/models/anti_cheat_violation_model.dart';
import 'package:testpoint/models/anti_cheat_config_model.dart';
import 'package:testpoint/services/anti_cheat_service.dart';

class AntiCheatProvider with ChangeNotifier {
  final AntiCheatService _antiCheatService = AntiCheatService.instance;
  
  // State
  bool _isActive = false;
  bool _isScreenPinned = false;
  List<AntiCheatViolation> _violations = [];
  AntiCheatConfig _config = const AntiCheatConfig();
  String? _lastWarningMessage;
  
  // Callbacks
  Function(AntiCheatViolation)? _onViolationCallback;
  Function(List<AntiCheatViolation>)? _onAutoSubmitCallback;
  Function(String)? _onWarningCallback;

  // Getters
  bool get isActive => _isActive;
  bool get isScreenPinned => _isScreenPinned;
  List<AntiCheatViolation> get violations => List.unmodifiable(_violations);
  AntiCheatConfig get config => _config;
  String? get lastWarningMessage => _lastWarningMessage;
  int get violationCount => _violations.length;
  bool get shouldAutoSubmit => _antiCheatService.shouldAutoSubmit();

  /// Initialize the anti-cheat provider
  Future<void> initialize({
    AntiCheatConfig? config,
    Function(AntiCheatViolation)? onViolation,
    Function(List<AntiCheatViolation>)? onAutoSubmit,
    Function(String)? onWarning,
  }) async {
    _config = config ?? const AntiCheatConfig();
    _onViolationCallback = onViolation;
    _onAutoSubmitCallback = onAutoSubmit;
    _onWarningCallback = onWarning;

    await _antiCheatService.initialize(
      config: _config,
      onViolation: _handleViolation,
      onAutoSubmit: _handleAutoSubmit,
      onWarning: _handleWarning,
    );

    notifyListeners();
  }

  /// Start monitoring for a test session
  Future<void> startMonitoring() async {
    try {
      await _antiCheatService.startMonitoring();
      _isActive = true;
      _isScreenPinned = _antiCheatService.isScreenPinned;
      _violations.clear();
      _lastWarningMessage = null;
      
      print('🛡️ AntiCheatProvider: Monitoring started');
      notifyListeners();
    } catch (e) {
      print('❌ AntiCheatProvider: Failed to start monitoring: $e');
      rethrow;
    }
  }

  /// Stop monitoring
  Future<void> stopMonitoring() async {
    try {
      await _antiCheatService.stopMonitoring();
      _isActive = false;
      _isScreenPinned = false;
      
      print('🛡️ AntiCheatProvider: Monitoring stopped');
      notifyListeners();
    } catch (e) {
      print('❌ AntiCheatProvider: Failed to stop monitoring: $e');
    }
  }

  /// Handle violation detected by the service
  void _handleViolation(AntiCheatViolation violation) {
    _violations.add(violation);
    print('🚨 AntiCheatProvider: Violation detected - ${violation.description}');
    
    _onViolationCallback?.call(violation);
    notifyListeners();
  }

  /// Handle auto-submit trigger
  void _handleAutoSubmit(List<AntiCheatViolation> violations) {
    print('🚨 AntiCheatProvider: Auto-submit triggered with ${violations.length} violations');
    _onAutoSubmitCallback?.call(violations);
    notifyListeners();
  }

  /// Handle warning message
  void _handleWarning(String message) {
    _lastWarningMessage = message;
    print('⚠️ AntiCheatProvider: Warning - $message');
    
    _onWarningCallback?.call(message);
    notifyListeners();
  }

  /// Manually report a violation (for custom violations)
  void reportViolation(AntiCheatViolation violation) {
    _antiCheatService.reportViolation(violation);
  }

  /// Report suspicious activity
  void reportSuspiciousActivity(String activity, Map<String, dynamic> details) {
    final violation = AntiCheatViolation.suspiciousActivity(
      activity: activity,
      details: details,
    );
    reportViolation(violation);
  }

  /// Get violation summary for reporting
  Map<String, dynamic> getViolationSummary() {
    return _antiCheatService.getViolationSummary();
  }

  /// Clear violations (for testing)
  void clearViolations() {
    _antiCheatService.clearViolations();
    _violations.clear();
    _lastWarningMessage = null;
    notifyListeners();
  }

  /// Get violations by type
  Map<ViolationType, List<AntiCheatViolation>> getViolationsByType() {
    final Map<ViolationType, List<AntiCheatViolation>> grouped = {};
    
    for (final violation in _violations) {
      grouped.putIfAbsent(violation.type, () => []).add(violation);
    }
    
    return grouped;
  }

  /// Check if screen pinning is required and active
  bool get isScreenPinningCompliant {
    return !_config.enableScreenPinning || _isScreenPinned;
  }

  /// Get current risk level based on violations
  RiskLevel get currentRiskLevel {
    final criticalCount = _violations.where((v) => v.severity >= 3).length;
    final seriousCount = _violations.where((v) => v.severity == 2).length;
    
    if (criticalCount > 0 || _violations.length >= _config.maxWarnings) {
      return RiskLevel.critical;
    } else if (seriousCount > 1 || _violations.length >= _config.maxWarnings - 1) {
      return RiskLevel.high;
    } else if (_violations.isNotEmpty) {
      return RiskLevel.medium;
    } else {
      return RiskLevel.low;
    }
  }

  /// Get remaining warnings before auto-submit
  int get remainingWarnings {
    return (_config.maxWarnings - _violations.length).clamp(0, _config.maxWarnings);
  }

  /// Update configuration (for admin settings)
  Future<void> updateConfig(AntiCheatConfig newConfig) async {
    _config = newConfig;
    
    if (_isActive) {
      // Restart monitoring with new config
      await stopMonitoring();
      await initialize(
        config: _config,
        onViolation: _onViolationCallback,
        onAutoSubmit: _onAutoSubmitCallback,
        onWarning: _onWarningCallback,
      );
      await startMonitoring();
    }
    
    notifyListeners();
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}

enum RiskLevel {
  low,
  medium,
  high,
  critical,
}

extension RiskLevelExtension on RiskLevel {
  Color get color {
    switch (this) {
      case RiskLevel.low:
        return Colors.green;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.deepOrange;
      case RiskLevel.critical:
        return Colors.red;
    }
  }

  String get label {
    switch (this) {
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.medium:
        return 'Medium Risk';
      case RiskLevel.high:
        return 'High Risk';
      case RiskLevel.critical:
        return 'Critical Risk';
    }
  }

  IconData get icon {
    switch (this) {
      case RiskLevel.low:
        return Icons.check_circle;
      case RiskLevel.medium:
        return Icons.warning;
      case RiskLevel.high:
        return Icons.error;
      case RiskLevel.critical:
        return Icons.dangerous;
    }
  }
}
