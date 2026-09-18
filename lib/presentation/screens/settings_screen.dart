import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';
import '../../core/constants/constants.dart';
import '../../data/models/user.dart';
import '../../logic/theme_provider.dart';
import '../../logic/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isFirebaseEnabled = ref.watch(firebaseBackendProvider);
    final user = ref.watch(authStateProvider).valueOrNull;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          ListTile(
            leading: const Icon(
              Icons.palette_outlined,
              color: AppColors.primaryLight,
            ),
            title: const Text('Dark Mode'),
            subtitle: Text(
              'Current theme: ${themeMode == ThemeMode.dark ? "Dark" : "Light"}',
            ),
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (val) {
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(
              Icons.cloud_sync_outlined,
              color: AppColors.secondary,
            ),
            title: const Text('Backend Database Mode'),
            subtitle: Text(
              isFirebaseEnabled
                  ? 'Firebase Enterprise Cloud'
                  : 'Mock REST API (SharedPreferences)',
            ),
            trailing: Switch(
              value: isFirebaseEnabled,
              onChanged: (val) async {
                if (val) {
                  try {
                    if (Firebase.apps.isEmpty) {
                      await Firebase.initializeApp(
                        options: DefaultFirebaseOptions.currentPlatform,
                      );
                    }
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Firebase setup is not configured yet. Falling back to Mock API.',
                          ),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                    return;
                  }
                }

                ref.read(firebaseBackendProvider.notifier).state = val;
                final prefs = ref.read(sharedPreferencesProvider);
                await prefs.setBool('use_firebase_backend', val);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Backend switched to ${val ? "Firebase Cloud" : "Offline Mock REST API"}. Please restart for changes to apply fully.',
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Mock REST API uses a local simulated Dio Interceptor database. Firebase Cloud connects to real Google Cloud Firestore and Firebase Auth.',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.lock_outline, color: AppColors.accent),
            title: const Text('Change Password'),
            subtitle: const Text('Update account security password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile/change-password'),
          ),

          if (user?.role == UserRole.admin ||
              user?.role == UserRole.manager) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 12, bottom: 4),
              child: Text(
                'Administrative Tools',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.admin_panel_settings_outlined,
                color: AppColors.error,
              ),
              title: const Text('Role Management'),
              subtitle: const Text('Grant or revoke employee roles'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/role-management'),
            ),
            ListTile(
              leading: const Icon(
                Icons.campaign_outlined,
                color: AppColors.info,
              ),
              title: const Text('Send Notifications'),
              subtitle: const Text('Broadcast messages to employees'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/notifications/send'),
            ),
          ],
          const Divider(),

          ListTile(
            leading: const Icon(
              Icons.info_outline,
              color: AppColors.lightTextSecondary,
            ),
            title: const Text('About Application'),
            subtitle: const Text('Enterprise Nexus version and specifications'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/about'),
          ),
        ],
      ),
    );
  }
}
