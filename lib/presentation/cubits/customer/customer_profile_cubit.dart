// Presentation - Customer profile cubit.
//
// Manages customer profile state including fetching, updating profile,
// updating address, and applying referral codes.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/usecase/usecase.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/usecases/customer/apply_referral.dart';
import '../../../domain/usecases/customer/get_profile.dart';
import '../../../domain/usecases/customer/update_address.dart';
import '../../../domain/usecases/customer/update_profile.dart';
import 'customer_profile_state.dart';

/// Cubit that manages the customer profile lifecycle.
///
/// Handles profile fetching, name updates, address updates,
/// and referral code application.
@injectable
class CustomerProfileCubit extends Cubit<CustomerProfileState> {
  final GetProfile _getProfile;
  final UpdateProfile _updateProfile;
  final UpdateAddress _updateAddress;
  final ApplyReferral _applyReferral;

  /// Creates a [CustomerProfileCubit].
  CustomerProfileCubit({
    required GetProfile getProfile,
    required UpdateProfile updateProfile,
    required UpdateAddress updateAddress,
    required ApplyReferral applyReferral,
  })  : _getProfile = getProfile,
        _updateProfile = updateProfile,
        _updateAddress = updateAddress,
        _applyReferral = applyReferral,
        super(const CustomerProfileInitial());

  /// Fetches the current customer's profile.
  Future<void> loadProfile() async {
    emit(const CustomerProfileLoading());
    final result = await _getProfile(const NoParams());
    result.fold(
      onSuccess: (customer) {
        emit(CustomerProfileLoaded(customer: customer));
      },
      onFailure: (failure) {
        emit(CustomerProfileError(message: failure.message));
      },
    );
  }

  /// Updates the customer's full name.
  Future<void> updateProfile({String? fullName}) async {
    final currentCustomer = _currentCustomer;
    if (currentCustomer != null) {
      emit(CustomerProfileUpdating(customer: currentCustomer));
    } else {
      emit(const CustomerProfileLoading());
    }
    final result = await _updateProfile(
      UpdateProfileParams(fullName: fullName),
    );
    result.fold(
      onSuccess: (customer) {
        emit(CustomerProfileLoaded(customer: customer));
      },
      onFailure: (failure) {
        emit(CustomerProfileError(
          message: failure.message,
          customer: currentCustomer,
        ));
      },
    );
  }

  /// Updates the customer's delivery address.
  Future<void> updateAddress({
    required String addressText,
    String? landmark,
    String? area,
  }) async {
    final currentCustomer = _currentCustomer;
    if (currentCustomer != null) {
      emit(CustomerProfileUpdating(customer: currentCustomer));
    } else {
      emit(const CustomerProfileLoading());
    }
    final result = await _updateAddress(UpdateAddressParams(
      addressText: addressText,
      landmark: landmark,
      area: area,
    ));
    result.fold(
      onSuccess: (customer) {
        emit(CustomerProfileLoaded(customer: customer));
      },
      onFailure: (failure) {
        emit(CustomerProfileError(
          message: failure.message,
          customer: currentCustomer,
        ));
      },
    );
  }

  /// Applies a referral code for the current customer.
  Future<void> applyReferral(String referralCode) async {
    final currentCustomer = _currentCustomer;
    if (currentCustomer != null) {
      emit(CustomerProfileUpdating(customer: currentCustomer));
    } else {
      emit(const CustomerProfileLoading());
    }
    final result = await _applyReferral(
      ApplyReferralParams(referralCode: referralCode),
    );
    result.fold(
      onSuccess: (_) async {
        // Re-fetch profile to get updated points balance.
        final profileResult = await _getProfile(const NoParams());
        profileResult.fold(
          onSuccess: (customer) {
            emit(CustomerReferralApplied(customer: customer));
          },
          onFailure: (failure) {
            emit(CustomerProfileError(
              message: failure.message,
              customer: currentCustomer,
            ));
          },
        );
      },
      onFailure: (failure) {
        emit(CustomerProfileError(
          message: failure.message,
          customer: currentCustomer,
        ));
      },
    );
  }

  /// Extracts the current customer from state if available.
  Customer? get _currentCustomer {
    final s = state;
    if (s is CustomerProfileLoaded) return s.customer;
    if (s is CustomerProfileUpdating) return s.customer;
    if (s is CustomerProfileError) return s.customer;
    if (s is CustomerReferralApplied) return s.customer;
    return null;
  }
}