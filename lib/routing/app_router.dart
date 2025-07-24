import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
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

    print(
      'Redirect: Path=${state.fullPath}, isAuthenticated=$isAuthenticated, isLoading=$isLoading',
    );

    // List of routes that are always accessible (public routes)
    final List<String> publicRoutes = [
      AppRoutes.login,
      AppRoutes.initialPasswordChange,
    ];

    // Check if the current path is one of the public routes
    final bool isGoingToPublicRoute = publicRoutes.contains(state.fullPath);

    // --- Core Redirect Logic ---

    // 1. If still loading (initial app startup)
    if (isLoading) {
      // If not on the splash screen, redirect to splash.
      if (state.fullPath != AppRoutes.splash) {
        print('Redirect: Loading, forcing to splash.');
        return AppRoutes.splash;
      }
      print('Redirect: Loading, staying on splash.');
      return null; // Stay on splash screen
    }

    // 2. If loading is complete (isLoading is false)

    // Determine the target route based on authentication status
    String? targetRoute;
    if (isAuthenticated) {
      if (authProvider.currentUser?.role == UserRole.student) {
        targetRoute = AppRoutes.studentDashboard;
      } else if (authProvider.currentUser?.role == UserRole.teacher) {
        targetRoute = AppRoutes.teacherDashboard;
      }
    } else {
      targetRoute = AppRoutes.login;
    }

    // If the current path is the splash screen, and loading is done, redirect to target.
    if (state.fullPath == AppRoutes.splash) {
      print('Redirect: Splash screen after loading, redirecting to $targetRoute.');
      return targetRoute;
    }

    // If authenticated and trying to go to a public route, redirect to dashboard.
    if (isAuthenticated && isGoingToPublicRoute) {
      print('Redirect: Authenticated and on public route, redirecting to $targetRoute.');
      return targetRoute;
    }

    // If not authenticated and trying to go to a protected route, redirect to login.
    if (!isAuthenticated && !isGoingToPublicRoute) {
      print('Redirect: Not authenticated and on protected route, redirecting to $targetRoute.');
      return targetRoute;
    }

    print('Redirect: No redirect needed. Current path is $state.fullPath');
    // No redirect needed, stay on the current path
    return null;
  },
);
