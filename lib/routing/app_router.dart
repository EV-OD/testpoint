import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:testpoint/config/app_routes.dart';
import 'package:testpoint/features/auth/screens/login_screen.dart';
import 'package:testpoint/features/auth/screens/splash_screen.dart';
import 'package:testpoint/features/student/screens/student_dashboard.dart';
import 'package:testpoint/features/teacher/screens/teacher_dashboard.dart';
import 'package:testpoint/features/auth/screens/initial_password_change_screen.dart';
import 'package:testpoint/features/student/screens/test_instructions_screen.dart';
import 'package:testpoint/features/student/screens/test_taking_screen.dart';
import 'package:testpoint/features/student/screens/test_results_screen.dart';
import 'package:testpoint/features/student/screens/test_submitted_screen.dart';
import 'package:testpoint/providers/auth_provider.dart';
import 'package:testpoint/models/user_model.dart';
import 'package:testpoint/models/test_model.dart';
import 'package:testpoint/models/question_model.dart';

final GoRouter Function(AuthProvider) router = (authProvider) => GoRouter(
  initialLocation: AppRoutes.splash,
  refreshListenable: authProvider, // Listen to AuthProvider for changes
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.initialPasswordChange,
      builder: (context, state) => const InitialPasswordChangeScreen(),
    ),
    GoRoute(
      path: AppRoutes.studentDashboard,
      builder: (context, state) => const StudentDashboard(),
    ),
    GoRoute(
      path: AppRoutes.teacherDashboard,
      builder: (context, state) => const TeacherDashboard(),
    ),
    GoRoute(
      path: AppRoutes.testInstructions,
      builder: (context, state) {
        final test = state.extra as Test;
        return TestInstructionsScreen(test: test);
      },
    ),
    GoRoute(
      path: AppRoutes.testTaking,
      builder: (context, state) {
        final test = state.extra as Test;
        return TestTakingScreen(test: test);
      },
    ),
    GoRoute(
      path: AppRoutes.testResults,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return TestResultsScreen(
          test: data['test'] as Test,
          questions: data['questions'] as List<Question>,
          answers: data['answers'] as Map<int, int>,
          score: data['score'] as int,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.testSubmitted,
      builder: (context, state) {
        final test = state.extra as Test;
        return TestSubmittedScreen(test: test);
      },
    ),
  ],
  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuthenticated = authProvider.isAuthenticated;
    final isLoading = authProvider.isInitialAuthCheckLoading;

    // 1. If still loading (initial app startup), only allow splash screen.
    if (isLoading) {
      return state.fullPath == AppRoutes.splash ? null : AppRoutes.splash;
    }

    // 2. Once loading is complete (isLoading is false), determine the target route.
    final String targetRoute = isAuthenticated
        ? (authProvider.currentUser?.role == UserRole.student
              ? AppRoutes.studentDashboard
              : AppRoutes.teacherDashboard)
        : AppRoutes.login;

    // If the current path is the target route, no redirect needed.
    if (state.fullPath == targetRoute) {
      return null;
    }

    // If the current path is the splash screen, redirect to the target route.
    if (state.fullPath == AppRoutes.splash) {
      return targetRoute;
    }

    // If authenticated and trying to access login/password change, redirect to dashboard.
    if (isAuthenticated &&
        (state.fullPath == AppRoutes.login ||
            state.fullPath == AppRoutes.initialPasswordChange)) {
      return targetRoute;
    }

    // If not authenticated and trying to access a protected route, redirect to login.
    if (!isAuthenticated &&
        (state.fullPath == AppRoutes.studentDashboard ||
            state.fullPath == AppRoutes.teacherDashboard)) {
      return targetRoute;
    }

    // Otherwise, no redirect needed (e.g., already on the correct page, or navigating between protected pages).
    return null;
  },
);
