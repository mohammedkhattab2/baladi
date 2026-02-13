// Data - Auth token model with JSON serialization.
//
// Maps between the API JSON representation and the domain AuthTokens / AuthResult classes.

import '../../domain/entities/customer.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'customer_model.dart';
import 'user_model.dart';

/// Data model for [AuthTokens] with JSON serialization support.
class AuthTokensModel extends AuthTokens {
  const AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
  });

  /// Creates an [AuthTokensModel] from a JSON map.
  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }

  /// Creates an [AuthTokensModel] from a domain [AuthTokens] instance.
  factory AuthTokensModel.fromEntity(AuthTokens tokens) {
    return AuthTokensModel(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }
}

/// Data model for [AuthResult] with JSON serialization support.
///
/// Parses the combined login/register response containing user,
/// tokens, and optionally customer profile data.
class AuthResultModel extends AuthResult {
  const AuthResultModel({
    required super.user,
    required super.tokens,
    super.customer,
  });

  /// Creates an [AuthResultModel] from a JSON map.
  ///
  /// Expects a response structure like:
  /// ```json
  /// {
  ///   "user": { ... },
  ///   "tokens": { "access_token": "...", "refresh_token": "..." },
  ///   "customer": { ... }  // optional, only for customer role
  /// }
  /// ```
  factory AuthResultModel.fromJson(Map<String, dynamic> json) {
    final User user = UserModel.fromJson(json['user'] as Map<String, dynamic>);
    final AuthTokens tokens =
        AuthTokensModel.fromJson(json['tokens'] as Map<String, dynamic>);
    final Customer? customer = json['customer'] != null
        ? CustomerModel.fromJson(json['customer'] as Map<String, dynamic>)
        : null;

    return AuthResultModel(
      user: user,
      tokens: tokens,
      customer: customer,
    );
  }

  /// Creates an [AuthResultModel] from a domain [AuthResult] instance.
  factory AuthResultModel.fromEntity(AuthResult result) {
    return AuthResultModel(
      user: result.user,
      tokens: result.tokens,
      customer: result.customer,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'user': UserModel.fromEntity(user).toJson(),
      'tokens': AuthTokensModel.fromEntity(tokens).toJson(),
      'customer': customer != null
          ? CustomerModel.fromEntity(customer!).toJson()
          : null,
    };
  }
}