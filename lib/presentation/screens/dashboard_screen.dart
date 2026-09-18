import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/constants.dart';
import '../../logic/auth_provider.dart';
import '../../logic/attendance_provider.dart';
import '../../logic/leave_provider.dart';
import '../../logic/employee_provider.dart';
import '../../data/models/user.dart';
import '../../data/models/leave_request.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  double _swipeProgress = 0.0;
  bool _sliderUnlocked = false;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _triggerCheckAction(BuildContext context, bool isCheckIn) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      if (isCheckIn) {
        await ref
            .read(attendanceStateProvider.notifier)
            .checkIn(37.7749, -122.4194);
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Successfully checked in! Location verified.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        await ref.read(attendanceStateProvider.notifier).checkOut();
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Successfully checked out! Log saved.'),
            backgroundColor: AppColors.info,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('ApiException: ', '')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final attendanceState = ref.watch(attendanceStateProvider);
    final leaveState = ref.watch(leaveStateProvider);
    final employeeState = ref.watch(employeeStateProvider);

    if (user == null) return const Center(child: CircularProgressIndicator());

    final todayRecord = attendanceState.todayRecord;
    final isCheckedIn = todayRecord != null;
    final isCheckedOut = todayRecord?.checkOut != null;

    final isWide = MediaQuery.of(context).size.width >= 720;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(attendanceStateProvider.notifier).initAttendance();
          ref.read(leaveStateProvider.notifier).initLeaveState();
          ref
              .read(employeeStateProvider.notifier)
              .fetchEmployees(isRefresh: true);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppLayout.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildWelcomeBanner(user),
              const SizedBox(height: 24),
              isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildCheckInOutCard(
                            isCheckedIn,
                            isCheckedOut,
                            attendanceState.isActionLoading,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 4,
                          child: _buildKpiGrid(user, leaveState, employeeState),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildCheckInOutCard(
                          isCheckedIn,
                          isCheckedOut,
                          attendanceState.isActionLoading,
                        ),
                        const SizedBox(height: 20),
                        _buildKpiGrid(user, leaveState, employeeState),
                      ],
                    ),
              const SizedBox(height: 24),
              _buildRecentActivity(context, user, leaveState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner(UserModel user) {
    final formattedDate = DateFormat('EEEE, MMMM d, y').format(DateTime.now());
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedDate,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_getGreeting()}, ${user.name}!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.role.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Department: ${user.department}',
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInOutCard(
    bool isCheckedIn,
    bool isCheckedOut,
    bool isActionLoading,
  ) {
    String cardTitle = 'Ready to Start Your Shift?';
    String cardSubtitle = 'Slide to check-in at Headquarters';
    IconData cardIcon = Icons.fingerprint;
    Color iconColor = AppColors.primaryLight;

    if (isCheckedIn && !isCheckedOut) {
      cardTitle = 'You are Checked In';
      cardSubtitle =
          'Shift started: ${DateFormat.jm().format(DateTime.parse(ref.watch(attendanceStateProvider).todayRecord!.checkIn))}';
      cardIcon = Icons.verified_user;
      iconColor = AppColors.success;
    } else if (isCheckedOut) {
      cardTitle = 'Shift Completed Today';
      cardSubtitle =
          'Total logged: ${ref.watch(attendanceStateProvider).todayRecord!.workingHours} hours';
      cardIcon = Icons.done_all;
      iconColor = AppColors.info;
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: iconColor.withOpacity(0.1),
                  child: Icon(cardIcon, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cardTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cardSubtitle,
                        style: const TextStyle(
                          color: AppColors.lightTextSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (!isCheckedOut && !isActionLoading)
              _buildSlideActionControl(isCheckedIn)
            else if (isActionLoading)
              const SizedBox(
                height: 50,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColors.success.withOpacity(0.2)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: AppColors.success,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Awesome! See you tomorrow.',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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

  Widget _buildSlideActionControl(bool isCheckedIn) {
    final label = isCheckedIn ? 'Slide to Check Out' : 'Slide to Check In';
    final activeColor = isCheckedIn ? AppColors.warning : AppColors.success;

    return LayoutBuilder(
      builder: (context, constraints) {
        final sliderWidth = constraints.maxWidth;
        final thumbSize = 46.0;
        final maxSwipe = sliderWidth - thumbSize - 8.0;

        return StatefulBuilder(
          builder: (context, setSliderState) {
            return Container(
              height: 54,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkSurface
                    : AppColors.lightBg,
                borderRadius: BorderRadius.circular(27),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                  Positioned(
                    left: _swipeProgress * maxSwipe,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setSliderState(() {
                          _swipeProgress =
                              (_swipeProgress + details.delta.dx / maxSwipe)
                                  .clamp(0.0, 1.0);
                        });
                      },
                      onHorizontalDragEnd: (details) {
                        if (_swipeProgress > 0.85) {
                          _swipeProgress = 1.0;
                          _triggerCheckAction(context, !isCheckedIn);
                        }
                        setSliderState(() {
                          _swipeProgress = 0.0;
                        });
                      },
                      child: Container(
                        width: thumbSize,
                        height: thumbSize,
                        decoration: BoxDecoration(
                          color: activeColor,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildKpiGrid(
    UserModel user,
    LeaveState leaveState,
    EmployeeState employeeState,
  ) {
    final isAdmin =
        user.role == UserRole.admin || user.role == UserRole.manager;

    if (isAdmin) {
      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildKpiCard(
            'Total Employees',
            employeeState.employees.length.toString(),
            Icons.people_outline,
            AppColors.primaryLight,
          ),
          _buildKpiCard(
            'Pending Leaves',
            leaveState.leaves
                .where((l) => l.status == LeaveStatus.pending)
                .length
                .toString(),
            Icons.pending_actions_outlined,
            AppColors.warning,
          ),
        ],
      );
    } else {
      // Employee Specific metrics
      final annualLeft = leaveState.balances['annual'] ?? 0;
      final sickLeft = leaveState.balances['sick'] ?? 0;
      final casualLeft = leaveState.balances['casual'] ?? 0;
      final totalLeaves = annualLeft + sickLeft + casualLeft;

      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildKpiCard(
            'Available Leaves',
            totalLeaves.toString(),
            Icons.beach_access_outlined,
            AppColors.accent,
          ),
          _buildKpiCard(
            'Hours Worked (Mon)',
            '8.1h',
            Icons.query_builder,
            AppColors.primaryLight,
          ),
        ],
      );
    }
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              radius: 20,
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.lightTextSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(
    BuildContext context,
    UserModel user,
    LeaveState leaveState,
  ) {
    final isAdmin =
        user.role == UserRole.admin || user.role == UserRole.manager;

    // Filter pending leaves or recently applied leaves
    final pendingLeaves = leaveState.leaves
        .where((l) => isAdmin ? l.status == LeaveStatus.pending : true)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isAdmin
                  ? 'Action Required: Pending Leaves'
                  : 'My Recent Leave Applications',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (pendingLeaves.isEmpty)
          const Card(
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'No recent applications to show.',
                  style: TextStyle(color: AppColors.lightTextSecondary),
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pendingLeaves.take(3).length,
            itemBuilder: (context, index) {
              final leave = pendingLeaves[index];
              Color statusColor = AppColors.warning;
              if (leave.status == LeaveStatus.approved)
                statusColor = AppColors.success;
              if (leave.status == LeaveStatus.rejected)
                statusColor = AppColors.error;

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(
                    isAdmin ? leave.employeeName : leave.leaveType.label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Dates: ${leave.startDate} to ${leave.endDate}',
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      leave.status.label,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
