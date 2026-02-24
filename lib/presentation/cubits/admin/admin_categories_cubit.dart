import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../data/models/category_model.dart';
import '../../../domain/entities/category.dart';
import 'admin_categories_state.dart';

/// Cubit (ViewModel) for the admin categories feature.
///
/// All networking / business logic for:
/// - loading categories
/// - creating a category
/// - updating a category
/// - deleting a category
///
/// is handled here instead of inside the UI layer to respect MVVM / clean
/// architecture boundaries.
class AdminCategoriesCubit extends Cubit<AdminCategoriesState> {
  final ApiClient _apiClient;

  AdminCategoriesCubit({required ApiClient apiClient})
      : _apiClient = apiClient,
        super(const AdminCategoriesInitial());

  /// Loads the categories list from the backend.
  Future<void> loadCategories() async {
    emit(const AdminCategoriesLoading());
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.categories);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final list = data['data'] as List? ?? [];
        final categories = list
            .whereType<Map>()
            .map(
              (e) => CategoryModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();
        emit(AdminCategoriesLoaded(categories: categories));
      } else {
        emit(const AdminCategoriesError('استجابة غير متوقعة من الخادم'));
      }
    } catch (e) {
      emit(AdminCategoriesError(e.toString()));
    }
  }

  /// Creates a new category.
  ///
  /// The backend responds with:
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "message": "Category created successfully",
  ///     "category": { ... }
  ///   }
  /// }
  ///
  /// We parse the nested `data.message` and surface it to the UI.
  ///
  /// [imagePath] is the local path of the image file picked from the device.
  /// When provided, the request is sent as `multipart/form-data` with the file
  /// field named `image` (as expected by the backend) plus the rest of the
  /// payload as normal form fields.
  Future<void> createCategory({
    required Map<String, dynamic> payload,
    required String imagePath,
  }) async {
    emit(const AdminCategoriesActionLoading());
    try {
      final response = await _apiClient.uploadFile<Map<String, dynamic>>(
        ApiEndpoints.categories,
        filePath: imagePath,
        fileField: 'image',
        data: payload,
        fromJson: (json) => json,
      );

      // Prefer the inner data.message; fall back to top-level message, then Arabic default.
      final backendData = response.data;
      final backendMessage = (backendData?['message'] as String?) ??
          response.message ??
          'تم إضافة التصنيف بنجاح';

      // Reload list after successful creation.
      await loadCategories();

      final currentState = state;
      final categories = currentState is AdminCategoriesLoaded
          ? currentState.categories
          : const <Category>[];

      emit(AdminCategoriesActionSuccess(
        message: backendMessage,
        categories: categories,
      ));
    } catch (e) {
      emit(AdminCategoriesError(e.toString()));
    }
  }

  /// Updates an existing category.
  Future<void> updateCategory({
    required String categoryId,
    required Map<String, dynamic> payload,
  }) async {
    emit(const AdminCategoriesActionLoading());
    try {
      await _apiClient.put(
        '${ApiEndpoints.categories}/$categoryId',
        body: payload,
        fromJson: (json) => json,
      );

      // Reload list after successful update.
      await loadCategories();

      final currentState = state;
      final categories = currentState is AdminCategoriesLoaded
          ? currentState.categories
          : const <Category>[];

      emit(AdminCategoriesActionSuccess(
        message: 'تم تحديث التصنيف بنجاح',
        categories: categories,
      ));
    } catch (e) {
      emit(AdminCategoriesError(e.toString()));
    }
  }

  /// Deletes the given category.
  Future<void> deleteCategory({
    required String categoryId,
  }) async {
    emit(const AdminCategoriesActionLoading());
    try {
      await _apiClient.delete(
        '${ApiEndpoints.categories}/$categoryId',
        fromJson: (json) => json,
      );

      // Reload list after successful delete.
      await loadCategories();

      final currentState = state;
      final categories = currentState is AdminCategoriesLoaded
          ? currentState.categories
          : const <Category>[];

      emit(AdminCategoriesActionSuccess(
        message: 'تم حذف التصنيف بنجاح',
        categories: categories,
      ));
    } catch (e) {
      emit(AdminCategoriesError(e.toString()));
    }
  }
}