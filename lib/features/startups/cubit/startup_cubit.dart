import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/startup_model.dart';
import '../../../data/repositories/firebase_repositories.dart';

class StartupCubit extends Cubit<StartupState> {
  StartupCubit({required StartupRepository repository})
      : _repository = repository,
        super(const StartupState());

  final StartupRepository _repository;
  StreamSubscription<List<StartupModel>>? _pendingSubscription;

  Future<void> loadForOwner(String ownerId) async {
    emit(state.copyWith(status: StartupViewStatus.loading));
    try {
      final startup = await _repository.getStartupByOwner(ownerId);
      emit(state.copyWith(
        status: StartupViewStatus.success,
        currentStartup: startup,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: StartupViewStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  void watchPendingVerifications() {
    _pendingSubscription?.cancel();
    _pendingSubscription = _repository
        .watchStartups(status: VerificationStatus.pending)
        .listen(
          (startups) => emit(state.copyWith(pendingStartups: startups)),
          onError: (Object error) =>
              emit(state.copyWith(errorMessage: error.toString())),
        );
  }

  Future<void> create({
    required String ownerId,
    required String name,
    required String description,
    required String sector,
    required String campus,
    required int teamSize,
  }) async {
    emit(state.copyWith(actionStatus: StartupActionStatus.submitting));
    try {
      final startup = await _repository.createStartup(
        StartupModel(
          id: '',
          ownerId: ownerId,
          name: name,
          description: description,
          sector: sector,
          campus: campus,
          teamSize: teamSize,
          verificationStatus: VerificationStatus.pending,
          createdAt: DateTime.now(),
        ),
      );
      emit(state.copyWith(
        actionStatus: StartupActionStatus.success,
        currentStartup: startup,
      ));
    } catch (error) {
      emit(state.copyWith(
        actionStatus: StartupActionStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> verify({
    required String startupId,
    required VerificationStatus status,
    String? rejectionReason,
  }) async {
    try {
      await _repository.updateVerification(
        startupId: startupId,
        status: status,
        rejectionReason: rejectionReason,
      );
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  @override
  Future<void> close() {
    _pendingSubscription?.cancel();
    return super.close();
  }
}

enum StartupViewStatus { initial, loading, success, failure }

enum StartupActionStatus { idle, submitting, success, failure }

class StartupState extends Equatable {
  const StartupState({
    this.status = StartupViewStatus.initial,
    this.actionStatus = StartupActionStatus.idle,
    this.currentStartup,
    this.pendingStartups = const [],
    this.errorMessage,
  });

  final StartupViewStatus status;
  final StartupActionStatus actionStatus;
  final StartupModel? currentStartup;
  final List<StartupModel> pendingStartups;
  final String? errorMessage;

  StartupState copyWith({
    StartupViewStatus? status,
    StartupActionStatus? actionStatus,
    StartupModel? currentStartup,
    List<StartupModel>? pendingStartups,
    String? errorMessage,
  }) {
    return StartupState(
      status: status ?? this.status,
      actionStatus: actionStatus ?? this.actionStatus,
      currentStartup: currentStartup ?? this.currentStartup,
      pendingStartups: pendingStartups ?? this.pendingStartups,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, actionStatus, currentStartup, pendingStartups, errorMessage];
}
