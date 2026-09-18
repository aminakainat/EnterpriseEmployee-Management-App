import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/models/attendance.dart';
import '../domain/repositories/attendance_repository.dart';
abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();
  @override
  List<Object?> get props => [];
}

class CheckInRequested extends AttendanceEvent {
  final double latitude;
  final double longitude;
  const CheckInRequested(this.latitude, this.longitude);

  @override
  List<Object?> get props => [latitude, longitude];
}

class CheckOutRequested extends AttendanceEvent {}

abstract class AttendanceBlocState extends Equatable {
  const AttendanceBlocState();
  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceBlocState {}

class AttendanceActionLoading extends AttendanceBlocState {}

class AttendanceActionSuccess extends AttendanceBlocState {
  final AttendanceModel record;
  final String actionType;
  const AttendanceActionSuccess(this.record, this.actionType);

  @override
  List<Object?> get props => [record, actionType];
}

class AttendanceActionError extends AttendanceBlocState {
  final String message;
  const AttendanceActionError(this.message);

  @override
  List<Object?> get props => [message];
}

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceBlocState> {
  final AttendanceRepository _repository;

  AttendanceBloc(this._repository) : super(AttendanceInitial()) {
    on<CheckInRequested>(_onCheckInRequested);
    on<CheckOutRequested>(_onCheckOutRequested);
  }

  Future<void> _onCheckInRequested(
    CheckInRequested event,
    Emitter<AttendanceBlocState> emit,
  ) async {
    emit(AttendanceActionLoading());
    try {
      final record = await _repository.checkIn(
        latitude: event.latitude,
        longitude: event.longitude,
      );
      emit(AttendanceActionSuccess(record, 'Check-In'));
    } catch (e) {
      emit(AttendanceActionError(e.toString().replaceAll('ApiException: ', '')));
    }
  }

  Future<void> _onCheckOutRequested(
    CheckOutRequested event,
    Emitter<AttendanceBlocState> emit,
  ) async {
    emit(AttendanceActionLoading());
    try {
      final record = await _repository.checkOut();
      emit(AttendanceActionSuccess(record, 'Check-Out'));
    } catch (e) {
      emit(AttendanceActionError(e.toString().replaceAll('ApiException: ', '')));
    }
  }
}
