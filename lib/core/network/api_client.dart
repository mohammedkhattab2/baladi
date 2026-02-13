// Core - HTTP client wrapper with interceptors, token injection, and error mapping.
//
// Wraps the `http` package to provide a consistent API for making network
// requests. Automatically injects auth tokens, sets standard headers,
// logs requests/responses in debug mode, and maps HTTP errors to typed exceptions.

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/environment.dart';
import '../error/exceptions.dart';
import 'api_response.dart';

/// A typed HTTP client that handles authentication, logging, and error mapping.
///
/// ```dart
/// final client = ApiClient(
///   baseUrl: EnvironmentConfig.current.apiBaseUrl,
///   authTokenGetter: () => secureStorage.read(key: 'accessToken'),
///   enableLogging: EnvironmentConfig.current.enableLogging,
/// );
///
/// final response = await client.get('/categories');
/// ```
class ApiClient {
  /// The base URL prepended to all request paths.
  final String baseUrl;

  /// Async function that returns the current auth token, or `null` if unauthenticated.
  final Future<String?> Function() authTokenGetter;

  /// Whether to print request/response details to the console.
  final bool enableLogging;

  /// The underlying HTTP client (injectable for testing).
  final http.Client _httpClient;

  /// Connection timeout duration.
  final Duration _timeout;

  /// Creates an [ApiClient].
  ///
  /// [baseUrl] is the root API URL (e.g. `http://10.0.2.2:3000/api/v1`).
  /// [authTokenGetter] returns the current Bearer token.
  /// [enableLogging] toggles console logging of requests/responses.
  /// [httpClient] can be injected for testing; defaults to a new [http.Client].
  /// [timeout] overrides the default connection timeout from [EnvironmentConfig].
  ApiClient({
    required this.baseUrl,
    required this.authTokenGetter,
    this.enableLogging = false,
    http.Client? httpClient,
    Duration? timeout,
  })  : _httpClient = httpClient ?? http.Client(),
        _timeout = timeout ?? EnvironmentConfig.current.connectTimeout;

  // ─── Public HTTP Methods ────────────────────────────────────────────

  /// Performs an HTTP GET request.
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, String>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final uri = _buildUri(path, queryParameters);
    return _executeRequest<T>(
      method: 'GET',
      uri: uri,
      fromJson: fromJson,
    );
  }

  /// Performs an HTTP POST request.
  Future<ApiResponse<T>> post<T>(
    String path, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final uri = _buildUri(path);
    return _executeRequest<T>(
      method: 'POST',
      uri: uri,
      body: body,
      fromJson: fromJson,
    );
  }

  /// Performs an HTTP PUT request.
  Future<ApiResponse<T>> put<T>(
    String path, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final uri = _buildUri(path);
    return _executeRequest<T>(
      method: 'PUT',
      uri: uri,
      body: body,
      fromJson: fromJson,
    );
  }

  /// Performs an HTTP PATCH request.
  Future<ApiResponse<T>> patch<T>(
    String path, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final uri = _buildUri(path);
    return _executeRequest<T>(
      method: 'PATCH',
      uri: uri,
      body: body,
      fromJson: fromJson,
    );
  }

  /// Performs an HTTP DELETE request.
  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final uri = _buildUri(path);
    return _executeRequest<T>(
      method: 'DELETE',
      uri: uri,
      body: body,
      fromJson: fromJson,
    );
  }

  /// Closes the underlying HTTP client. Call when the client is no longer needed.
  void dispose() {
    _httpClient.close();
  }

  // ─── Private Helpers ────────────────────────────────────────────────

  Uri _buildUri(String path, [Map<String, String>? queryParameters]) {
    final url = '$baseUrl$path';
    final uri = Uri.parse(url);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(queryParameters: queryParameters);
    }
    return uri;
  }

  Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Accept-Language': 'ar',
    };

    final token = await authTokenGetter();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<ApiResponse<T>> _executeRequest<T>({
    required String method,
    required Uri uri,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final headers = await _buildHeaders();
      final encodedBody = body != null ? jsonEncode(body) : null;

      _logRequest(method, uri, headers, encodedBody);

      final http.Response response;

      switch (method) {
        case 'GET':
          response = await _httpClient
              .get(uri, headers: headers)
              .timeout(_timeout);
        case 'POST':
          response = await _httpClient
              .post(uri, headers: headers, body: encodedBody)
              .timeout(_timeout);
        case 'PUT':
          response = await _httpClient
              .put(uri, headers: headers, body: encodedBody)
              .timeout(_timeout);
        case 'PATCH':
          response = await _httpClient
              .patch(uri, headers: headers, body: encodedBody)
              .timeout(_timeout);
        case 'DELETE':
          response = await _httpClient
              .delete(uri, headers: headers, body: encodedBody)
              .timeout(_timeout);
        default:
          throw ServerException(
            message: 'Unsupported HTTP method: $method',
            statusCode: 500,
          );
      }

      _logResponse(method, uri, response);

      return _handleResponse<T>(response, fromJson);
    } on TimeoutException {
      throw const TimeoutException();
    } on http.ClientException {
      throw const NetworkException();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'حدث خطأ غير متوقع: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final statusCode = response.statusCode;

    Map<String, dynamic>? jsonBody;
    try {
      if (response.body.isNotEmpty) {
        jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {
      // Response body is not valid JSON — leave jsonBody as null.
    }

    // Successful responses (2xx)
    if (statusCode >= 200 && statusCode < 300) {
      return ApiResponse<T>.fromJson(jsonBody ?? {}, fromJson);
    }

    // Error responses
    final message = jsonBody?['message'] as String? ?? 'حدث خطأ غير متوقع';

    switch (statusCode) {
      case 401:
      case 403:
        throw AuthException(message: message);
      case 404:
        throw NotFoundException(message: message);
      case 422:
        final rawErrors = jsonBody?['errors'];
        final fieldErrors = <String, String>{};
        if (rawErrors is Map) {
          for (final entry in rawErrors.entries) {
            final key = entry.key.toString();
            final value = entry.value;
            if (value is List && value.isNotEmpty) {
              fieldErrors[key] = value.first.toString();
            } else {
              fieldErrors[key] = value.toString();
            }
          }
        }
        throw ValidationException(message: message, fieldErrors: fieldErrors);
      default:
        if (statusCode >= 500) {
          throw ServerException(
            message: message,
            statusCode: statusCode,
            errorBody: jsonBody,
          );
        }
        throw ServerException(
          message: message,
          statusCode: statusCode,
          errorBody: jsonBody,
        );
    }
  }

  void _logRequest(
    String method,
    Uri uri,
    Map<String, String> headers,
    String? body,
  ) {
    if (!enableLogging) return;
    // ignore: avoid_print
    print('┌─── API Request ───────────────────────────');
    // ignore: avoid_print
    print('│ $method $uri');
    // ignore: avoid_print
    print('│ Headers: $headers');
    if (body != null) {
      // ignore: avoid_print
      print('│ Body: $body');
    }
    // ignore: avoid_print
    print('└───────────────────────────────────────────');
  }

  void _logResponse(String method, Uri uri, http.Response response) {
    if (!enableLogging) return;
    // ignore: avoid_print
    print('┌─── API Response ──────────────────────────');
    // ignore: avoid_print
    print('│ $method $uri');
    // ignore: avoid_print
    print('│ Status: ${response.statusCode}');
    // ignore: avoid_print
    print('│ Body: ${response.body}');
    // ignore: avoid_print
    print('└───────────────────────────────────────────');
  }
}