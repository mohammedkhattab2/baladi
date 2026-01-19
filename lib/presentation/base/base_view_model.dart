/// Base ViewModel class for MVVM architecture.
///
/// All ViewModels should extend this class to get common functionality:
/// - Loading state management
/// - Error handling
/// - Disposal
///
/// Architecture note: ViewModels are responsible for UI state and
/// orchestrating use cases. They should NOT contain business logic.
library;
import 'package:flutter/foundation.dart';

import '../../core/error/failures.dart' as failures;
import '../../core/result/result.dart';

/// UI state wrapper for ViewModels.
enum ViewState {
  /// Initial state before any data is loaded.
  initial,

  /// Data is being loaded.
  loading,

  /// Data loaded successfully.
  success,

  /// Error occurred while loading data.
  error,

  /// Empty state (no data available).
  empty,
}

/// Base ViewModel class that all feature ViewModels should extend.
abstract class BaseViewModel extends ChangeNotifier {
  /// Current view state.
  ViewState _state = ViewState.initial;
  ViewState get state => _state;

  /// Error message if state is error.
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Error code if state is error.
  String? _errorCode;
  String? get errorCode => _errorCode;

  /// Whether the ViewModel has been disposed.
  bool _disposed = false;
  bool get isDisposed => _disposed;

  /// Loading indicator for specific operations.
  final Map<String, bool> _loadingOperations = {};

  /// Set view state to loading.
  @protected
  void setLoading() {
    _state = ViewState.loading;
    _errorMessage = null;
    _errorCode = null;
    notifyListenersSafe();
  }

  /// Set view state to success.
  @protected
  void setSuccess() {
    _state = ViewState.success;
    _errorMessage = null;
    _errorCode = null;
    notifyListenersSafe();
  }

  /// Set view state to empty.
  @protected
  void setEmpty() {
    _state = ViewState.empty;
    _errorMessage = null;
    _errorCode = null;
    notifyListenersSafe();
  }

  /// Set view state to error with message.
  @protected
  void setError(String message, {String? code}) {
    _state = ViewState.error;
    _errorMessage = message;
    _errorCode = code;
    notifyListenersSafe();
  }

  /// Set error from failure.
  @protected
  void setErrorFromFailure(failures.Failure failure) {
    setError(failure.message, code: failure.code);
  }

  /// Reset to initial state.
  @protected
  void reset() {
    _state = ViewState.initial;
    _errorMessage = null;
    _errorCode = null;
    _loadingOperations.clear();
    notifyListenersSafe();
  }

  /// Check if a specific operation is loading.
  bool isOperationLoading(String operationKey) {
    return _loadingOperations[operationKey] ?? false;
  }

  /// Set a specific operation loading state.
  @protected
  void setOperationLoading(String operationKey, bool isLoading) {
    _loadingOperations[operationKey] = isLoading;
    notifyListenersSafe();
  }

  /// Helper getters for state checking.
  bool get isInitial => _state == ViewState.initial;
  bool get isLoading => _state == ViewState.loading;
  bool get isSuccess => _state == ViewState.success;
  bool get isError => _state == ViewState.error;
  bool get isEmpty => _state == ViewState.empty;

  /// Notifies listeners only if not disposed.
  @protected
  void notifyListenersSafe() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  /// Execute an async operation with automatic state management.
  /// 
  /// [operation] is the async function to execute.
  /// [operationKey] is optional key for tracking specific operations.
  /// [onSuccess] is called on successful result.
  /// [onError] is called on failure result.
  /// [setGlobalLoading] whether to set global loading state.
  @protected
  Future<T?> execute<T>({
    required Future<Result<T>> Function() operation,
    String? operationKey,
    void Function(T data)? onSuccess,
    void Function(failures.Failure failure)? onError,
    bool setGlobalLoading = true,
  }) async {
    try {
      if (operationKey != null) {
        setOperationLoading(operationKey, true);
      }
      if (setGlobalLoading) {
        setLoading();
      }

      final result = await operation();

      if (operationKey != null) {
        setOperationLoading(operationKey, false);
      }

      return result.fold(
        onSuccess: (data) {
          if (setGlobalLoading) {
            setSuccess();
          }
          onSuccess?.call(data);
          return data;
        },
        onFailure: (failure) {
          if (setGlobalLoading) {
            setErrorFromFailure(failure);
          }
          onError?.call(failure);
          return null;
        },
      );
    } catch (e) {
      if (operationKey != null) {
        setOperationLoading(operationKey, false);
      }
      if (setGlobalLoading) {
        setError(e.toString());
      }
      return null;
    }
  }

  /// Execute an async operation without Result wrapper.
  @protected
  Future<T?> executeRaw<T>({
    required Future<T> Function() operation,
    String? operationKey,
    void Function(T data)? onSuccess,
    void Function(Object error)? onError,
    bool setGlobalLoading = true,
  }) async {
    try {
      if (operationKey != null) {
        setOperationLoading(operationKey, true);
      }
      if (setGlobalLoading) {
        setLoading();
      }

      final result = await operation();

      if (operationKey != null) {
        setOperationLoading(operationKey, false);
      }
      if (setGlobalLoading) {
        setSuccess();
      }

      onSuccess?.call(result);
      return result;
    } catch (e) {
      if (operationKey != null) {
        setOperationLoading(operationKey, false);
      }
      if (setGlobalLoading) {
        setError(e.toString());
      }
      onError?.call(e);
      return null;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Mixin for ViewModels that need to track multiple loading states.
mixin MultiLoadingStateMixin on BaseViewModel {
  final Set<String> _activeOperations = {};

  /// Check if any operation is currently loading.
  bool get hasActiveOperations => _activeOperations.isNotEmpty;

  /// Get all active operation keys.
  Set<String> get activeOperations => Set.unmodifiable(_activeOperations);

  /// Start tracking an operation.
  void startOperation(String key) {
    _activeOperations.add(key);
    notifyListenersSafe();
  }

  /// Stop tracking an operation.
  void endOperation(String key) {
    _activeOperations.remove(key);
    notifyListenersSafe();
  }

  /// Check if a specific operation is active.
  bool isOperationActive(String key) => _activeOperations.contains(key);
}

/// Mixin for ViewModels that need pagination support.
mixin PaginationMixin<T> on BaseViewModel {
  final List<T> _items = [];
  List<T> get items => List.unmodifiable(_items);

  int _currentPage = 1;
  int get currentPage => _currentPage;

  int _pageSize = 20;
  int get pageSize => _pageSize;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  /// Set page size.
  void setPageSize(int size) {
    _pageSize = size;
  }

  /// Reset pagination.
  void resetPagination() {
    _items.clear();
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    notifyListenersSafe();
  }

  /// Load first page.
  @protected
  Future<void> loadFirstPage(Future<List<T>> Function(int page, int pageSize) loader) async {
    resetPagination();
    setLoading();

    try {
      final newItems = await loader(_currentPage, _pageSize);
      _items.addAll(newItems);
      _hasMore = newItems.length >= _pageSize;

      if (_items.isEmpty) {
        setEmpty();
      } else {
        setSuccess();
      }
    } catch (e) {
      setError(e.toString());
    }
  }

  /// Load next page.
  @protected
  Future<void> loadNextPage(Future<List<T>> Function(int page, int pageSize) loader) async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    notifyListenersSafe();

    try {
      _currentPage++;
      final newItems = await loader(_currentPage, _pageSize);
      _items.addAll(newItems);
      _hasMore = newItems.length >= _pageSize;
    } catch (e) {
      _currentPage--; // Rollback on error
    } finally {
      _isLoadingMore = false;
      notifyListenersSafe();
    }
  }

  /// Add item to list.
  void addItem(T item) {
    _items.add(item);
    notifyListenersSafe();
  }

  /// Remove item from list.
  void removeItem(T item) {
    _items.remove(item);
    if (_items.isEmpty && state == ViewState.success) {
      setEmpty();
    } else {
      notifyListenersSafe();
    }
  }

  /// Update item in list.
  void updateItem(int index, T newItem) {
    if (index >= 0 && index < _items.length) {
      _items[index] = newItem;
      notifyListenersSafe();
    }
  }

  /// Clear all items.
  void clearItems() {
    _items.clear();
    setEmpty();
  }
}