part of 'opportunity_bloc.dart';

sealed class OpportunityEvent extends Equatable {
  const OpportunityEvent();

  @override
  List<Object?> get props => [];
}

class OpportunitySubscriptionRequested extends OpportunityEvent {
  const OpportunitySubscriptionRequested();
}

class OpportunityFilterChanged extends OpportunityEvent {
  const OpportunityFilterChanged({
    this.category,
    this.campus,
    this.searchQuery,
  });

  final String? category;
  final String? campus;
  final String? searchQuery;

  @override
  List<Object?> get props => [category, campus, searchQuery];
}

class OpportunityCreateRequested extends OpportunityEvent {
  const OpportunityCreateRequested(this.opportunity);

  final OpportunityModel opportunity;

  @override
  List<Object?> get props => [opportunity];
}

class OpportunityToggleRequested extends OpportunityEvent {
  const OpportunityToggleRequested({
    required this.opportunityId,
    required this.isActive,
  });

  final String opportunityId;
  final bool isActive;

  @override
  List<Object?> get props => [opportunityId, isActive];
}
