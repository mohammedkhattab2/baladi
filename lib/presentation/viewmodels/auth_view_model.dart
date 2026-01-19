/// Authentication ViewModel.
///
/// Handles authentication UI state and orchestrates auth use cases.
/// This ViewModel does NOT contain business logic - it delegates
/// to use cases and domain services.
library;
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_customer.dart';
import '../base/base_view_model.dart';
import '../state/ui_state.dart';

/// ViewModel for authentication screens.
class AuthViewModel extends BaseViewModel {
  final LoginCustomer _loginCustomer;

  AuthViewModel({
    required LoginCustomer loginCustomer,
  }) : _loginCustomer = loginCustomer;

  /// Current authenticated user.
  User? _currentUser;
  User? get currentUser => _currentUser;

  /// UI state for auth operations.
  UiState<User> _authState = const InitialState();
  UiState<User> get authState => _authState;

  /// Phone number for login.
  String _phoneNumber = '';
  String get phoneNumber => _phoneNumber;

  /// PIN for login.
  String _pin = '';
  String get pin => _pin;

  /// Name for registration.
  String _name = '';
  String get name => _name;

  /// Security answer for registration/recovery.
  String _securityAnswer = '';
  String get securityAnswer => _securityAnswer;

  /// Whether to show PIN entry.
  bool _showPinEntry = false;
  bool get showPinEntry => _showPinEntry;

  /// Whether user is in registration mode.
  bool _isRegistering = false;
  bool get isRegistering => _isRegistering;

  /// Validation error messages.
  String? _phoneError;
  String? get phoneError => _phoneError;

  String? _pinError;
  String? get pinError => _pinError;

  String? _nameError;
  String? get nameError => _nameError;

  String? _securityAnswerError;
  String? get securityAnswerError => _securityAnswerError;

  /// Update phone number.
  void setPhoneNumber(String value) {
    _phoneNumber = value;
    _phoneError = null;
    notifyListenersSafe();
  }

  /// Update PIN.
  void setPin(String value) {
    _pin = value;
    _pinError = null;
    notifyListenersSafe();
  }

  /// Update name.
  void setName(String value) {
    _name = value;
    _nameError = null;
    notifyListenersSafe();
  }

  /// Update security answer.
  void setSecurityAnswer(String value) {
    _securityAnswer = value;
    _securityAnswerError = null;
    notifyListenersSafe();
  }

  /// Toggle registration mode.
  void toggleRegistrationMode() {
    _isRegistering = !_isRegistering;
    _clearValidationErrors();
    notifyListenersSafe();
  }

  /// Proceed to PIN entry.
  void proceedToPinEntry() {
    if (_validatePhoneNumber()) {
      _showPinEntry = true;
      notifyListenersSafe();
    }
  }

  /// Go back to phone entry.
  void backToPhoneEntry() {
    _showPinEntry = false;
    _pin = '';
    notifyListenersSafe();
  }

  /// Login with phone and PIN.
  Future<bool> login() async {
    if (!_validateLogin()) {
      return false;
    }

    _authState = const LoadingState();
    notifyListenersSafe();

    final result = await _loginCustomer(
      LoginCustomerParams(
        mobileNumber: _phoneNumber,
        pin: _pin,
      ),
    );

    return result.fold(
      onSuccess: (user) {
        _currentUser = user;
        _authState = SuccessState(user);
        notifyListenersSafe();
        return true;
      },
      onFailure: (failure) {
        _authState = ErrorState.fromFailure(failure);
        notifyListenersSafe();
        return false;
      },
    );
  }

  /// Register new customer.
  Future<bool> register() async {
    if (!_validateRegistration()) {
      return false;
    }

    _authState = const LoadingState();
    notifyListenersSafe();

    // Note: Registration use case would be injected similarly
    // For now, we'll just simulate the flow
    _authState = const ErrorState(message: 'Registration not implemented yet');
    notifyListenersSafe();
    return false;
  }

  /// Verify security answer for PIN recovery.
  Future<bool> verifySecurityAnswer() async {
    if (_securityAnswer.isEmpty) {
      _securityAnswerError = 'Please enter your security answer';
      notifyListenersSafe();
      return false;
    }

    setLoading();
    
    // Note: Verify security answer use case would be injected
    setError('PIN recovery not implemented yet');
    return false;
  }

  /// Reset PIN after security verification.
  Future<bool> resetPin(String newPin) async {
    if (newPin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(newPin)) {
      _pinError = 'PIN must be exactly 4 digits';
      notifyListenersSafe();
      return false;
    }

    setLoading();
    
    // Note: Reset PIN use case would be injected
    setError('PIN reset not implemented yet');
    return false;
  }

  /// Logout current user.
  Future<void> logout() async {
    setLoading();
    
    _currentUser = null;
    _authState = const InitialState();
    _clearAllFields();
    
    setSuccess();
  }

  /// Validate phone number.
  bool _validatePhoneNumber() {
    if (_phoneNumber.isEmpty) {
      _phoneError = 'Phone number is required';
      notifyListenersSafe();
      return false;
    }

    // Egyptian phone format: 01xxxxxxxxx (11 digits)
    if (!RegExp(r'^01[0125]\d{8}$').hasMatch(_phoneNumber)) {
      _phoneError = 'Enter a valid Egyptian phone number';
      notifyListenersSafe();
      return false;
    }

    return true;
  }

  /// Validate login fields.
  bool _validateLogin() {
    bool isValid = true;

    if (!_validatePhoneNumber()) {
      isValid = false;
    }

    if (_pin.isEmpty) {
      _pinError = 'PIN is required';
      isValid = false;
    } else if (_pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(_pin)) {
      _pinError = 'PIN must be exactly 4 digits';
      isValid = false;
    }

    if (!isValid) {
      notifyListenersSafe();
    }

    return isValid;
  }

  /// Validate registration fields.
  bool _validateRegistration() {
    bool isValid = _validateLogin();

    if (_name.isEmpty) {
      _nameError = 'Name is required';
      isValid = false;
    } else if (_name.length < 2) {
      _nameError = 'Name must be at least 2 characters';
      isValid = false;
    }

    if (_securityAnswer.isEmpty) {
      _securityAnswerError = 'Security answer is required';
      isValid = false;
    } else if (_securityAnswer.length < 2) {
      _securityAnswerError = 'Answer must be at least 2 characters';
      isValid = false;
    }

    if (!isValid) {
      notifyListenersSafe();
    }

    return isValid;
  }

  /// Clear validation errors.
  void _clearValidationErrors() {
    _phoneError = null;
    _pinError = null;
    _nameError = null;
    _securityAnswerError = null;
  }

  /// Clear all fields.
  void _clearAllFields() {
    _phoneNumber = '';
    _pin = '';
    _name = '';
    _securityAnswer = '';
    _showPinEntry = false;
    _isRegistering = false;
    _clearValidationErrors();
  }

  /// Reset view model state.
  @override
  void reset() {
    super.reset();
    _authState = const InitialState();
    _currentUser = null;
    _clearAllFields();
  }
}