// Presentation - Auth cubit.
//
// Manages authentication state including login, registration,
// PIN recovery, session checking, and logout.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/enums/user_role.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/auth/login_customer.dart';
import '../../../domain/usecases/auth/login_user.dart';
import '../../../domain/usecases/auth/logout.dart';
import '../../../domain/usecases/auth/recover_pin.dart';
import '../../../domain/usecases/auth/register_customer.dart';
import 'auth_state.dart';

/// Cubit that manages the authentication lifecycle.
///
/// Handles customer registration/login (phone + PIN),
/// staff login (username + password + role), PIN recovery,
/// session persistence, and logout.
@injectable
class AuthCubit extends Cubit<AuthState> {
  final RegisterCustomer _registerCustomer;
  final LoginCustomer _loginCustomer;
  final LoginUser _loginUser;
  final Logout _logout;
  final RecoverPin _recoverPin;
  final AuthRepository _authRepository;

  /// Creates an [AuthCubit].
  AuthCubit({
    required RegisterCustomer registerCustomer,
    required LoginCustomer loginCustomer,
    required LoginUser loginUser,
    required Logout logout,
    required RecoverPin recoverPin,
    required AuthRepository authRepository,
  })  : _registerCustomer = registerCustomer,
        _loginCustomer = loginCustomer,
        _loginUser = loginUser,
        _logout = logout,
        _recoverPin = recoverPin,
        _authRepository = authRepository,
        super(const AuthInitial());

  /// Checks if there is an existing authenticated session.
  Future<void> checkAuthStatus() async {
    emit(const AuthCheckingSession());
    final isAuthenticated = await _authRepository.isAuthenticated();
    if (!isAuthenticated) {
      emit(const AuthUnauthenticated());
      return;
    }
    final role = await _authRepository.getStoredUserRole();
    if (role == null) {
      emit(const AuthUnauthenticated());
      return;
    }
    // We have stored credentials but no full user object in the cubit.
    // Emit authenticated with minimal info; screens can fetch full profiles.
    emit(AuthAuthenticated(
      user: _placeholderUser(role),
      role: role,
    ));
  }

  /// Registers a new customer.
  Future<void> registerCustomer({
    required String phone,
    required String pin,
    required String fullName,
    String? referralCode,
  }) async {
    emit(const AuthLoading());
    final result = await _registerCustomer(RegisterCustomerParams(
      phone: phone,
      pin: pin,
      fullName: fullName,
      referralCode: referralCode,
    ));
    result.fold(
      onSuccess: (authResult) {
        emit(AuthAuthenticated(
          user: authResult.user,
          role: UserRole.customer,
          customer: authResult.customer,
        ));
      },
      onFailure: (failure) {
        emit(AuthError(
          message: failure.message,
          fieldErrors:
              failure is ValidationFailure ? failure.fieldErrors : null,
        ));
      },
    );
  }

  /// Logs in a customer with phone and PIN.
  Future<void> loginCustomer({
    required String phone,
    required String pin,
  }) async {
    emit(const AuthLoading());
    final result = await _loginCustomer(LoginCustomerParams(
      phone: phone,
      pin: pin,
    ));
    result.fold(
      onSuccess: (authResult) {
        emit(AuthAuthenticated(
          user: authResult.user,
          role: UserRole.customer,
          customer: authResult.customer,
        ));
      },
      onFailure: (failure) {
        emit(AuthError(
          message: failure.message,
          fieldErrors:
              failure is ValidationFailure ? failure.fieldErrors : null,
        ));
      },
    );
  }

  /// Logs in a staff user (shop, rider, or admin).
  Future<void> loginUser({
    required String username,
    required String password,
    required UserRole role,
  }) async {
    emit(const AuthLoading());
    final result = await _loginUser(LoginUserParams(
      username: username,
      password: password,
      role: role,
    ));
    result.fold(
      onSuccess: (authResult) {
        emit(AuthAuthenticated(
          user: authResult.user,
          role: role,
          customer: authResult.customer,
        ));
      },
      onFailure: (failure) {
        emit(AuthError(
          message: failure.message,
          fieldErrors:
              failure is ValidationFailure ? failure.fieldErrors : null,
        ));
      },
    );
  }

  /// Initiates PIN recovery for a customer.
  Future<void> recoverPin({required String phone}) async {
    emit(const AuthLoading());
    final result = await _recoverPin(RecoverPinParams(phone: phone));
    result.fold(
      onSuccess: (_) {
        emit(const AuthPinRecoverySent(
          message: 'تم إرسال طلب استعادة الرمز بنجاح',
        ));
      },
      onFailure: (failure) {
        emit(AuthError(message: failure.message));
      },
    );
  }

  /// Logs out the current user and clears session data.
  Future<void> logout() async {
    emit(const AuthLoading());
    await _logout(const NoParams());
    emit(const AuthUnauthenticated());
  }

  /// Creates a placeholder [User] for session restore when
  /// we only have role info stored locally.
  static User _placeholderUser(UserRole role) {
    final now = DateTime.now();
    return User(
      id: '',
      role: role,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }
}