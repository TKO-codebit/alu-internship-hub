import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/firebase_repositories.dart';

class BookmarkCubit extends Cubit<BookmarkState> {
  BookmarkCubit({required BookmarkRepository repository})
      : _repository = repository,
        super(const BookmarkState());

  final BookmarkRepository _repository;
  StreamSubscription<Set<String>>? _subscription;

  void watch(String userId) {
    _subscription?.cancel();
    _subscription = _repository.watchBookmarkIds(userId).listen(
      (ids) => emit(state.copyWith(bookmarkedIds: ids)),
      onError: (Object error) => emit(state.copyWith(errorMessage: error.toString())),
    );
  }

  Future<void> toggle({
    required String userId,
    required String opportunityId,
  }) async {
    final isBookmarked = state.bookmarkedIds.contains(opportunityId);
    emit(state.copyWith(isUpdating: true));
    try {
      await _repository.toggleBookmark(
        userId: userId,
        opportunityId: opportunityId,
        isBookmarked: isBookmarked,
      );
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    } finally {
      emit(state.copyWith(isUpdating: false));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

class BookmarkState extends Equatable {
  const BookmarkState({
    this.bookmarkedIds = const {},
    this.isUpdating = false,
    this.errorMessage,
  });

  final Set<String> bookmarkedIds;
  final bool isUpdating;
  final String? errorMessage;

  BookmarkState copyWith({
    Set<String>? bookmarkedIds,
    bool? isUpdating,
    String? errorMessage,
  }) {
    return BookmarkState(
      bookmarkedIds: bookmarkedIds ?? this.bookmarkedIds,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [bookmarkedIds, isUpdating, errorMessage];
}
