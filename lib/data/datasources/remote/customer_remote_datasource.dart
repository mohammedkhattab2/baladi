// Data - Customer remote datasource.
//
// Abstract interface and implementation for customer profile API calls.
// Handles profile retrieval, updates, address management, and referrals.

import 'package:injectable/injectable.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../models/customer_model.dart';

/// Remote datasource contract for customer operations.
abstract class CustomerRemoteDatasource {
  /// Fetches the current customer's profile.
  Future<CustomerModel> getProfile();

  /// Updates the customer's profile.
  Future<CustomerModel> updateProfile({String? fullName});

  /// Updates the customer's delivery address.
  Future<CustomerModel> updateAddress({
    required String addressText,
    String? landmark,
    String? area,
  });

  /// Applies a referral code to the current customer.
  Future<void> applyReferralCode(String referralCode);

  /// Fetches the customer's referral code.
  Future<String> getReferralCode();
}

/// Implementation of [CustomerRemoteDatasource] using [ApiClient].
@LazySingleton(as: CustomerRemoteDatasource)
class CustomerRemoteDatasourceImpl implements CustomerRemoteDatasource {
  final ApiClient _apiClient;

  /// Creates a [CustomerRemoteDatasourceImpl].
  CustomerRemoteDatasourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<CustomerModel> getProfile() async {
    final response = await _apiClient.get(
      ApiEndpoints.customerProfile,
      fromJson: (json) => CustomerModel.fromJson(json),
    );
    return response.data!;
  }

  @override
  Future<CustomerModel> updateProfile({String? fullName}) async {
    final response = await _apiClient.put(
      ApiEndpoints.customerProfile,
      body: {
        if (fullName != null) 'full_name': fullName,
      },
      fromJson: (json) => CustomerModel.fromJson(json),
    );
    return response.data!;
  }

  @override
  Future<CustomerModel> updateAddress({
    required String addressText,
    String? landmark,
    String? area,
  }) async {
    final response = await _apiClient.put(
      ApiEndpoints.customerAddress,
      body: {
        'address_text': addressText,
        if (landmark != null) 'landmark': landmark,
        if (area != null) 'area': area,
      },
      fromJson: (json) => CustomerModel.fromJson(json),
    );
    return response.data!;
  }

  @override
  Future<void> applyReferralCode(String referralCode) async {
    await _apiClient.post(
      ApiEndpoints.customerReferralApply,
      body: {'referral_code': referralCode},
    );
  }

  @override
  Future<String> getReferralCode() async {
    final response = await _apiClient.get(
      ApiEndpoints.customerReferral,
      fromJson: (json) => json['referral_code'] as String,
    );
    return response.data!;
  }
}