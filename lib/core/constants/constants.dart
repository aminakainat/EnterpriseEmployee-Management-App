import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Enterprise Nexus';
  static const String apiBaseUrl = 'https://api.enterprise.com/v1';

  static const String tokenKey = 'jwt_access_token';
  static const String refreshTokenKey = 'jwt_refresh_token';
  static const String userKey = 'auth_user_data';

  static const String mockDbInitializedKey = 'mock_db_initialized';
  static const String mockEmployeesKey = 'mock_db_employees';
  static const String mockAttendanceKey = 'mock_db_attendance';
  static const String mockLeavesKey = 'mock_db_leaves';
  static const String mockNotificationsKey = 'mock_db_notifications';
}

class AppColors {
  static const Color primary = Color(0xFF1E3A8A); // Deep Sapphire
  static const Color primaryLight = Color(0xFF3B82F6); // Bright Blue
  static const Color secondary = Color(0xFF4F46E5); // Royal Indigo
  static const Color accent = Color(0xFF10B981); // Emerald Mint

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF06B6D4);

  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color darkBg = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF334155);
}

class AppLayout {
  static const double borderRadius = 12.0;
  static const double cardPadding = 16.0;
  static const double screenPadding = 20.0;
}
