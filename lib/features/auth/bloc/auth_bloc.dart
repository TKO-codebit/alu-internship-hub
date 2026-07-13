import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/firebase_repositories.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthProfileUpdated>(_onProfileUpdated);
  }

  final AuthRepository _authRepository;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final profile = await _authRepository.getCurrentUserProfile();
      if (profile == null) {
        emit(const AuthUnauthenticated());
      } else {
        emit(AuthAuthenticated(profile));
      }
    } catch (error) {
      emit(AuthFailure(error.toString()));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignUp(AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final profile = await _authRepository.signUp(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        role: event.role,
        campus: event.campus,
        skills: event.skills,
      );
      emit(AuthAuthenticated(profile));
    } catch (error) {
      emit(AuthFailure(error.toString()));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignIn(AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final profile = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(profile));
    } catch (error) {
      emit(AuthFailure(error.toString()));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignOut(AuthSignOutRequested event, Emitter<AuthState> emit) async {
    await _authRepository.signOut();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onProfileUpdated(AuthProfileUpdated event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await _authRepository.updateProfile(event.user);
      emit(AuthAuthenticated(event.user));
    } catch (error) {
      emit(AuthFailure(error.toString()));
    }
  }
}
