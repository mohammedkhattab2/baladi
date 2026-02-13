// Presentation - Customer profile cubit states.
//
// Defines all possible states for the customer profile feature
// including loading, loaded, updating, and error states.

import 'package:equatable/equatable.dart';

import '../../../domain/entities/customer.dart';

/// Base state for the customer profile cubit.
abstract class CustomerProfileState extends Equatable {
  const CustomerProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state — profile not yet loaded.
class CustomerProfileInitial extends CustomerProfileState {
  const CustomerProfileInitial();
}

/// Profile is being fetched or updated.
class CustomerProfileLoading extends CustomerProfileState {
  const CustomerProfileLoading();
}

/// Profile loaded successfully.
class CustomerProfileLoaded extends CustomerProfileState {
  /// The customer profile data.
  final Customer customer;

  const CustomerProfileLoaded({required this.customer});

  @override
  List<Object?> get props => [customer];
}

/// Profile update in progress (shows current data while saving).
class CustomerProfileUpdating extends CustomerProfileState {
  /// The current customer profile data (before update completes).
  final Customer customer;

  const CustomerProfileUpdating({required this.customer});

  @override
  List<Object?> get props => [customer];
}

/// An error occurred while loading or updating the profile.
class CustomerProfileError extends CustomerProfileState {
  /// The error message to display.
  final String message;

  /// The previously loaded customer (if available for retry UI).
  final Customer? customer;

  const CustomerProfileError({
    required this.message,
    this.customer,
  });

  @override
  List<Object?> get props => [message, customer];
}

/// Referral code applied successfully.
class CustomerReferralApplied extends CustomerProfileState {
  /// The updated customer profile after referral application.
  final Customer customer;

  const CustomerReferralApplied({required this.customer});

  @override
  List<Object?> get props => [customer];
}