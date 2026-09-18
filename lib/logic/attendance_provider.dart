import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/attendance.dart';
import '../data/repositories/attendance_repository_impl.dart';
import '../data/repositories/firebase_attendance_repository_impl.dart';
import '../domain/repositories/attendance_repository.dart';
import 'auth_provider.dart';
import 'attendance_bloc.dart';

class AttendanceState {
  final AttendanceModel? todayRecord;
  final List<AttendanceModel> history;
  final bool isLoading;
  final bool isActionLoading;
  final int page;
  final int totalPages;
  final String? errorMessage;

  AttendanceState({
    this.todayRecord,
    required this.history,
    required this.isLoading,
    required this.isActionLoading,
    required this.page,
    required this.totalPages,
    this.errorMessage,
  });

  factory AttendanceState.initial() {
    return AttendanceState(
      history: [],
      isLoading: false,
      isActionLoading: false,
      page: 1,
      totalPages: 1,
    );
  }

  AttendanceState copyWith({
    AttendanceModel? todayRecord,
    bool clearTodayRecord = false,
    List<AttendanceModel>? history,
    bool? isLoading,
    bool? isActionLoading,
    int? page,
    int? totalPages,
    String? errorMessage,
  }) {
    return AttendanceState(
      todayRecord: clearTodayRecord ? null : (todayRecord ?? this.todayRecord),
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      errorMessage: errorMessage,
    );
  }
}

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final useFirebase = ref.watch(firebaseBackendProvider);
  if (useFirebase && Firebase.apps.isNotEmpty) {
    return FirebaseAttendanceRepositoryImpl(FirebaseFirestore.instance, FirebaseAuth.instance);
  } else {
    final apiClient = ref.watch(apiClientProvider);
    return AttendanceRepositoryImpl(apiClient);
  }
});

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final AttendanceRepository _repository;

  AttendanceNotifier(this._repository) : super(AttendanceState.initial()) {
    initAttendance();
  }

  Future<void> initAttendance() async {
    state = state.copyWith(isLoading: true);
    try {
      final today = await _repository.getTodayStatus();
      state = state.copyWith(todayRecord: today, isLoading: false);
      await fetchHistory(isRefresh: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> fetchHistory({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(page: 1, history: []);
    }

    try {
      final result = await _repository.getAttendanceHistory(
        page: state.page,
        limit: 10,
      );

      state = state.copyWith(
        history: isRefresh
            ? (result['history'] as List<AttendanceModel>)
            : [...state.history, ...(result['history'] as List<AttendanceModel>)],
        totalPages: result['totalPages'] as int,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> fetchNextHistoryPage() async {
    if (state.page >= state.totalPages) return;
    state = state.copyWith(page: state.page + 1);
    await fetchHistory();
  }

  Future<void> checkIn(double lat, double lng) async {
    state = state.copyWith(isActionLoading: true, errorMessage: null);
    try {
      final record = await _repository.checkIn(latitude: lat, longitude: lng);
      state = state.copyWith(
        todayRecord: record,
        isActionLoading: false,
        history: [record, ...state.history],
      );
    } catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> checkOut() async {
    state = state.copyWith(isActionLoading: true, errorMessage: null);
    try {
      final record = await _repository.checkOut();
      
      final updatedHistory = state.history.map((h) => h.id == record.id ? record : h).toList();

      state = state.copyWith(
        todayRecord: record,
        isActionLoading: false,
        history: updatedHistory,
      );
    } catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }
}

final attendanceStateProvider = StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  final repository = ref.watch(attendanceRepositoryProvider);
  return AttendanceNotifier(repository);
});

final attendanceBlocProvider = Provider<AttendanceBloc>((ref) {
  final repository = ref.watch(attendanceRepositoryProvider);
  final bloc = AttendanceBloc(repository);
  ref.onDispose(() => bloc.close());
  return bloc;
});
