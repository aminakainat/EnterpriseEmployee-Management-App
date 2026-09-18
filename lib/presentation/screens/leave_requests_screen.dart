import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants/constants.dart';
import '../../data/models/leave_request.dart';
import '../../data/models/user.dart';
import '../../logic/auth_provider.dart';
import '../../logic/leave_provider.dart';

class LeaveRequestsScreen extends ConsumerStatefulWidget {
  const LeaveRequestsScreen({super.key});

  @override
  ConsumerState<LeaveRequestsScreen> createState() =>
      _LeaveRequestsScreenState();
}

class _LeaveRequestsScreenState extends ConsumerState<LeaveRequestsScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
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
    _tabController?.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(leaveStateProvider.notifier).fetchNextPage();
    }
  }

  void _showApplyLeaveSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const ApplyLeaveBottomSheet(),
    );
  }

  void _showReviewDialog(BuildContext context, String id, bool approve) {
    final commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(approve ? 'Approve Leave' : 'Reject Leave'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Provide comment or feedback (optional):'),
            const SizedBox(height: 12),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                hintText: 'e.g., Have a safe trip / Please reschedule...',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              try {
                await ref
                    .read(leaveStateProvider.notifier)
                    .reviewLeave(id, approve, commentController.text.trim());
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      approve
                          ? 'Leave request approved.'
                          : 'Leave request rejected.',
                    ),
                    backgroundColor: approve
                        ? AppColors.success
                        : AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      e.toString().replaceAll('ApiException: ', ''),
                    ),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: approve ? AppColors.success : AppColors.error,
            ),
            child: Text(
              approve ? 'Confirm Approval' : 'Confirm Rejection',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final state = ref.watch(leaveStateProvider);
    final isManager =
        user?.role == UserRole.admin || user?.role == UserRole.manager;

    if (isManager && _tabController == null) {
      _tabController = TabController(length: 2, vsync: this);
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (user?.role == UserRole.employee)
            _buildLeaveBalances(state.balances),

          if (isManager && _tabController != null)
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'Pending Reviews'),
                Tab(text: 'All Leave History'),
              ],
            ),

          Expanded(
            child: state.isLoading && state.leaves.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : isManager && _tabController != null
                ? TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLeavesList(
                        state.leaves
                            .where((l) => l.status == LeaveStatus.pending)
                            .toList(),
                        isManager,
                        state.isActionLoading,
                      ),
                      _buildLeavesList(
                        state.leaves,
                        isManager,
                        state.isActionLoading,
                      ),
                    ],
                  )
                : _buildLeavesList(state.leaves, false, state.isActionLoading),
          ),
        ],
      ),
      floatingActionButton: user?.role == UserRole.employee
          ? FloatingActionButton.extended(
              onPressed: () => _showApplyLeaveSheet(context),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Apply Leave'),
            )
          : null,
    );
  }

  Widget _buildLeaveBalances(Map<String, int> balances) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildBalanceCard(
              'Annual',
              balances['annual'] ?? 0,
              AppColors.primaryLight,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildBalanceCard(
              'Sick',
              balances['sick'] ?? 0,
              AppColors.warning,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildBalanceCard(
              'Casual',
              balances['casual'] ?? 0,
              AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(String title, int days, Color color) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Column(
          children: [
            Text(
              days.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$title (Days)',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.lightTextSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeavesList(
    List<LeaveRequestModel> leaves,
    bool isManager,
    bool isActionLoading,
  ) {
    if (leaves.isEmpty) {
      return const Center(child: Text('No leave applications registered.'));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: leaves.length,
      itemBuilder: (context, index) {
        final leave = leaves[index];
        Color statusColor = AppColors.warning;
        if (leave.status == LeaveStatus.approved)
          statusColor = AppColors.success;
        if (leave.status == LeaveStatus.rejected) statusColor = AppColors.error;

        final duration =
            DateTime.parse(
              leave.endDate,
            ).difference(DateTime.parse(leave.startDate)).inDays +
            1;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isManager ? leave.employeeName : leave.leaveType.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.2)),
                      ),
                      child: Text(
                        leave.status.label,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Duration: ${leave.startDate} to ${leave.endDate} ($duration days)',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Reason: "${leave.reason}"',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.lightTextSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (leave.attachmentName != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_file,
                        size: 14,
                        color: AppColors.primaryLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        leave.attachmentName!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
                if (leave.reviewerName != null) ...[
                  const Divider(height: 20),
                  Text(
                    'Reviewed by: ${leave.reviewerName}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (leave.reviewerComment != null)
                    Text(
                      'Comment: "${leave.reviewerComment}"',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                ],
                if (isManager &&
                    leave.status == LeaveStatus.pending &&
                    !isActionLoading) ...[
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () =>
                            _showReviewDialog(context, leave.id, false),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () =>
                            _showReviewDialog(context, leave.id, true),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class ApplyLeaveBottomSheet extends ConsumerStatefulWidget {
  const ApplyLeaveBottomSheet({super.key});

  @override
  ConsumerState<ApplyLeaveBottomSheet> createState() =>
      _ApplyLeaveBottomSheetState();
}

class _ApplyLeaveBottomSheetState extends ConsumerState<ApplyLeaveBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  String _leaveType = 'annual';
  DateTimeRange? _selectedRange;
  String? _attachedFileName;
  String? _attachedFilePath;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _selectDates() async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      initialDateRange: _selectedRange,
    );

    if (pickedRange != null) {
      setState(() => _selectedRange = pickedRange);
    }
  }

  void _selectAttachment() async {
    final isFirebase = ref.read(firebaseBackendProvider);
    if (isFirebase) {
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
        );
        if (result != null && result.files.single.path != null) {
          setState(() {
            _attachedFileName = result.files.single.name;
            _attachedFilePath = result.files.single.path;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error picking file: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } else {
      setState(() {
        _attachedFileName = 'medical_clearance_note.pdf';
        _attachedFilePath = 'mock_file_path';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select leave start and end dates.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final format = DateFormat('yyyy-MM-dd');
    final start = format.format(_selectedRange!.start);
    final end = format.format(_selectedRange!.end);

    try {
      await ref
          .read(leaveStateProvider.notifier)
          .applyLeave(
            leaveType: _leaveType,
            startDate: start,
            endDate: end,
            reason: _reasonController.text.trim(),
            attachmentName: _attachedFileName,
            attachmentPath: _attachedFilePath,
          );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leave request submitted!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('ApiException: ', '')),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rangeText = _selectedRange == null
        ? 'Select Date Range'
        : '${DateFormat('MMM d').format(_selectedRange!.start)} - ${DateFormat('MMM d').format(_selectedRange!.end)}';

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Apply For Leave',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _leaveType,
              decoration: const InputDecoration(
                labelText: 'Leave Type',
                prefixIcon: Icon(Icons.beach_access),
              ),
              items: const [
                DropdownMenuItem(value: 'annual', child: Text('Annual Leave')),
                DropdownMenuItem(value: 'sick', child: Text('Sick Leave')),
                DropdownMenuItem(value: 'casual', child: Text('Casual Leave')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _leaveType = val);
              },
            ),
            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: _selectDates,
              icon: const Icon(Icons.calendar_today),
              label: Text(rangeText),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.centerLeft,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for Leave',
                prefixIcon: Icon(Icons.comment_outlined),
              ),
              maxLines: 3,
              validator: (val) {
                if (val == null || val.trim().isEmpty)
                  return 'Please provide a reason';
                return null;
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _selectAttachment,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Attach Document'),
                ),
                const SizedBox(width: 12),
                if (_attachedFileName != null)
                  Expanded(
                    child: Text(
                      _attachedFileName!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _submit,
              child: const Text('Submit Application'),
            ),
          ],
        ),
      ),
    );
  }
}
