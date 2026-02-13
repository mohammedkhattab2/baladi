// Core - Generic API response wrapper model.
//
// Standardizes the shape of all API responses, providing typed access
// to [data], server [message], field-level [errors], and [pagination] metadata.

/// Generic wrapper for API responses.
///
/// The server is expected to return JSON in the shape:
/// ```json
/// {
///   "success": true,
///   "data": { ... },
///   "message": "Operation successful",
///   "errors": null,
///   "pagination": { ... }
/// }
/// ```
class ApiResponse<T> {
  /// Whether the operation was successful.
  final bool success;

  /// The parsed data payload, or `null` on failure or empty responses.
  final T? data;

  /// An optional human-readable message from the server.
  final String? message;

  /// Field-level validation errors returned by the server (422 responses).
  final Map<String, String>? errors;

  /// Pagination metadata, present on paginated list endpoints.
  final PaginationMeta? pagination;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errors,
    this.pagination,
  });

  /// Constructs an [ApiResponse] from a decoded JSON map.
  ///
  /// [fromJson] is an optional data parser that converts the raw `data` field
  /// into a typed [T]. If omitted, [data] will be `null`.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    // Parse data
    T? data;
    if (fromJson != null && json['data'] != null) {
      data = fromJson(json['data'] as Map<String, dynamic>);
    }

    // Parse field errors
    Map<String, String>? errors;
    if (json['errors'] != null && json['errors'] is Map) {
      final rawErrors = json['errors'] as Map;
      errors = {};
      for (final entry in rawErrors.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        if (value is List && value.isNotEmpty) {
          errors[key] = value.first.toString();
        } else {
          errors[key] = value.toString();
        }
      }
    }

    // Parse pagination
    PaginationMeta? pagination;
    if (json['pagination'] != null && json['pagination'] is Map) {
      pagination = PaginationMeta.fromJson(
        json['pagination'] as Map<String, dynamic>,
      );
    }

    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      data: data,
      message: json['message'] as String?,
      errors: errors,
      pagination: pagination,
    );
  }

  /// Whether this response contains pagination metadata.
  bool get hasPagination => pagination != null;

  /// Whether this response contains field-level errors.
  bool get hasErrors => errors != null && errors!.isNotEmpty;

  @override
  String toString() =>
      'ApiResponse(success: $success, message: $message, hasData: ${data != null})';
}

/// Pagination metadata returned by paginated API endpoints.
class PaginationMeta {
  /// The current page number (1-based).
  final int currentPage;

  /// Total number of pages available.
  final int totalPages;

  /// Total number of items across all pages.
  final int totalItems;

  /// Number of items per page.
  final int perPage;

  /// Whether there are more pages after the current one.
  final bool hasNextPage;

  const PaginationMeta({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.perPage,
    required this.hasNextPage,
  });

  /// Constructs a [PaginationMeta] from a decoded JSON map.
  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    final currentPage = json['currentPage'] as int? ?? 1;
    final totalPages = json['totalPages'] as int? ?? 1;

    return PaginationMeta(
      currentPage: currentPage,
      totalPages: totalPages,
      totalItems: json['totalItems'] as int? ?? 0,
      perPage: json['perPage'] as int? ?? 20,
      hasNextPage: json['hasNextPage'] as bool? ?? (currentPage < totalPages),
    );
  }

  @override
  String toString() =>
      'PaginationMeta(page: $currentPage/$totalPages, total: $totalItems)';
}