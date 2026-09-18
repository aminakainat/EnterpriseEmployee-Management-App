import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/employee.dart';
import '../data/repositories/employee_repository_impl.dart';
import '../data/repositories/firebase_employee_repository_impl.dart';
import '../domain/repositories/employee_repository.dart';
import 'auth_provider.dart';

class EmployeeState {
  final List<EmployeeModel> employees;
  final bool isLoading;
  final bool isMoreLoading;
  final int page;
  final int totalPages;
  final String searchQuery;
  final String selectedDepartment;
  final String selectedRole;
  final String selectedStatus;
  final String? errorMessage;

  EmployeeState({
    required this.employees,
    required this.isLoading,
    required this.isMoreLoading,
    required this.page,
    required this.totalPages,
    required this.searchQuery,
    required this.selectedDepartment,
    required this.selectedRole,
    required this.selectedStatus,
    this.errorMessage,
  });

  factory EmployeeState.initial() {
    return EmployeeState(
      employees: [],
      isLoading: false,
      isMoreLoading: false,
      page: 1,
      totalPages: 1,
      searchQuery: '',
      selectedDepartment: 'All',
      selectedRole: 'All',
      selectedStatus: 'All',
    );
  }

  EmployeeState copyWith({
    List<EmployeeModel>? employees,
    bool? isLoading,
    bool? isMoreLoading,
    int? page,
    int? totalPages,
    String? searchQuery,
    String? selectedDepartment,
    String? selectedRole,
    String? selectedStatus,
    String? errorMessage,
  }) {
    return EmployeeState(
      employees: employees ?? this.employees,
      isLoading: isLoading ?? this.isLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      selectedRole: selectedRole ?? this.selectedRole,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      errorMessage: errorMessage,
    );
  }
}

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  final useFirebase = ref.watch(firebaseBackendProvider);
  if (useFirebase && Firebase.apps.isNotEmpty) {
    return FirebaseEmployeeRepositoryImpl(FirebaseFirestore.instance);
  } else {
    final apiClient = ref.watch(apiClientProvider);
    return EmployeeRepositoryImpl(apiClient);
  }
});

class EmployeeNotifier extends StateNotifier<EmployeeState> {
  final EmployeeRepository _repository;

  EmployeeNotifier(this._repository) : super(EmployeeState.initial()) {
    fetchEmployees();
  }

  Future<void> fetchEmployees({bool isRefresh = false}) async {
    if (state.isLoading || state.isMoreLoading) return;

    if (isRefresh) {
      state = state.copyWith(page: 1, employees: [], isLoading: true);
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final result = await _repository.getEmployees(
        page: state.page,
        search: state.searchQuery,
        department: state.selectedDepartment,
        role: state.selectedRole,
        status: state.selectedStatus,
      );

      state = state.copyWith(
        employees: result['employees'] as List<EmployeeModel>,
        totalPages: result['totalPages'] as int,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isLoading ||
        state.isMoreLoading ||
        state.page >= state.totalPages)
      return;

    state = state.copyWith(isMoreLoading: true);
    final nextPage = state.page + 1;

    try {
      final result = await _repository.getEmployees(
        page: nextPage,
        search: state.searchQuery,
        department: state.selectedDepartment,
        role: state.selectedRole,
        status: state.selectedStatus,
      );

      final List<EmployeeModel> newEmployees =
          result['employees'] as List<EmployeeModel>;

      state = state.copyWith(
        employees: [...state.employees, ...newEmployees],
        page: nextPage,
        totalPages: result['totalPages'] as int,
        isMoreLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isMoreLoading: false, errorMessage: e.toString());
    }
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, page: 1, employees: []);
    fetchEmployees();
  }

  void updateFilters({String? department, String? role, String? status}) {
    state = state.copyWith(
      selectedDepartment: department ?? state.selectedDepartment,
      selectedRole: role ?? state.selectedRole,
      selectedStatus: status ?? state.selectedStatus,
      page: 1,
      employees: [],
    );
    fetchEmployees();
  }

  Future<void> createEmployee(EmployeeModel employee) async {
    try {
      await _repository.createEmployee(employee);
      fetchEmployees(isRefresh: true);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEmployee(String id, Map<String, dynamic> data) async {
    try {
      await _repository.updateEmployee(id, data);
      fetchEmployees(isRefresh: true);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEmployee(String id) async {
    try {
      await _repository.deleteEmployee(id);
      fetchEmployees(isRefresh: true);
    } catch (e) {
      rethrow;
    }
  }
}

final employeeStateProvider =
    StateNotifierProvider<EmployeeNotifier, EmployeeState>((ref) {
      final repository = ref.watch(employeeRepositoryProvider);
      return EmployeeNotifier(repository);
    });
