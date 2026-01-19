/// UI State models for presentation layer.
///
/// These models represent the state of UI components and are used
/// by ViewModels to communicate state to the View layer.
library;
import '../../core/error/failures.dart' as failures;

/// Generic UI state wrapper for any data type.
/// 
/// This is a sealed class that represents all possible states
/// of a UI component.
sealed class UiState<T> {
  const UiState();

  /// Check if state is initial.
  bool get isInitial => this is InitialState<T>;

  /// Check if state is loading.
  bool get isLoading => this is LoadingState<T>;

  /// Check if state is success.
  bool get isSuccess => this is SuccessState<T>;

  /// Check if state is error.
  bool get isError => this is ErrorState<T>;

  /// Check if state is empty.
  bool get isEmpty => this is EmptyState<T>;

  /// Get data if success state, null otherwise.
  T? get dataOrNull {
    final state = this;
    return state is SuccessState<T> ? state.data : null;
  }

  /// Get error message if error state, null otherwise.
  String? get errorMessageOrNull {
    final state = this;
    return state is ErrorState<T> ? state.message : null;
  }

  /// Pattern matching for UI state.
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) success,
    required R Function(String message, String? code) error,
    required R Function() empty,
  }) {
    final state = this;
    return switch (state) {
      InitialState<T>() => initial(),
      LoadingState<T>() => loading(),
      SuccessState<T>(data: final data) => success(data),
      ErrorState<T>(message: final msg, code: final code) => error(msg, code),
      EmptyState<T>() => empty(),
    };
  }

  /// Pattern matching with default fallback.
  R maybeWhen<R>({
    R Function()? initial,
    R Function()? loading,
    R Function(T data)? success,
    R Function(String message, String? code)? error,
    R Function()? empty,
    required R Function() orElse,
  }) {
    final state = this;
    return switch (state) {
      InitialState<T>() => initial?.call() ?? orElse(),
      LoadingState<T>() => loading?.call() ?? orElse(),
      SuccessState<T>(data: final data) => success?.call(data) ?? orElse(),
      ErrorState<T>(message: final msg, code: final code) => error?.call(msg, code) ?? orElse(),
      EmptyState<T>() => empty?.call() ?? orElse(),
    };
  }
}

/// Initial state - before any data is loaded.
class InitialState<T> extends UiState<T> {
  const InitialState();
}

/// Loading state - data is being fetched.
class LoadingState<T> extends UiState<T> {
  /// Optional message to show during loading.
  final String? message;

  const LoadingState({this.message});
}

/// Success state - data loaded successfully.
class SuccessState<T> extends UiState<T> {
  final T data;

  const SuccessState(this.data);
}

/// Error state - an error occurred.
class ErrorState<T> extends UiState<T> {
  final String message;
  final String? code;
  final failures.Failure? failure;

  const ErrorState({
    required this.message,
    this.code,
    this.failure,
  });

  factory ErrorState.fromFailure(failures.Failure failure) {
    return ErrorState(
      message: failure.message,
      code: failure.code,
      failure: failure,
    );
  }
}

/// Empty state - no data available.
class EmptyState<T> extends UiState<T> {
  /// Optional message for empty state.
  final String? message;

  const EmptyState({this.message});
}

/// Extension for creating UI states easily.
extension UiStateExtensions<T> on T {
  /// Wrap data in success state.
  UiState<T> toSuccessState() => SuccessState(this);
}

/// Extension for nullable to UI state conversion.
extension NullableUiStateExtensions<T> on T? {
  /// Convert nullable to UI state.
  UiState<T> toUiState({String emptyMessage = 'No data available'}) {
    if (this != null) {
      return SuccessState(this as T);
    }
    return EmptyState(message: emptyMessage);
  }
}

/// Extension for List to UI state conversion.
extension ListUiStateExtensions<T> on List<T> {
  /// Convert list to UI state (empty if list is empty).
  UiState<List<T>> toUiState({String emptyMessage = 'No items found'}) {
    if (isEmpty) {
      return EmptyState(message: emptyMessage);
    }
    return SuccessState(this);
  }
}