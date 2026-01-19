/// LoginCustomer use case.
/// 
/// Handles customer authentication with mobile number and PIN.
/// 
/// Architecture note: Use cases orchestrate domain services and
/// repositories. Authentication logic is handled by the auth repository.
library;
import '../../core/result/result.dart' as result;
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../../core/utils/validators.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Parameters for customer login.
class LoginCustomerParams {
  final String mobileNumber;
  final String pin;

  const LoginCustomerParams({
    required this.mobileNumber,
    required this.pin,
  });
}

/// Use case for customer login.
class LoginCustomer implements UseCase<User, LoginCustomerParams> {
  final AuthRepository _authRepository;

  LoginCustomer({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  @override
  Future<result.Result<User>> call(LoginCustomerParams params) async {
    // Step 1: Validate mobile number
    final phoneValidation = Validators.phoneNumber(params.mobileNumber);
    if (!phoneValidation.isValid) {
      return result.Failure(
        ValidationFailure(message: phoneValidation.errorMessage ?? 'Invalid mobile number format'),
      );
    }

    // Step 2: Validate PIN
    final pinValidation = Validators.pin(params.pin);
    if (!pinValidation.isValid) {
      return result.Failure(
        ValidationFailure(message: pinValidation.errorMessage ?? 'PIN must be 4 digits'),
      );
    }

    // Step 3: Authenticate
    return _authRepository.loginWithPin(
      mobileNumber: params.mobileNumber,
      pin: params.pin,
    );
  }
}

/// Use case for customer registration.
class RegisterCustomer implements UseCase<User, RegisterCustomerParams> {
  final AuthRepository _authRepository;

  RegisterCustomer({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  @override
  Future<result.Result<User>> call(RegisterCustomerParams params) async {
    // Step 1: Validate mobile number
    final phoneValidation = Validators.phoneNumber(params.mobileNumber);
    if (!phoneValidation.isValid) {
      return result.Failure(
        ValidationFailure(message: phoneValidation.errorMessage ?? 'Invalid mobile number format'),
      );
    }

    // Step 2: Validate PIN
    final pinValidation = Validators.pin(params.pin);
    if (!pinValidation.isValid) {
      return result.Failure(
        ValidationFailure(message: pinValidation.errorMessage ?? 'PIN must be 4 digits'),
      );
    }

    // Step 3: Validate name
    if (params.name.trim().isEmpty) {
      return result.Failure(
        ValidationFailure(message: 'Name is required'),
      );
    }

    // Step 4: Validate security answer
    if (params.securityAnswer.trim().isEmpty) {
      return result.Failure(
        ValidationFailure(message: 'Security answer is required'),
      );
    }

    // Step 5: Register
    return _authRepository.registerCustomer(
      mobileNumber: params.mobileNumber,
      pin: params.pin,
      name: params.name,
      securityAnswer: params.securityAnswer,
    );
  }
}

/// Parameters for customer registration.
class RegisterCustomerParams {
  final String mobileNumber;
  final String pin;
  final String name;
  final String securityAnswer;

  const RegisterCustomerParams({
    required this.mobileNumber,
    required this.pin,
    required this.name,
    required this.securityAnswer,
  });
}

/// Use case for recovering customer account.
class RecoverCustomerAccount implements UseCase<bool, RecoverAccountParams> {
  final AuthRepository _authRepository;

  RecoverCustomerAccount({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  @override
  Future<result.Result<bool>> call(RecoverAccountParams params) async {
    // Step 1: Validate mobile number
    final phoneValidation = Validators.phoneNumber(params.mobileNumber);
    if (!phoneValidation.isValid) {
      return result.Failure(
        ValidationFailure(message: phoneValidation.errorMessage ?? 'Invalid mobile number format'),
      );
    }

    // Step 2: Validate security answer
    if (params.securityAnswer.trim().isEmpty) {
      return result.Failure(
        ValidationFailure(message: 'Security answer is required'),
      );
    }

    // Step 3: Verify security answer
    return _authRepository.verifySecurityAnswer(
      mobileNumber: params.mobileNumber,
      securityAnswer: params.securityAnswer,
    );
  }
}

/// Parameters for account recovery.
class RecoverAccountParams {
  final String mobileNumber;
  final String securityAnswer;

  const RecoverAccountParams({
    required this.mobileNumber,
    required this.securityAnswer,
  });
}

/// Use case for resetting customer PIN.
class ResetCustomerPin implements UseCase<void, ResetPinParams> {
  final AuthRepository _authRepository;

  ResetCustomerPin({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  @override
  Future<result.Result<void>> call(ResetPinParams params) async {
    // Step 1: Validate mobile number
    final phoneValidation = Validators.phoneNumber(params.mobileNumber);
    if (!phoneValidation.isValid) {
      return result.Failure(
        ValidationFailure(message: phoneValidation.errorMessage ?? 'Invalid mobile number format'),
      );
    }

    // Step 2: Validate new PIN
    final pinValidation = Validators.pin(params.newPin);
    if (!pinValidation.isValid) {
      return result.Failure(
        ValidationFailure(message: pinValidation.errorMessage ?? 'PIN must be 4 digits'),
      );
    }

    // Step 3: Reset PIN
    return _authRepository.resetPin(
      mobileNumber: params.mobileNumber,
      newPin: params.newPin,
    );
  }
}

/// Parameters for PIN reset.
class ResetPinParams {
  final String mobileNumber;
  final String newPin;

  const ResetPinParams({
    required this.mobileNumber,
    required this.newPin,
  });
}