# 🎯 TestPoint - Comprehensive Online Testing Platform

A secure, feature-rich Flutter application for creating, managing, and taking online tests with advanced anti-cheat capabilities.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com/)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)](https://flutter.dev/)

## 🌟 Features

### 🔐 **Advanced Anti-Cheat System**
- **Real-time Violation Detection**: App switching, screenshot attempts, screen recording prevention
- **Configurable Security Levels**: Strict, Balanced, and Lenient presets with custom configuration
- **Native Platform Integration**: Android screen pinning, FLAG_SECURE screenshot prevention
- **Risk Assessment**: AI-powered scoring with progressive warning system
- **Comprehensive Reporting**: Detailed violation analytics for teachers

### 👨‍🏫 **Teacher Dashboard**
- **Intuitive Test Creation**: Multi-step wizard with validation and preview
- **Question Management**: MCQ creation with real-time preview and answer validation
- **Group Management**: Organize students and assign tests to specific groups
- **Live Monitoring**: Real-time test session monitoring with violation alerts
- **Results Analytics**: Comprehensive student performance analysis

### 👨‍🎓 **Student Experience**
- **Seamless Test Taking**: Clean, distraction-free interface with progress tracking
- **Smart Timer System**: Visual countdown with automatic submission prevention
- **Educational Anti-Cheat**: Clear rules explanation before test starts
- **Instant Results**: Detailed score breakdown with question-by-question analysis
- **Mobile Optimized**: Responsive design for various screen sizes

### 🛡️ **Security & Privacy**
- **Role-Based Access Control**: Admin, Teacher, and Student permissions
- **Firebase Security Rules**: Comprehensive data protection and isolation
- **End-to-End Encryption**: Secure data transmission and storage
- **Privacy Compliant**: GDPR-ready with configurable data retention

## 🏗️ Architecture

### **Frontend (Flutter)**
- **Material 3 Design**: Modern UI with dark mode support
- **Provider State Management**: Reactive architecture with real-time updates
- **Platform Channels**: Native Android/iOS integration for anti-cheat features
- **Responsive Layout**: Optimized for phones, tablets, and desktop

### **Backend (Firebase)**
- **Firestore Database**: Real-time NoSQL database with offline support
- **Firebase Auth**: Secure authentication with role-based access
- **Cloud Functions**: Server-side validation and processing
- **Firebase Storage**: Secure file storage for future multimedia questions

### **Anti-Cheat Engine**
- **Cross-Platform Service**: Unified violation detection across platforms
- **Native Plugins**: Platform-specific security implementations
- **Real-time Monitoring**: Live violation tracking during tests
- **Machine Learning**: Pattern recognition for advanced cheat detection

## 🚀 Quick Start

### Prerequisites
- Flutter 3.0 or higher
- Android Studio / VS Code
- Firebase project setup
- Android SDK (for Android development)
- Xcode (for iOS development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/pragyan-ghimire/testpoint.git
   cd testpoint
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   ```bash
   # Add your google-services.json (Android)
   # Add your GoogleService-Info.plist (iOS)
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

### 🔧 Configuration

#### Firebase Setup
1. Create a new Firebase project
2. Enable Firestore Database
3. Enable Authentication (Email/Password)
4. Configure security rules (see `firestore.rules`)
5. Add platform-specific configuration files

#### Anti-Cheat Configuration
```dart
// Example anti-cheat configuration
AntiCheatConfig.balanced() // Recommended for most tests
AntiCheatConfig.strict()   // High-stakes exams
AntiCheatConfig.lenient()  // Practice tests
```

## 📱 Platform Features

### **Android**
- ✅ Screen pinning (prevents home/back button)
- ✅ Screenshot prevention (FLAG_SECURE)
- ✅ App lifecycle monitoring
- ✅ Background app detection
- ✅ Screen recording prevention

### **iOS** (Planned)
- ⏳ Screen recording detection
- ⏳ App switching prevention
- ⏳ Guided Access integration
- ⏳ Background monitoring

## 🎯 User Roles

### **👑 Administrator**
- Complete system management
- User role assignment
- Global configuration
- System analytics
- Security monitoring

### **👨‍🏫 Teacher**
- Test creation and management
- Group administration
- Student performance tracking
- Anti-cheat configuration
- Violation reporting

### **👨‍🎓 Student**
- Test taking interface
- Results viewing
- Progress tracking
- Profile management
- Test history

## 📊 Technical Specifications

### **Performance**
- ⚡ Real-time data synchronization
- 🔄 Offline capability (planned)
- 📱 Native performance
- 🎨 Smooth 60fps animations
- 💾 Efficient memory usage

### **Security**
- 🔐 End-to-end encryption
- 🛡️ Multi-layer validation
- 🔍 Real-time monitoring
- 📝 Audit trails
- 🚫 Anti-tampering measures

### **Scalability**
- ☁️ Cloud-native architecture
- 📈 Auto-scaling Firebase backend
- 🔀 Load balancing
- 📊 Performance monitoring
- 🗄️ Efficient data structures

## 📋 Testing Strategy

### **Unit Tests**
```bash
flutter test
```

### **Integration Tests**
```bash
flutter test integration_test/
```

### **Anti-Cheat Testing**
- Platform-specific violation simulation
- Security bypass testing
- Performance impact analysis
- User experience validation

## 🗂️ Project Structure

```
lib/
├── config/           # App configuration
├── core/            # Core utilities and themes
├── data/            # Data layer
├── features/        # Feature modules
│   ├── admin/       # Admin functionality
│   ├── auth/        # Authentication
│   ├── student/     # Student interface
│   └── teacher/     # Teacher dashboard
├── models/          # Data models
├── providers/       # State management
├── repositories/    # Data repositories
├── routing/         # Navigation
├── services/        # Business logic
└── widgets/         # Reusable components
```

## 🔄 Development Status

| Component | Status | Description |
|-----------|--------|-------------|
| **Authentication** | ✅ Complete | Firebase Auth with role-based access |
| **Test Management** | ✅ Complete | CRUD operations with validation |
| **Question System** | ✅ Complete | MCQ with preview and validation |
| **Anti-Cheat Core** | ✅ Complete | Violation detection and reporting |
| **Teacher Dashboard** | ✅ Complete | Comprehensive management interface |
| **Student Interface** | ✅ Complete | Test taking and results viewing |
| **Mobile Optimization** | ✅ Complete | Responsive design implementation |
| **Android Security** | ✅ Complete | Native anti-cheat features |
| **iOS Security** | 🚧 In Progress | Platform-specific implementations |
| **Advanced Analytics** | ⏳ Planned | ML-powered insights |
| **Offline Support** | ⏳ Planned | Cached test taking |

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Workflow
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new features
5. Ensure all tests pass
6. Submit a pull request

### Code Style
- Follow Flutter/Dart conventions
- Use meaningful variable names
- Add documentation for public APIs
- Maintain test coverage above 80%

## 📄 Documentation

- **[Firebase Structure](firebase-structure.md)** - Database schema and security rules
- **[Anti-Cheat Guide](ANTI_CHEAT_CONFIG_GUIDE.md)** - Configuration and usage
- **[API Reference](docs/api.md)** - Service and repository documentation
- **[User Manual](docs/user-guide.md)** - End-user documentation

## 🔧 Troubleshooting

### Common Issues

**Build Errors**
```bash
flutter clean
flutter pub get
flutter run
```

**Firebase Connection**
- Verify configuration files are in place
- Check Firebase project settings
- Ensure security rules are deployed

**Anti-Cheat Not Working**
- Verify platform-specific permissions
- Check device compatibility
- Review configuration settings

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/pragyan-ghimire/testpoint/issues)
- **Discussions**: [GitHub Discussions](https://github.com/pragyan-ghimire/testpoint/discussions)
- **Email**: support@testpoint.app

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for robust backend services
- Material Design for beautiful UI components
- Open source community for invaluable contributions

---

**Built with ❤️ using Flutter & Firebase**

*TestPoint - Secure, Scalable, Smart Testing Platform*
