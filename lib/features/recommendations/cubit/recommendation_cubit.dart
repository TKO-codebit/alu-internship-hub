import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/recommendation_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/firebase_repositories.dart';

class RecommendationCubit extends Cubit<RecommendationState> {
  RecommendationCubit({required RecommendationRepository repository})
      : _repository = repository,
        super(const RecommendationState());

  final RecommendationRepository _repository;
  StreamSubscription<List<RecommendationModel>>? _subscription;

  void watchForStudent(String studentId) {
    _subscription?.cancel();
    emit(state.copyWith(status: RecommendationViewStatus.loading));
    _subscription = _repository.watchStudentRecommendations(studentId).listen(
      (items) => emit(state.copyWith(
        status: RecommendationViewStatus.success,
        recommendations: items,
      )),
      onError: (Object error) => emit(state.copyWith(
        status: RecommendationViewStatus.failure,
        errorMessage: error.toString(),
      )),
    );
  }

  void watchForFacilitator(String facilitatorId) {
    _subscription?.cancel();
    emit(state.copyWith(status: RecommendationViewStatus.loading));
    _subscription = _repository.watchFacilitatorRecommendations(facilitatorId).listen(
      (items) => emit(state.copyWith(
        status: RecommendationViewStatus.success,
        recommendations: items,
      )),
      onError: (Object error) => emit(state.copyWith(
        status: RecommendationViewStatus.failure,
        errorMessage: error.toString(),
      )),
    );
  }

  Future<void> request({
    required UserModel student,
    required UserModel facilitator,
    required String purpose,
    required String message,
  }) async {
    emit(state.copyWith(actionStatus: RecommendationActionStatus.submitting));
    try {
      await _repository.requestRecommendation(
        student: student,
        facilitator: facilitator,
        purpose: purpose,
        message: message,
      );
      emit(state.copyWith(actionStatus: RecommendationActionStatus.success));
    } catch (error) {
      emit(state.copyWith(
        actionStatus: RecommendationActionStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> respond({
    required String recommendationId,
    required String studentId,
    required RecommendationStatus status,
    String? recommendationText,
  }) async {
    try {
      await _repository.respondToRecommendation(
        recommendationId: recommendationId,
        studentId: studentId,
        status: status,
        recommendationText: recommendationText,
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

enum RecommendationViewStatus { initial, loading, success, failure }

enum RecommendationActionStatus { idle, submitting, success, failure }

class RecommendationState extends Equatable {
  const RecommendationState({
    this.status = RecommendationViewStatus.initial,
    this.actionStatus = RecommendationActionStatus.idle,
    this.recommendations = const [],
    this.errorMessage,
  });

  final RecommendationViewStatus status;
  final RecommendationActionStatus actionStatus;
  final List<RecommendationModel> recommendations;
  final String? errorMessage;

  RecommendationState copyWith({
    RecommendationViewStatus? status,
    RecommendationActionStatus? actionStatus,
    List<RecommendationModel>? recommendations,
    String? errorMessage,
  }) {
    return RecommendationState(
      status: status ?? this.status,
      actionStatus: actionStatus ?? this.actionStatus,
      recommendations: recommendations ?? this.recommendations,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, actionStatus, recommendations, errorMessage];
}
