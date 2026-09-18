import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/constants.dart';
import '../../data/models/employee.dart';
import '../../data/models/user.dart';
import '../../logic/auth_provider.dart';
import '../../logic/employee_provider.dart';

class EmployeeDetailScreen extends ConsumerWidget {
  final String employeeId;
  final EmployeeModel? employee;

  const EmployeeDetailScreen({
    super.key,
    required this.employeeId,
    this.employee,
  });

  EmployeeModel _getEmployee(WidgetRef ref) {
    if (employee != null) return employee!;

    final employees = ref.read(employeeStateProvider).employees;
    return employees.firstWhere(
      (e) => e.id == employeeId,
      orElse: () => EmployeeModel(
        id: employeeId,
        name: 'Employee Profile',
        email: 'details@enterprise.com',
        phone: '+1 (555) 012-3456',
        role: UserRole.employee,
        department: 'IT',
        status: EmployeeStatus.active,
        joiningDate: '2026-07-01',
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, EmployeeModel emp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text(
          'Are you sure you want to delete ${emp.name}? This action cannot be undone.',
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
                    .read(employeeStateProvider.notifier)
                    .deleteEmployee(emp.id);
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Employee deleted successfully.'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                if (context.mounted) {
                  context.go('/');
                }
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final isAdmin = user?.role == UserRole.admin;
    final emp = _getEmployee(ref);

    Color statusColor = AppColors.success;
    if (emp.status == EmployeeStatus.onLeave) statusColor = AppColors.warning;
    if (emp.status == EmployeeStatus.inactive) statusColor = AppColors.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Profile'),
        actions: [
          if (isAdmin) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                context.push('/employee/${emp.id}/edit', extra: emp);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _confirmDelete(context, ref, emp),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppLayout.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 54,
                    backgroundColor: AppColors.primary.withOpacity(0.05),
                    backgroundImage: emp.avatarUrl != null
                        ? NetworkImage(emp.avatarUrl!)
                        : null,
                    child: emp.avatarUrl == null
                        ? Text(
                            emp.name.substring(0, 1),
                            style: const TextStyle(fontSize: 32),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    emp.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          emp.status.label,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          emp.role.label,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Professional Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.business, 'Department', emp.department),
                    const Divider(height: 24),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Joining Date',
                      emp.joiningDate,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(Icons.badge_outlined, 'Employee ID', emp.id),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.email_outlined,
                      'Email Address',
                      emp.email,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      Icons.phone_outlined,
                      'Phone Number',
                      emp.phone,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              child: ListTile(
                leading: const Icon(
                  Icons.folder_open_outlined,
                  color: AppColors.secondary,
                ),
                title: const Text(
                  'View Uploaded Documents',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Identity cards, resumes, credentials'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push('/employee/${emp.id}/documents');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.lightTextSecondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.lightTextSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
