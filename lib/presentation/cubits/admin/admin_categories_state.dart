import 'package:equatable/equatable.dart';

import '../../../domain/entities/category.dart';

/// States for [`AdminCategoriesCubit()`](lib/presentation/cubits/admin/admin_categories_cubit.dart).
///
/// Kept separate from the UI layer to follow MVVM / clean architecture.
abstract class AdminCategoriesState extends Equatable {
  const AdminCategoriesState();

  /// Convenience getter so the UI can always read [categories] safely.
  ///
  /// By default states have no categories; specific states can override or
  /// provide their own lists.
  List<Category> get categories => const <Category>[];

  @override
  List<Object?> get props => [];
}

/// Initial state – categories not yet loaded.
class AdminCategoriesInitial extends AdminCategoriesState {
  const AdminCategoriesInitial();
}

/// Categories list is being loaded.
class AdminCategoriesLoading extends AdminCategoriesState {
  const AdminCategoriesLoading();
}

/// Categories list loaded successfully.
class AdminCategoriesLoaded extends AdminCategoriesState {
  final List<Category> _categories;

  const AdminCategoriesLoaded({required List<Category> categories})
      : _categories = categories;

  @override
  List<Category> get categories => _categories;

  @override
  List<Object?> get props => ["loaded", _categories];
}

/// Any create / update / delete action is in progress.
class AdminCategoriesActionLoading extends AdminCategoriesState {
  const AdminCategoriesActionLoading();
}

/// A create / update / delete action completed successfully.
class AdminCategoriesActionSuccess extends AdminCategoriesState {
  /// Success message to show in a snackbar.
  final String message;

  /// The latest categories list after the successful action.
  final List<Category> _categories;

  const AdminCategoriesActionSuccess({
    required this.message,
    required List<Category> categories,
  }) : _categories = categories;

  @override
  List<Category> get categories => _categories;

  @override
  List<Object?> get props => ["success", message, _categories];
}

/// An error occurred while loading or mutating categories.
class AdminCategoriesError extends AdminCategoriesState {
  final String message;

  const AdminCategoriesError(this.message);

  @override
  List<Object?> get props => ["error", message];
}