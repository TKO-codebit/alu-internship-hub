import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/application_model.dart';
import '../../../data/repositories/firebase_repositories.dart';

class ApplicationCubit extends Cubit<ApplicationState> {
  ApplicationCubit({required ApplicationRepository repository})
      : _repository = repository,
        super(const ApplicationState());

  final ApplicationRepository _repository;
  StreamSubscription<List<ApplicationModel>>? _subscription;

  void watchForStudent(String studentId) {
    _subscription?.cancel();
    emit(state.copyWith(status: ApplicationViewStatus.loading));
    _subscription = _repository.watchStudentApplications(studentId).listen(
      (applications) {
        emit(state.copyWith(
          status: ApplicationViewStatus.success,
          applications: applications,
        ));
      },
      onError: (Object error) {
        emit(state.copyWith(
          status: ApplicationViewStatus.failure,
          errorMessage: error.toString(),
        ));
      },
    );
  }

  void watchForStartup(String startupId) {
    _subscription?.cancel();
    emit(state.copyWith(status: ApplicationViewStatus.loading));
    _subscription = _repository.watchStartupApplications(startupId).listen(
      (applications) {
        emit(state.copyWith(
          status: ApplicationViewStatus.success,
          applications: applications,
        ));
      },
      onError: (Object error) {
        emit(state.copyWith(
          status: ApplicationViewStatus.failure,
          errorMessage: error.toString(),
        ));
      },
    );
  }

  Future<bool> hasApplied({
    required String studentId,
    required String opportunityId,
  }) {
    return _repository.hasApplied(
      studentId: studentId,
      opportunityId: opportunityId,
    );
  }

  Future<void> submit(ApplicationModel application) async {
    emit(state.copyWith(submitStatus: ApplicationSubmitStatus.submitting));
    try {
      await _repository.submitApplication(application);
      emit(state.copyWith(submitStatus: ApplicationSubmitStatus.success));
    } catch (error) {
      emit(state.copyWith(
        submitStatus: ApplicationSubmitStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> updateStatus({
    required String applicationId,
    required ApplicationStatus status,
    required String studentId,
    required String opportunityTitle,
  }) async {
    try {
      await _repository.updateStatus(
        applicationId: applicationId,
        status: status,
        studentId: studentId,
        opportunityTitle: opportunityTitle,
      );
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

enum ApplicationViewStatus { initial, loading, success, failure }

enum ApplicationSubmitStatus { idle, submitting, success, failure }

class ApplicationState extends Equatable {
  const ApplicationState({
    this.status = ApplicationViewStatus.initial,
    this.submitStatus = ApplicationSubmitStatus.idle,
    this.applications = const [],
    this.errorMessage,
  });

  final ApplicationViewStatus status;
  final ApplicationSubmitStatus submitStatus;
  final List<ApplicationModel> applications;
  final String? errorMessage;

  ApplicationState copyWith({
    ApplicationViewStatus? status,
    ApplicationSubmitStatus? submitStatus,
    List<ApplicationModel>? applications,
    String? errorMessage,
  }) {
    return ApplicationState(
      status: status ?? this.status,
      submitStatus: submitStatus ?? this.submitStatus,
      applications: applications ?? this.applications,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, submitStatus, applications, errorMessage];
}
