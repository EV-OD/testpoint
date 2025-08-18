# Anti-Cheat Configuration Guide

## Overview
The TestPoint anti-cheating system is highly configurable to suit different testing scenarios. You can configure it at multiple levels:

## Configuration Levels

### 1. **Global Default Configuration**
Set system-wide defaults for all new tests.

### 2. **Test-Specific Configuration**
Override settings for individual tests based on their requirements.

### 3. **Real-time Configuration**
Adjust settings during test creation or editing.

## Configuration Options

### **Warning & Violation Settings**

| Setting | Description | Default | Range |
|---------|-------------|---------|-------|
| `maxWarnings` | Number of warnings before auto-submit | 3 | 1-10 |
| `maxAppSwitchDuration` | Max seconds outside app before violation | 15 | 5-60 |
| `violationCooldown` | Time between similar violation reports | 5s | 1-30s |

### **Monitoring Features**

| Feature | Description | Default |
|---------|-------------|---------|
| `enableScreenPinning` | Prevent leaving the test app (Android) | ✅ |
| `enableScreenshotPrevention` | Block screenshots and screen capture | ✅ |
| `enableScreenRecordingDetection` | Detect screen recording attempts | ✅ |
| `enableSuspiciousActivityDetection` | Monitor unusual behavior patterns | ✅ |

## Pre-built Configurations

### **Strict Mode** 🔒
Perfect for high-stakes exams and certification tests.
```dart
AntiCheatConfig.strict()
// maxWarnings: 2
// maxAppSwitchDuration: 5 seconds
// All monitoring features: ENABLED
```

### **Balanced Mode** ⚖️
Recommended for most regular tests and assessments.
```dart
AntiCheatConfig.balanced()
// maxWarnings: 3
// maxAppSwitchDuration: 15 seconds  
// All monitoring features: ENABLED
```

### **Lenient Mode** 🎓
Ideal for practice tests and low-stakes assessments.
```dart
AntiCheatConfig.lenient()
// maxWarnings: 5
// maxAppSwitchDuration: 30 seconds
// Most monitoring features: DISABLED
```

## How to Configure

### **During Test Creation**
1. Navigate to "Create Test" screen
2. Click "Anti-Cheat Settings" button
3. Choose a preset or customize settings
4. Save the test

### **For Existing Tests**
1. Go to Teacher Dashboard
2. Find the test and click the menu (⋮)
3. Select "Configure Anti-Cheat"
4. Adjust settings and save

### **Programmatically**
```dart
// Create custom configuration
final customConfig = AntiCheatConfig(
  maxWarnings: 4,
  maxAppSwitchDuration: 20,
  enableScreenPinning: true,
  enableScreenshotPrevention: true,
  enableScreenRecordingDetection: false,
  enableSuspiciousActivityDetection: true,
  violationCooldown: Duration(seconds: 8),
);

// Apply to test
await antiCheatProvider.updateConfig(customConfig);
```

## Best Practices

### **High-Stakes Tests**
- Use **Strict Mode**
- Enable all monitoring features
- Set low violation thresholds
- Consider shorter app switch tolerance

### **Regular Assessments**
- Use **Balanced Mode**
- Enable core monitoring features
- Use moderate violation thresholds
- Allow reasonable app switch tolerance

### **Practice Tests**
- Use **Lenient Mode**
- Disable most monitoring features
- Use high violation thresholds
- Focus on educational warnings

## Security Levels

The system automatically calculates security levels based on your configuration:

### **🟢 High Security**
- Strict violation thresholds
- All monitoring features enabled
- Immediate consequences
- Best for critical assessments

### **🟡 Medium Security**
- Balanced approach
- Most monitoring features enabled
- Progressive warnings
- Good for regular tests

### **🟠 Low Security**
- Lenient thresholds
- Basic monitoring only
- Educational approach
- Suitable for practice

## Configuration UI Features

### **Interactive Sliders**
Adjust numerical settings with real-time feedback.

### **Toggle Switches**
Enable/disable monitoring features easily.

### **Preset Selector**
Quickly apply proven configurations.

### **Live Preview**
See how your settings affect security level.

### **Risk Assessment**
Visual indication of configuration strength.

## Implementation Example

```dart
// Show configuration screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AntiCheatConfigScreen(
      test: currentTest,
      initialConfig: currentTest.antiCheatConfig,
      onConfigSaved: (config) {
        // Save configuration
        updateTestConfig(currentTest.id, config);
      },
    ),
  ),
);
```

## Tips for Teachers

1. **Start with presets** - Use built-in configurations as starting points
2. **Consider test stakes** - Higher stakes = stricter settings
3. **Student experience** - Balance security with usability
4. **Test environment** - Consider where students will take the test
5. **Review violations** - Regularly check violation reports to adjust settings

The anti-cheat system is designed to be both powerful and user-friendly, giving you complete control over test security while maintaining a positive student experience.
