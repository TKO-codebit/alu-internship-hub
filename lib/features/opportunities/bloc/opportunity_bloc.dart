import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/opportunity_model.dart';
import '../../../data/repositories/firebase_repositories.dart';

part 'opportunity_event.dart';
part 'opportunity_state.dart';

class OpportunityBloc extends Bloc<OpportunityEvent, OpportunityState> {
  OpportunityBloc({required OpportunityRepository repository})
      : _repository = repository,
        super(const OpportunityState()) {
    on<OpportunitySubscriptionRequested>(_onSubscribe);
    on<OpportunityFilterChanged>(_onFilterChanged);
    on<OpportunityCreateRequested>(_onCreate);
    on<OpportunityToggleRequested>(_onToggle);
    on<_OpportunityStreamUpdated>(_onStreamUpdated);
    on<_OpportunityStreamFailed>(_onStreamFailed);
  }

  final OpportunityRepository _repository;
  StreamSubscription<List<OpportunityModel>>? _subscription;

  Future<void> _onSubscribe(
    OpportunitySubscriptionRequested event,
    Emitter<OpportunityState> emit,
  ) async {
    await _subscription?.cancel();
    emit(state.copyWith(status: OpportunityStatus.loading));

    _subscription = _repository
        .watchActiveOpportunities(
          category: state.selectedCategory,
          campus: state.selectedCampus,
          searchQuery: state.searchQuery,
        )
        .listen(
          (opportunities) => add(_OpportunityStreamUpdated(opportunities)),
          onError: (Object error) => add(_OpportunityStreamFailed(error.toString())),
        );
  }

  void _onFilterChanged(OpportunityFilterChanged event, Emitter<OpportunityState> emit) {
    emit(
      state.copyWith(
        selectedCategory: event.category ?? state.selectedCategory,
        selectedCampus: event.campus ?? state.selectedCampus,
        searchQuery: event.searchQuery ?? state.searchQuery,
      ),
    );
    add(const OpportunitySubscriptionRequested());
  }

  Future<void> _onCreate(
    OpportunityCreateRequested event,
    Emitter<OpportunityState> emit,
  ) async {
    emit(state.copyWith(actionStatus: OpportunityActionStatus.submitting));
    try {
      await _repository.createOpportunity(event.opportunity);
      emit(state.copyWith(actionStatus: OpportunityActionStatus.success));
    } catch (error) {
      emit(state.copyWith(
        actionStatus: OpportunityActionStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onToggle(
    OpportunityToggleRequested event,
    Emitter<OpportunityState> emit,
  ) async {
    try {
      await _repository.toggleActive(event.opportunityId, event.isActive);
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  void _onStreamUpdated(
    _OpportunityStreamUpdated event,
    Emitter<OpportunityState> emit,
  ) {
    emit(state.copyWith(
      status: OpportunityStatus.success,
      opportunities: event.opportunities,
    ));
  }

  void _onStreamFailed(
    _OpportunityStreamFailed event,
    Emitter<OpportunityState> emit,
  ) {
    emit(state.copyWith(
      status: OpportunityStatus.failure,
      errorMessage: event.message,
    ));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

class _OpportunityStreamUpdated extends OpportunityEvent {
  const _OpportunityStreamUpdated(this.opportunities);
  final List<OpportunityModel> opportunities;
}

class _OpportunityStreamFailed extends OpportunityEvent {
  const _OpportunityStreamFailed(this.message);
  final String message;
}
