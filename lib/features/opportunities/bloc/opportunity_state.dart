part of 'opportunity_bloc.dart';

enum OpportunityStatus { initial, loading, success, failure }

enum OpportunityActionStatus { idle, submitting, success, failure }

class OpportunityState extends Equatable {
  const OpportunityState({
    this.status = OpportunityStatus.initial,
    this.actionStatus = OpportunityActionStatus.idle,
    this.opportunities = const [],
    this.selectedCategory = 'All',
    this.selectedCampus = 'All',
    this.searchQuery = '',
    this.errorMessage,
  });

  final OpportunityStatus status;
  final OpportunityActionStatus actionStatus;
  final List<OpportunityModel> opportunities;
  final String selectedCategory;
  final String selectedCampus;
  final String searchQuery;
  final String? errorMessage;

  OpportunityState copyWith({
    OpportunityStatus? status,
    OpportunityActionStatus? actionStatus,
    List<OpportunityModel>? opportunities,
    String? selectedCategory,
    String? selectedCampus,
    String? searchQuery,
    String? errorMessage,
  }) {
    return OpportunityState(
      status: status ?? this.status,
      actionStatus: actionStatus ?? this.actionStatus,
      opportunities: opportunities ?? this.opportunities,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedCampus: selectedCampus ?? this.selectedCampus,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        actionStatus,
        opportunities,
        selectedCategory,
        selectedCampus,
        searchQuery,
        errorMessage,
      ];
}
