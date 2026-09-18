import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/constants.dart';
import '../logic/auth_provider.dart';
import '../logic/notification_provider.dart';
import '../logic/theme_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/employee_directory_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/leave_requests_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notifications_screen.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const EmployeeDirectoryScreen(),
    const AttendanceScreen(),
    const LeaveRequestsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authStateProvider);
    final user = userAsync.valueOrNull;
    final themeMode = ref.watch(themeProvider);
    final unreadNotifs = ref.watch(notificationStateProvider.notifier).unreadCount;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isWide = MediaQuery.of(context).size.width >= 720;

    final List<NavigationDestination> destinations = [
      const NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
      const NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Directory'),
      const NavigationDestination(icon: Icon(Icons.access_time_outlined), selectedIcon: Icon(Icons.access_time), label: 'Attendance'),
      const NavigationDestination(icon: Icon(Icons.description_outlined), selectedIcon: Icon(Icons.description), label: 'Leaves'),
      const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
    ];

    final List<NavigationRailDestination> railDestinations = [
      const NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dashboard')),
      const NavigationRailDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: Text('Directory')),
      const NavigationRailDestination(icon: Icon(Icons.access_time_outlined), selectedIcon: Icon(Icons.access_time), label: Text('Attendance')),
      const NavigationRailDestination(icon: Icon(Icons.description_outlined), selectedIcon: Icon(Icons.description), label: Text('Leaves')),
      const NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('Profile')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.blur_on, color: AppColors.primaryLight, size: 28),
            const SizedBox(width: 8),
            Text(
              AppConstants.appName,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextPrimary
                    : AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: unreadNotifs > 0,
              label: Text(unreadNotifs.toString()),
              backgroundColor: AppColors.error,
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(themeMode == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => GoRouter.of(context).push('/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
              destinations: destinations,
              height: 65,
              elevation: 4,
            ),
      body: Row(
        children: [
          if (isWide) ...[
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
              labelType: NavigationRailLabelType.all,
              destinations: railDestinations,
              elevation: 1,
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedIconTheme: const IconThemeData(color: AppColors.primaryLight),
              unselectedIconTheme: const IconThemeData(color: Colors.grey),
            ),
            const VerticalDivider(width: 1, thickness: 1),
          ],
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
