import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/constants.dart';
import '../../data/models/attendance.dart';
import '../../data/models/user.dart';
import '../../logic/auth_provider.dart';
import '../../logic/attendance_provider.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(attendanceStateProvider.notifier).fetchNextHistoryPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attendanceStateProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final isManager =
        user?.role == UserRole.admin || user?.role == UserRole.manager;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLocationCard(),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              isManager ? 'Company Attendance Logs' : 'My Attendance Logs',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),

          Expanded(
            child: state.isLoading && state.history.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.history.isEmpty
                ? const Center(child: Text('No attendance logs registered.'))
                : RefreshIndicator(
                    onRefresh: () => ref
                        .read(attendanceStateProvider.notifier)
                        .fetchHistory(isRefresh: true),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: state.history.length,
                      itemBuilder: (context, index) {
                        final record = state.history[index];
                        return _buildAttendanceTile(record, isManager);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.info.withOpacity(0.1),
                  child: const Icon(Icons.location_on, color: AppColors.info),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workplace Location Geofencing',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Enterprise SF HQ (37.7749, -122.4194)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'GPS Verified',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.04),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.radar, color: AppColors.primaryLight, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'You are inside the geofence perimeter (94m to HQ center)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightTextSecondary,
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

  Widget _buildAttendanceTile(AttendanceModel record, bool isManager) {
    Color statusColor = AppColors.success;
    if (record.status == AttendanceStatus.late) statusColor = AppColors.warning;
    if (record.status == AttendanceStatus.absent) statusColor = AppColors.error;

    final checkInTime = DateFormat.jm().format(DateTime.parse(record.checkIn));
    final checkOutTime = record.checkOut != null
        ? DateFormat.jm().format(DateTime.parse(record.checkOut!))
        : 'Active';

    final workingHoursText = record.workingHours != null
        ? '${record.workingHours} hrs'
        : 'Active';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      elevation: 0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          radius: 20,
          child: Icon(
            record.status == AttendanceStatus.present
                ? Icons.check
                : Icons.warning_amber_rounded,
            color: statusColor,
            size: 18,
          ),
        ),
        title: Text(
          isManager
              ? record.employeeName
              : DateFormat(
                  'EEEE, MMMM d',
                ).format(DateTime.parse(record.checkIn)),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: isManager
            ? Text(
                '${DateFormat('MMM d').format(DateTime.parse(record.checkIn))} • $checkInTime to $checkOutTime',
              )
            : Text('$checkInTime to $checkOutTime • $workingHoursText'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            record.status.label,
            style: TextStyle(
              color: statusColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
