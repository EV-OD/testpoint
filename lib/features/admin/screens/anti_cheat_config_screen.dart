import 'package:flutter/material.dart';
import 'package:testpoint/models/anti_cheat_config_model.dart';
import 'package:testpoint/models/test_model.dart';

class AntiCheatConfigScreen extends StatefulWidget {
  final Test? test; // If provided, configure for specific test
  final AntiCheatConfig? initialConfig;
  final Function(AntiCheatConfig)? onConfigSaved;

  const AntiCheatConfigScreen({
    super.key,
    this.test,
    this.initialConfig,
    this.onConfigSaved,
  });

  @override
  State<AntiCheatConfigScreen> createState() => _AntiCheatConfigScreenState();
}

class _AntiCheatConfigScreenState extends State<AntiCheatConfigScreen> {
  late AntiCheatConfig _config;
  ConfigPreset _selectedPreset = ConfigPreset.custom;
  bool _isSaving = false; // Prevent double-save operations

  @override
  void initState() {
    super.initState();
    _config = widget.initialConfig ?? AntiCheatConfig.balanced();
    _detectPreset();
  }

  void _detectPreset() {
    if (_config == AntiCheatConfig.strict()) {
      _selectedPreset = ConfigPreset.strict;
    } else if (_config == AntiCheatConfig.balanced()) {
      _selectedPreset = ConfigPreset.balanced;
    } else if (_config == AntiCheatConfig.lenient()) {
      _selectedPreset = ConfigPreset.lenient;
    } else {
      _selectedPreset = ConfigPreset.custom;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.test != null 
            ? 'Configure Anti-Cheat for ${widget.test!.name}'
            : 'Anti-Cheat Configuration'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPresetSelector(),
            const SizedBox(height: 24),
            _buildWarningSettings(),
            const SizedBox(height: 24),
            _buildMonitoringSettings(),
            const SizedBox(height: 24),
            _buildTimingSettings(),
            const SizedBox(height: 24),
            _buildPreview(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuration Presets',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: ConfigPreset.values.map((preset) => 
                _buildPresetChip(preset)
              ).toList(),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getPresetDescription(_selectedPreset),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(ConfigPreset preset) {
    final isSelected = _selectedPreset == preset;
    return ChoiceChip(
      label: Text(preset.label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedPreset = preset;
            _config = preset.getConfig();
          });
        }
      },
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected 
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildWarningSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Warning & Violation Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSliderSetting(
              'Maximum Warnings',
              'Number of warnings before automatic test submission',
              _config.maxWarnings.toDouble(),
              1,
              10,
              (value) => _updateConfig(_config.copyWith(maxWarnings: value.round())),
              valueLabel: '${_config.maxWarnings} warnings',
            ),
            const SizedBox(height: 16),
            _buildSliderSetting(
              'App Switch Tolerance',
              'Maximum seconds allowed outside the app before violation',
              _config.maxAppSwitchDuration.toDouble(),
              5,
              60,
              (value) => _updateConfig(_config.copyWith(maxAppSwitchDuration: value.round())),
              valueLabel: '${_config.maxAppSwitchDuration} seconds',
            ),
            const SizedBox(height: 16),
            _buildSliderSetting(
              'Violation Cooldown',
              'Minimum time between similar violation reports',
              _config.violationCooldown.inSeconds.toDouble(),
              1,
              30,
              (value) => _updateConfig(_config.copyWith(
                violationCooldown: Duration(seconds: value.round())
              )),
              valueLabel: '${_config.violationCooldown.inSeconds} seconds',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonitoringSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monitoring Features',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchSetting(
              'Screen Pinning (Android)',
              'Prevent students from leaving the test app',
              _config.enableScreenPinning,
              (value) => _updateConfig(_config.copyWith(enableScreenPinning: value)),
              Icons.pin_drop,
            ),
            _buildSwitchSetting(
              'Screenshot Prevention',
              'Block screenshot and screen capture',
              _config.enableScreenshotPrevention,
              (value) => _updateConfig(_config.copyWith(enableScreenshotPrevention: value)),
              Icons.screenshot,
            ),
            _buildSwitchSetting(
              'Screen Recording Detection',
              'Detect and prevent screen recording',
              _config.enableScreenRecordingDetection,
              (value) => _updateConfig(_config.copyWith(enableScreenRecordingDetection: value)),
              Icons.videocam,
            ),
            _buildSwitchSetting(
              'Suspicious Activity Detection',
              'Monitor for unusual behavior patterns',
              _config.enableSuspiciousActivityDetection,
              (value) => _updateConfig(_config.copyWith(enableSuspiciousActivityDetection: value)),
              Icons.psychology,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimingSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Risk Assessment',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildRiskIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskIndicator() {
    final risk = _calculateRiskLevel();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: risk.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: risk.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(risk.icon, color: risk.color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Security Level: ${risk.label}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: risk.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _getRiskDescription(risk),
                  style: TextStyle(color: risk.color.withOpacity(0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuration Preview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPreviewItem('Max Warnings', '${_config.maxWarnings}'),
            _buildPreviewItem('App Switch Tolerance', '${_config.maxAppSwitchDuration}s'),
            _buildPreviewItem('Violation Cooldown', '${_config.violationCooldown.inSeconds}s'),
            _buildPreviewItem('Screen Pinning', _config.enableScreenPinning ? 'Enabled' : 'Disabled'),
            _buildPreviewItem('Screenshot Prevention', _config.enableScreenshotPrevention ? 'Enabled' : 'Disabled'),
            _buildPreviewItem('Recording Detection', _config.enableScreenRecordingDetection ? 'Enabled' : 'Disabled'),
            _buildPreviewItem('Activity Detection', _config.enableSuspiciousActivityDetection ? 'Enabled' : 'Disabled'),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting(
    String title,
    String description,
    double value,
    double min,
    double max,
    Function(double) onChanged, {
    String? valueLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              valueLabel ?? value.round().toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).round(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSwitchSetting(
    String title,
    String description,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(description),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveConfiguration,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: _isSaving 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Save Configuration'),
          ),
        ),
      ],
    );
  }

  void _updateConfig(AntiCheatConfig newConfig) {
    setState(() {
      _config = newConfig;
      _selectedPreset = ConfigPreset.custom;
    });
  }

  void _saveConfiguration() async {
    // Prevent double-save operations
    if (_isSaving) return;
    _isSaving = true;
    
    // Call the callback first to refresh data
    widget.onConfigSaved?.call(_config);
    
    // Add a small delay to ensure callback completes
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Then navigate back, but only if still mounted and can navigate
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop(_config);
    }
  }

  SecurityLevel _calculateRiskLevel() {
    int score = 0;
    
    // Warning threshold scoring
    if (_config.maxWarnings <= 2) score += 3;
    else if (_config.maxWarnings <= 3) score += 2;
    else score += 1;
    
    // App switch tolerance scoring
    if (_config.maxAppSwitchDuration <= 10) score += 3;
    else if (_config.maxAppSwitchDuration <= 20) score += 2;
    else score += 1;
    
    // Feature enablement scoring
    if (_config.enableScreenPinning) score += 1;
    if (_config.enableScreenshotPrevention) score += 1;
    if (_config.enableScreenRecordingDetection) score += 1;
    if (_config.enableSuspiciousActivityDetection) score += 1;
    
    if (score >= 8) return SecurityLevel.high;
    if (score >= 6) return SecurityLevel.medium;
    return SecurityLevel.low;
  }

  String _getPresetDescription(ConfigPreset preset) {
    switch (preset) {
      case ConfigPreset.strict:
        return 'Maximum security for high-stakes exams. Strict monitoring with immediate consequences.';
      case ConfigPreset.balanced:
        return 'Recommended for most tests. Good balance between security and student experience.';
      case ConfigPreset.lenient:
        return 'Minimal monitoring for practice tests and low-stakes assessments.';
      case ConfigPreset.custom:
        return 'Custom configuration with manually adjusted settings.';
    }
  }

  String _getRiskDescription(SecurityLevel level) {
    switch (level) {
      case SecurityLevel.high:
        return 'High security configuration suitable for critical assessments.';
      case SecurityLevel.medium:
        return 'Moderate security with reasonable student experience.';
      case SecurityLevel.low:
        return 'Basic security measures with maximum flexibility.';
    }
  }
}

enum ConfigPreset {
  strict,
  balanced,
  lenient,
  custom,
}

extension ConfigPresetExtension on ConfigPreset {
  String get label {
    switch (this) {
      case ConfigPreset.strict:
        return 'Strict';
      case ConfigPreset.balanced:
        return 'Balanced';
      case ConfigPreset.lenient:
        return 'Lenient';
      case ConfigPreset.custom:
        return 'Custom';
    }
  }

  AntiCheatConfig getConfig() {
    switch (this) {
      case ConfigPreset.strict:
        return AntiCheatConfig.strict();
      case ConfigPreset.balanced:
        return AntiCheatConfig.balanced();
      case ConfigPreset.lenient:
        return AntiCheatConfig.lenient();
      case ConfigPreset.custom:
        return const AntiCheatConfig();
    }
  }
}

enum SecurityLevel {
  low,
  medium,
  high,
}

extension SecurityLevelExtension on SecurityLevel {
  Color get color {
    switch (this) {
      case SecurityLevel.low:
        return Colors.orange;
      case SecurityLevel.medium:
        return Colors.blue;
      case SecurityLevel.high:
        return Colors.green;
    }
  }

  String get label {
    switch (this) {
      case SecurityLevel.low:
        return 'Low';
      case SecurityLevel.medium:
        return 'Medium';
      case SecurityLevel.high:
        return 'High';
    }
  }

  IconData get icon {
    switch (this) {
      case SecurityLevel.low:
        return Icons.shield_outlined;
      case SecurityLevel.medium:
        return Icons.shield;
      case SecurityLevel.high:
        return Icons.verified_user;
    }
  }
}

// Extension to add copyWith method
extension AntiCheatConfigExtension on AntiCheatConfig {
  AntiCheatConfig copyWith({
    int? maxWarnings,
    int? maxAppSwitchDuration,
    bool? enableScreenPinning,
    bool? enableScreenshotPrevention,
    bool? enableScreenRecordingDetection,
    bool? enableSuspiciousActivityDetection,
    Duration? violationCooldown,
  }) {
    return AntiCheatConfig(
      maxWarnings: maxWarnings ?? this.maxWarnings,
      maxAppSwitchDuration: maxAppSwitchDuration ?? this.maxAppSwitchDuration,
      enableScreenPinning: enableScreenPinning ?? this.enableScreenPinning,
      enableScreenshotPrevention: enableScreenshotPrevention ?? this.enableScreenshotPrevention,
      enableScreenRecordingDetection: enableScreenRecordingDetection ?? this.enableScreenRecordingDetection,
      enableSuspiciousActivityDetection: enableSuspiciousActivityDetection ?? this.enableSuspiciousActivityDetection,
      violationCooldown: violationCooldown ?? this.violationCooldown,
    );
  }
}
