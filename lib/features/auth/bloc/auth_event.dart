part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthSignUpRequested extends AuthEvent {
  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.role,
    required this.campus,
    this.skills = const [],
  });

  final String email;
  final String password;
  final String fullName;
  final UserRole role;
  final String campus;
  final List<String> skills;

  @override
  List<Object?> get props => [email, fullName, role, campus, skills];
}

class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthProfileUpdated extends AuthEvent {
  const AuthProfileUpdated(this.user);

  final UserModel user;

  @override
  List<Object?> get props => [user];
}
