import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../data/models/user.dart';
import '../../logic/employee_provider.dart';

class RoleManagementScreen extends ConsumerStatefulWidget {
  const RoleManagementScreen({super.key});

  @override
  ConsumerState<RoleManagementScreen> createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends ConsumerState<RoleManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final employeeState = ref.watch(employeeStateProvider);
    final notifier = ref.read(employeeStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Role & Account Access'),
      ),
      body: employeeState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(AppLayout.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Employee Authorization Controls',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Modify employee permissions and access levels across the Enterprise ecosystem.',
                    style: TextStyle(color: AppColors.lightTextSecondary),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: employeeState.employees.length,
                      itemBuilder: (context, index) {
                        final emp = employeeState.employees[index];
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage: emp.avatarUrl != null
                                      ? NetworkImage(emp.avatarUrl!)
                                      : null,
                                  child: emp.avatarUrl == null
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        emp.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      Text(emp.email, style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(emp.role.label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: (emp.status.name == 'active' ? AppColors.success : AppColors.error).withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(emp.status.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: emp.status.name == 'active' ? AppColors.success : AppColors.error)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_road_outlined, color: AppColors.primaryLight),
                                      onPressed: () => _showManageDialog(context, emp, notifier),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showManageDialog(BuildContext context, dynamic emp, EmployeeNotifier notifier) {
    UserRole selectedRole = emp.role;
    String selectedStatusStr = emp.status.name;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Manage ${emp.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<UserRole>(
                  value: selectedRole,
                  decoration: const InputDecoration(labelText: 'Assign Role'),
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(value: role, child: Text(role.label));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedRole = val);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatusStr,
                  decoration: const InputDecoration(labelText: 'Account Status'),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                    DropdownMenuItem(value: 'onLeave', child: Text('On Leave')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => selectedStatusStr = val);
                  },
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
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  Navigator.pop(ctx);
                  try {
                    await notifier.updateEmployee(emp.id, {
                      'role': selectedRole.name,
                      'status': selectedStatusStr,
                    });
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('Employee permissions updated successfully!'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
                    );
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
                    );
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }
}
