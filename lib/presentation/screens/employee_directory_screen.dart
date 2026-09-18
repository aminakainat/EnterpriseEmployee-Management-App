import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/constants.dart';
import '../../data/models/employee.dart';
import '../../data/models/user.dart';
import '../../logic/auth_provider.dart';
import '../../logic/employee_provider.dart';

class EmployeeDirectoryScreen extends ConsumerStatefulWidget {
  const EmployeeDirectoryScreen({super.key});

  @override
  ConsumerState<EmployeeDirectoryScreen> createState() =>
      _EmployeeDirectoryScreenState();
}

class _EmployeeDirectoryScreenState
    extends ConsumerState<EmployeeDirectoryScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(employeeStateProvider.notifier).fetchNextPage();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(employeeStateProvider.notifier).updateSearchQuery(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final state = ref.watch(employeeStateProvider);
    final notifier = ref.read(employeeStateProvider.notifier);

    final isAdmin = user?.role == UserRole.admin;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          notifier.updateSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
              ),
            ),
          ),

          _buildFilterRow(state, notifier),

          Expanded(
            child: state.isLoading && state.employees.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.employees.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () => notifier.fetchEmployees(isRefresh: true),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          state.employees.length +
                          (state.isMoreLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.employees.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final employee = state.employees[index];
                        return _buildEmployeeCard(employee);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                context.push('/employee/add');
              },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildFilterRow(EmployeeState state, EmployeeNotifier notifier) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
      child: Row(
        children: [
          _buildDropdownFilter(
            value: state.selectedDepartment,
            items: [
              'All',
              'IT',
              'HR',
              'Finance',
              'Operations',
              'Engineering',
              'Design',
              'Sales',
            ],
            label: 'Dept',
            onChanged: (val) {
              if (val != null) notifier.updateFilters(department: val);
            },
          ),
          const SizedBox(width: 8),

          _buildDropdownFilter(
            value: state.selectedRole,
            items: ['All', 'Admin', 'Manager', 'Employee'],
            label: 'Role',
            onChanged: (val) {
              if (val != null) notifier.updateFilters(role: val);
            },
          ),
          const SizedBox(width: 8),

          _buildDropdownFilter(
            value: state.selectedStatus,
            items: ['All', 'Active', 'OnLeave', 'Inactive'],
            label: 'Status',
            onChanged: (val) {
              if (val != null) notifier.updateFilters(status: val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String value,
    required List<String> items,
    required String label,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                '$label: $item',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.arrow_drop_down, size: 18),
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(EmployeeModel employee) {
    Color statusColor = AppColors.success;
    if (employee.status == EmployeeStatus.onLeave)
      statusColor = AppColors.warning;
    if (employee.status == EmployeeStatus.inactive)
      statusColor = AppColors.error;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      elevation: 0,
      child: ListTile(
        onTap: () {
          context.push('/employee/${employee.id}', extra: employee);
        },
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary.withOpacity(0.05),
          backgroundImage: employee.avatarUrl != null
              ? NetworkImage(employee.avatarUrl!)
              : null,
          child: employee.avatarUrl == null
              ? Text(employee.name.substring(0, 1))
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                employee.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text('${employee.role.label} • ${employee.department}'),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.phone_outlined,
                  size: 14,
                  color: AppColors.lightTextSecondary,
                ),
                const SizedBox(width: 4),
                Text(employee.phone, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.lightTextSecondary,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.lightTextSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No employees found matching the filters.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              _searchController.clear();
              ref.read(employeeStateProvider.notifier).updateSearchQuery('');
              ref
                  .read(employeeStateProvider.notifier)
                  .updateFilters(department: 'All', role: 'All', status: 'All');
            },
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }
}
