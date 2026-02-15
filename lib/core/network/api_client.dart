// Core - HTTP client wrapper using Dio with interceptors, token injection, and error mapping.
//
// Wraps the `dio` package to provide a consistent API for making network
// requests. Automatically injects auth tokens via interceptor, sets standard
// headers, logs requests/responses in debug mode, retries on failure,
// and maps HTTP errors to typed exceptions.

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/environment.dart';
import '../error/exceptions.dart';
import 'api_response.dart';

/// A typed HTTP client powered by [Dio] that handles authentication,
/// logging, retry, and error mapping.
///
/// ```dart
/// final client = ApiClient(
///   baseUrl: EnvironmentConfig.current.apiBaseUrl,
///   authTokenGetter: () => secureStorage.getAccessToken(),
///   onTokenExpired: () => authCubit.logout(),
///   enableLogging: EnvironmentConfig.current.enableLogging,
/// );
///
/// final response = await client.get('/categories');
/// ```
class ApiClient {
  /// The underlying [Dio] instance.
  late final Dio _dio;

  /// Async function that returns the current access token, or `null` if unauthenticated.
  final Future<String?> Function() authTokenGetter;

  /// Async function that returns a new access token using the refresh token.
  /// Return `null` if refresh fails.
  final Future<String?> Function()? tokenRefresher;

  /// Callback invoked when the token is expired and cannot be refreshed.
  final void Function()? onTokenExpired;

  /// Creates an [ApiClient] with Dio interceptors for auth, logging, and error handling.
  ///
  /// [baseUrl] is the root API URL (e.g. `http://10.0.2.2:3000/api/v1`).
  /// [authTokenGetter] returns the current Bearer token.
  /// [tokenRefresher] attempts to refresh an expired token.
  /// [onTokenExpired] is called when the token cannot be refreshed (e.g. force logout).
  /// [enableLogging] toggles console logging of requests/responses.
  /// [connectTimeout] overrides the default connection timeout.
  /// [receiveTimeout] overrides the default receive timeout.
  ApiClient({
    required String baseUrl,
    required this.authTokenGetter,
    this.tokenRefresher,
    this.onTokenExpired,
    bool enableLogging = false,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout:
            connectTimeout ?? EnvironmentConfig.current.connectTimeout,
        receiveTimeout:
            receiveTimeout ?? EnvironmentConfig.current.connectTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Language': 'ar',
        },
      ),
    );

    // 1️⃣ Auth interceptor — attaches JWT and handles 401 token refresh
    _dio.interceptors.add(_AuthInterceptor(
      authTokenGetter: authTokenGetter,
      tokenRefresher: tokenRefresher,
      onTokenExpired: onTokenExpired,
      dio: _dio,
    ));

    // 2️⃣ Error mapping interceptor — converts DioExceptions to typed AppExceptions
    _dio.interceptors.add(_ErrorMappingInterceptor());

    // 3️⃣ Logger interceptor (dev only) — logs requests and responses
    if (enableLogging) {
      _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ));
    }
  }

  /// Exposes the raw [Dio] instance for advanced use cases (e.g. file upload).
  Dio get dio => _dio;

  // ─── Public HTTP Methods ────────────────────────────────────────────

  /// Performs an HTTP GET request.
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _execute(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return _parseResponse<T>(response, fromJson);
    });
  }

  /// Performs an HTTP GET request that returns a list.
  Future<ApiResponse<List<T>>> getList<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _execute(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return _parseListResponse<T>(response, fromJson);
    });
  }

  /// Performs an HTTP POST request.
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _execute(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: body,
      );
      return _parseResponse<T>(response, fromJson);
    });
  }

  /// Performs an HTTP PUT request.
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _execute(() async {
      final response = await _dio.put<Map<String, dynamic>>(
        path,
        data: body,
      );
      return _parseResponse<T>(response, fromJson);
    });
  }

  /// Performs an HTTP PATCH request.
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _execute(() async {
      final response = await _dio.patch<Map<String, dynamic>>(
        path,
        data: body,
      );
      return _parseResponse<T>(response, fromJson);
    });
  }

  /// Performs an HTTP DELETE request.
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _execute(() async {
      final response = await _dio.delete<Map<String, dynamic>>(
        path,
        data: body,
      );
      return _parseResponse<T>(response, fromJson);
    });
  }

  /// Uploads a file using multipart form data.
  ///
  /// ```dart
  /// final response = await client.uploadFile(
  ///   '/shop/products',
  ///   filePath: '/path/to/image.jpg',
  ///   fileField: 'image',
  ///   data: {'name': 'Product Name', 'price': '100'},
  /// );
  /// ```
  Future<ApiResponse<T>> uploadFile<T>(
    String path, {
    required String filePath,
    required String fileField,
    Map<String, dynamic>? data,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _execute(() async {
      final formData = FormData.fromMap({
        ...?data,
        fileField: await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return _parseResponse<T>(response, fromJson);
    });
  }

  /// Closes the underlying Dio client.
  void dispose() {
    _dio.close();
  }

  // ─── Private Helpers ────────────────────────────────────────────────

  /// Executes a Dio operation and unwraps [DioException] into typed
  /// [AppException] subclasses so that [Result.guard()] in the data layer
  /// can catch them properly.
  ///
  /// Without this, the [_ErrorMappingInterceptor] wraps typed exceptions
  /// inside [DioException.error], but Dio always throws [DioException] —
  /// so the typed information is lost when caught by `Result.guard()`.
  Future<T> _execute<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (e) {
      // Unwrap our typed AppException from the DioException envelope
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      // Fallback for unexpected DioExceptions
      throw ServerException(
        message: e.message ?? 'حدث خطأ غير متوقع',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  ApiResponse<T> _parseResponse<T>(
    Response<Map<String, dynamic>> response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final json = response.data ?? {};
    return ApiResponse<T>.fromJson(json, fromJson);
  }

  ApiResponse<List<T>> _parseListResponse<T>(
    Response<Map<String, dynamic>> response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final json = response.data ?? {};

    List<T>? listData;
    if (fromJson != null && json['data'] != null && json['data'] is List) {
      final rawList = json['data'] as List;
      listData = rawList
          .whereType<Map<String, dynamic>>()
          .map((item) => fromJson(item))
          .toList();
    }

    // Parse pagination
    PaginationMeta? pagination;
    if (json['pagination'] != null && json['pagination'] is Map) {
      pagination = PaginationMeta.fromJson(
        json['pagination'] as Map<String, dynamic>,
      );
    }

    return ApiResponse<List<T>>(
      success: json['success'] as bool? ?? false,
      data: listData,
      message: json['message'] as String?,
      pagination: pagination,
    );
  }
}

// ─── Auth Interceptor ───────────────────────────────────────────────────────

/// Interceptor that attaches the Bearer token to every request and
/// handles 401 responses by attempting a token refresh.
class _AuthInterceptor extends Interceptor {
  final Future<String?> Function() authTokenGetter;
  final Future<String?> Function()? tokenRefresher;
  final void Function()? onTokenExpired;
  final Dio dio;

  bool _isRefreshing = false;
  final List<_RetryRequest> _pendingRequests = [];

  _AuthInterceptor({
    required this.authTokenGetter,
    this.tokenRefresher,
    this.onTokenExpired,
    required this.dio,
  });

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await authTokenGetter();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401 || tokenRefresher == null) {
      handler.next(err);
      return;
    }

    // If already refreshing, queue this request
    if (_isRefreshing) {
      final completer = Completer<Response>();
      _pendingRequests.add(_RetryRequest(
        options: err.requestOptions,
        completer: completer,
      ));
      try {
        final response = await completer.future;
        handler.resolve(response);
      } catch (e) {
        handler.next(err);
      }
      return;
    }

    _isRefreshing = true;

    try {
      final newToken = await tokenRefresher!();

      if (newToken != null) {
        // Retry the original request with the new token
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final retryResponse = await dio.fetch(err.requestOptions);
        handler.resolve(retryResponse);

        // Retry all queued requests
        for (final pending in _pendingRequests) {
          pending.options.headers['Authorization'] = 'Bearer $newToken';
          try {
            final response = await dio.fetch(pending.options);
            pending.completer.complete(response);
          } catch (e) {
            pending.completer.completeError(e);
          }
        }
      } else {
        // Refresh failed — force logout
        onTokenExpired?.call();
        handler.next(err);

        // Fail all queued requests
        for (final pending in _pendingRequests) {
          pending.completer.completeError(err);
        }
      }
    } catch (_) {
      onTokenExpired?.call();
      handler.next(err);

      for (final pending in _pendingRequests) {
        pending.completer.completeError(err);
      }
    } finally {
      _isRefreshing = false;
      _pendingRequests.clear();
    }
  }
}

class _RetryRequest {
  final RequestOptions options;
  final Completer<Response> completer;

  _RetryRequest({required this.options, required this.completer});
}

// ─── Error Mapping Interceptor ──────────────────────────────────────────────

/// Interceptor that maps [DioException] types to typed [AppException] subclasses.
class _ErrorMappingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const TimeoutException(),
            type: err.type,
          ),
        );
        return;

      case DioExceptionType.connectionError:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const NetworkException(),
            type: err.type,
          ),
        );
        return;

      case DioExceptionType.badResponse:
        final response = err.response;
        if (response != null) {
          final statusCode = response.statusCode ?? 500;
          final jsonBody = response.data is Map<String, dynamic>
              ? response.data as Map<String, dynamic>
              : <String, dynamic>{};

          // ── Parse the backend's actual error response format ──
          //
          // Backend format:
          //   { "success": false, "error": { "code": "...", "message": "...", "details": [...] } }
          //
          // Legacy/fallback format (for forward compatibility):
          //   { "message": "...", "errors": { "field": "msg" } }
          final errorObj = jsonBody['error'] is Map<String, dynamic>
              ? jsonBody['error'] as Map<String, dynamic>
              : null;

          final message = errorObj?['message'] as String?
              ?? jsonBody['message'] as String?
              ?? 'حدث خطأ غير متوقع';

          final errorCode = errorObj?['code'] as String?;

          switch (statusCode) {
            case 401:
            case 403:
              handler.reject(
                DioException(
                  requestOptions: err.requestOptions,
                  response: err.response,
                  error: AuthException(message: message, code: errorCode ?? 'AUTH_ERROR'),
                  type: err.type,
                ),
              );
              return;

            case 404:
              handler.reject(
                DioException(
                  requestOptions: err.requestOptions,
                  response: err.response,
                  error: NotFoundException(message: message, code: errorCode ?? 'NOT_FOUND'),
                  type: err.type,
                ),
              );
              return;

            case 422:
              final fieldErrors = <String, String>{};

              // Backend format: error.details = [{"field":"phone","message":"..."}]
              final details = errorObj?['details'];
              if (details is List) {
                for (final detail in details) {
                  if (detail is Map<String, dynamic>) {
                    final field = detail['field'] as String?;
                    final msg = detail['message'] as String?;
                    if (field != null && msg != null) {
                      fieldErrors[field] = msg;
                    }
                  }
                }
              }

              // Legacy fallback: errors = {"phone":"msg"} or {"phone":["msg"]}
              if (fieldErrors.isEmpty) {
                final rawErrors = jsonBody['errors'];
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
              }

              handler.reject(
                DioException(
                  requestOptions: err.requestOptions,
                  response: err.response,
                  error: ValidationException(
                    message: message,
                    fieldErrors: fieldErrors,
                    code: errorCode ?? 'VALIDATION_ERROR',
                  ),
                  type: err.type,
                ),
              );
              return;

            default:
              // Check if this is a validation error based on error code.
              // The backend may return 400 instead of 422 for validation
              // errors — detect by error code rather than status alone.
              if (errorCode == 'VALIDATION_ERROR') {
                final fieldErrors = <String, String>{};
                final details = errorObj?['details'];
                if (details is List) {
                  for (final detail in details) {
                    if (detail is Map<String, dynamic>) {
                      final field = detail['field'] as String?;
                      final msg = detail['message'] as String?;
                      if (field != null && msg != null) {
                        fieldErrors[field] = msg;
                      }
                    }
                  }
                }
                handler.reject(
                  DioException(
                    requestOptions: err.requestOptions,
                    response: err.response,
                    error: ValidationException(
                      message: message,
                      fieldErrors: fieldErrors,
                      code: errorCode,
                    ),
                    type: err.type,
                  ),
                );
                return;
              }

              handler.reject(
                DioException(
                  requestOptions: err.requestOptions,
                  response: err.response,
                  error: ServerException(
                    message: message,
                    statusCode: statusCode,
                    errorBody: jsonBody,
                    code: errorCode,
                  ),
                  type: err.type,
                ),
              );
              return;
          }
        }

      case DioExceptionType.cancel:
        handler.reject(err);
        return;

      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: ServerException(
              message: 'حدث خطأ غير متوقع: ${err.message}',
              statusCode: 500,
            ),
            type: err.type,
          ),
        );
        return;
    }

    handler.next(err);
  }
}