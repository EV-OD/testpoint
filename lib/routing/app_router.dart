import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:testpoint/config/app_routes.dart';
import 'package:testpoint/features/auth/screens/login_screen.dart';
import 'package:testpoint/features/auth/screens/splash_screen.dart';
import 'package:testpoint/features/student/screens/student_dashboard.dart';
import 'package:testpoint/features/teacher/screens/teacher_dashboard.dart';
import 'package:testpoint/features/auth/screens/initial_password_change_screen.dart';
import 'package:testpoint/providers/auth_provider.dart';
import 'package:testpoint/models/user_model.dart';

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
