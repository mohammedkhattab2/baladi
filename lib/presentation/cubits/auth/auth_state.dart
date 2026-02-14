// Presentation - Auth cubit states.
//
// Defines all possible states for the authentication flow
// including login, registration, PIN recovery, and session management.

import 'package:equatable/equatable.dart';

import '../../../domain/entities/customer.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/enums/user_role.dart';

/// Base state for the auth cubit.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state — auth status not yet determined.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Checking if the user has an existing session.
class AuthCheckingSession extends AuthState {
  const AuthCheckingSession();
}

/// An auth operation (login, register, recover) is in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated.
class AuthAuthenticated extends AuthState {
  /// The authenticated user.
  final User user;

  /// The user's role.
  final UserRole role;

  /// Customer profile (only for customer role).
  final Customer? customer;

  const AuthAuthenticated({
    required this.user,
    required this.role,
    this.customer,
  });

  @override
  List<Object?> get props => [user, role, customer];
}

/// User is not authenticated.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// An auth error occurred.
class AuthError extends AuthState {
  /// The error message to display.
  final String message;

  /// Field-level validation errors (for registration forms).
  final Map<String, String>? fieldErrors;

  const AuthError({
    required this.message,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, fieldErrors];
}

/// PIN recovery request was successful.
class AuthPinRecoverySent extends AuthState {
  /// Informational message from the backend.
  final String message;

  const AuthPinRecoverySent({required this.message});

  @override
  List<Object?> get props => [message];
}
class AuthRecoveryQuestionLoaded extends AuthState {
  /// The registered phone number.
  final String phone;

  /// The security question to display.
  final String securityQuestion;

  const AuthRecoveryQuestionLoaded({
    required this.phone,
    required this.securityQuestion,
  });

  @override
  List<Object?> get props => [phone, securityQuestion];
}

/// PIN was reset successfully.
class AuthPinResetSuccess extends AuthState {
  final String message;

  const AuthPinResetSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}