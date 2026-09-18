import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/leave_request.dart';
import '../data/repositories/leave_repository_impl.dart';
import '../data/repositories/firebase_leave_repository_impl.dart';
import '../domain/repositories/leave_repository.dart';
import 'auth_provider.dart';

class LeaveState {
  final List<LeaveRequestModel> leaves;
  final Map<String, int> balances;
  final bool isLoading;
  final bool isActionLoading;
  final int page;
  final int totalPages;
  final String? errorMessage;

  LeaveState({
    required this.leaves,
    required this.balances,
    required this.isLoading,
    required this.isActionLoading,
    required this.page,
    required this.totalPages,
    this.errorMessage,
  });

  factory LeaveState.initial() {
    return LeaveState(
      leaves: [],
      balances: {'annual': 0, 'sick': 0, 'casual': 0},
      isLoading: false,
      isActionLoading: false,
      page: 1,
      totalPages: 1,
    );
  }

  LeaveState copyWith({
    List<LeaveRequestModel>? leaves,
    Map<String, int>? balances,
    bool? isLoading,
    bool? isActionLoading,
    int? page,
    int? totalPages,
    String? errorMessage,
  }) {
    return LeaveState(
      leaves: leaves ?? this.leaves,
      balances: balances ?? this.balances,
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      errorMessage: errorMessage,
    );
  }
}

final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  final useFirebase = ref.watch(firebaseBackendProvider);
  if (useFirebase && Firebase.apps.isNotEmpty) {
    return FirebaseLeaveRepositoryImpl(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    );
  } else {
    final apiClient = ref.watch(apiClientProvider);
    return LeaveRepositoryImpl(apiClient);
  }
});

class LeaveNotifier extends StateNotifier<LeaveState> {
  final LeaveRepository _repository;

  LeaveNotifier(this._repository) : super(LeaveState.initial()) {
    initLeaveState();
  }

  Future<void> initLeaveState() async {
    state = state.copyWith(isLoading: true);
    try {
      final balances = await _repository.getLeaveBalances();
      state = state.copyWith(balances: balances);
      await fetchLeaves(isRefresh: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> fetchLeaves({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(page: 1, leaves: [], isLoading: true);
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final result = await _repository.getLeaveRequests(
        page: state.page,
        limit: 10,
      );

      state = state.copyWith(
        leaves: isRefresh
            ? (result['leaves'] as List<LeaveRequestModel>)
            : [
                ...state.leaves,
                ...(result['leaves'] as List<LeaveRequestModel>),
              ],
        totalPages: result['totalPages'] as int,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> fetchNextPage() async {
    if (state.page >= state.totalPages) return;
    state = state.copyWith(page: state.page + 1);
    await fetchLeaves();
  }

  Future<void> applyLeave({
    required String leaveType,
    required String startDate,
    required String endDate,
    required String reason,
    String? attachmentName,
    String? attachmentPath,
  }) async {
    state = state.copyWith(isActionLoading: true);
    try {
      final newLeave = await _repository.applyForLeave(
        leaveType: leaveType,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        attachmentName: attachmentName,
        attachmentPath: attachmentPath,
      );
      final updatedBalances = Map<String, int>.from(state.balances);
      final duration =
          DateTime.parse(endDate).difference(DateTime.parse(startDate)).inDays +
          1;
      if (updatedBalances.containsKey(leaveType)) {
        updatedBalances[leaveType] = (updatedBalances[leaveType]! - duration)
            .clamp(0, 30);
      }

      state = state.copyWith(
        leaves: [newLeave, ...state.leaves],
        balances: updatedBalances,
        isActionLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> reviewLeave(String id, bool approve, String? comment) async {
    state = state.copyWith(isActionLoading: true);
    try {
      final updated = approve
          ? await _repository.approveLeave(id, comment)
          : await _repository.rejectLeave(id, comment);

      final updatedLeaves = state.leaves
          .map((l) => l.id == id ? updated : l)
          .toList();
      state = state.copyWith(leaves: updatedLeaves, isActionLoading: false);
    } catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }
}

final leaveStateProvider = StateNotifierProvider<LeaveNotifier, LeaveState>((
  ref,
) {
  final repository = ref.watch(leaveRepositoryProvider);
  return LeaveNotifier(repository);
});
