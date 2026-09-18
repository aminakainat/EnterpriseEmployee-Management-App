import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/employee.dart';
import '../../data/models/user.dart';
import '../../logic/auth_provider.dart';
import '../../presentation/main_layout.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/forgot_password_screen.dart';
import '../../presentation/screens/reset_password_confirmation_screen.dart';
import '../../presentation/screens/employee_detail_screen.dart';
import '../../presentation/screens/employee_form_screen.dart';
import '../../presentation/screens/change_password_screen.dart';
import '../../presentation/screens/send_notification_screen.dart';
import '../../presentation/screens/uploaded_documents_screen.dart';
import '../../presentation/screens/role_management_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/about_app_screen.dart';
import '../../presentation/screens/signup_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // We can listen to the authStateChanges to trigger router refresh automatically
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-confirmation',
        builder: (context, state) => const ResetPasswordConfirmationScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // Bottom Shell Nav Layout
      GoRoute(path: '/', builder: (context, state) => const MainLayout()),

      // Employee Specific details
      GoRoute(
        path: '/employee/add',
        builder: (context, state) => const EmployeeFormScreen(),
      ),
      GoRoute(
        path: '/employee/:id',
        builder: (context, state) {
          final employee = state.extra as EmployeeModel?;
          final id = state.pathParameters['id'] ?? '';
          return EmployeeDetailScreen(employeeId: id, employee: employee);
        },
      ),
      GoRoute(
        path: '/employee/:id/edit',
        builder: (context, state) {
          final employee = state.extra as EmployeeModel?;
          return EmployeeFormScreen(employee: employee);
        },
      ),
      GoRoute(
        path: '/employee/:id/documents',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return UploadedDocumentsScreen(employeeId: id);
        },
      ),

      // Profile settings
      GoRoute(
        path: '/profile/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),

      // Admin & Settings routes
      GoRoute(
        path: '/notifications/send',
        builder: (context, state) => const SendNotificationScreen(),
      ),
      GoRoute(
        path: '/role-management',
        builder: (context, state) => const RoleManagementScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutApplicationScreen(),
      ),
    ],
    redirect: (context, state) {
      final user = authState.valueOrNull;
      final loggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/reset-confirmation' ||
          state.matchedLocation == '/splash';

      if (authState.isLoading) return null;

      if (user == null) {
        return loggingIn ? null : '/login';
      }

      if (loggingIn) {
        return '/';
      }
      final adminRoutes = [
        '/employee/add',
        '/notifications/send',
        '/role-management',
      ];
      final isEmployee = user.role == UserRole.employee;
      if (isEmployee && adminRoutes.contains(state.matchedLocation)) {
        return '/';
      }

      return null;
    },
  );
});
