import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../data/models/employee.dart';
import '../../data/models/user.dart';
import '../../logic/employee_provider.dart';

class EmployeeFormScreen extends ConsumerStatefulWidget {
  final EmployeeModel? employee;

  const EmployeeFormScreen({super.key, this.employee});

  @override
  ConsumerState<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends ConsumerState<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedDept = 'IT';
  UserRole _selectedRole = UserRole.employee;
  EmployeeStatus _selectedStatus = EmployeeStatus.active;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      final emp = widget.employee!;
      _nameController.text = emp.name;
      _emailController.text = emp.email;
      _phoneController.text = emp.phone;
      _selectedDept = emp.department;
      _selectedRole = emp.role;
      _selectedStatus = emp.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final isEditing = widget.employee != null;

    try {
      if (isEditing) {
        await ref
            .read(employeeStateProvider.notifier)
            .updateEmployee(widget.employee!.id, {
              'name': _nameController.text.trim(),
              'phone': _phoneController.text.trim(),
              'department': _selectedDept,
              'role': _selectedRole.name,
              'status': _selectedStatus.name,
            });
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Employee profile updated!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        final newEmp = EmployeeModel(
          id: '',
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          role: _selectedRole,
          department: _selectedDept,
          status: _selectedStatus,
          joiningDate: DateTime.now().toIso8601String().substring(0, 10),
        );

        await ref.read(employeeStateProvider.notifier).createEmployee(newEmp);
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Employee registered successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      if (mounted) {
        if (isEditing) {
          Navigator.pop(context);
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('ApiException: ', '')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.employee != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Profile' : 'Add Employee')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppLayout.screenPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !isEditing,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                        hintText: '+1 (555) 000-0000',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter phone';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    DropdownButtonFormField<String>(
                      value: _selectedDept,
                      decoration: const InputDecoration(
                        labelText: 'Department',
                        prefixIcon: Icon(Icons.business),
                      ),
                      items:
                          [
                            'IT',
                            'HR',
                            'Finance',
                            'Operations',
                            'Engineering',
                            'Design',
                            'Sales',
                          ].map((String dept) {
                            return DropdownMenuItem(
                              value: dept,
                              child: Text(dept),
                            );
                          }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDept = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<UserRole>(
                      value: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Organizational Role',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      items: UserRole.values.map((UserRole role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role.label),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedRole = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<EmployeeStatus>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Employee Status',
                        prefixIcon: Icon(Icons.info_outline),
                      ),
                      items: EmployeeStatus.values.map((EmployeeStatus status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedStatus = val);
                      },
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: _save,
                      child: Text(
                        isEditing ? 'Save Changes' : 'Register Employee',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
