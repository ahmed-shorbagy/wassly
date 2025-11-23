import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/food_category_entity.dart';
import '../../domain/repositories/food_category_repository.dart';

part 'food_category_state.dart';

class FoodCategoryCubit extends Cubit<FoodCategoryState> {
  final FoodCategoryRepository repository;

  FoodCategoryCubit({required this.repository}) : super(FoodCategoryInitial());

  Future<void> loadRestaurantCategories(String restaurantId) async {
    if (isClosed) return;
    try {
      emit(FoodCategoryLoading());
      AppLogger.logInfo('Loading categories for restaurant: $restaurantId');

      final result = await repository.getRestaurantCategories(restaurantId);

      if (isClosed) return;
      result.fold(
        (failure) {
          if (isClosed) return;
          AppLogger.logError('Failed to load categories', error: failure.message);
          emit(FoodCategoryError(failure.message));
        },
        (categories) {
          if (isClosed) return;
          AppLogger.logSuccess('Categories loaded: ${categories.length}');
          emit(FoodCategoryLoaded(categories));
        },
      );
    } catch (e) {
      if (isClosed) return;
      AppLogger.logError('Error loading categories', error: e);
      emit(FoodCategoryError('Failed to load categories: $e'));
    }
  }

  Future<void> createCategory({
    required String restaurantId,
    required String name,
    String? description,
    int displayOrder = 0,
  }) async {
    if (isClosed) return;
    try {
      emit(FoodCategoryLoading());
      AppLogger.logInfo('Creating category: $name');

      final category = FoodCategoryEntity(
        id: '', // Will be set by repository
        restaurantId: restaurantId,
        name: name,
        description: description,
        displayOrder: displayOrder,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await repository.createCategory(category);

      if (isClosed) return;
      result.fold(
        (failure) {
          if (isClosed) return;
          AppLogger.logError('Failed to create category', error: failure.message);
          emit(FoodCategoryError(failure.message));
        },
        (createdCategory) {
          if (isClosed) return;
          AppLogger.logSuccess('Category created successfully');
          emit(FoodCategoryCreated());
          // Reload categories
          loadRestaurantCategories(restaurantId);
        },
      );
    } catch (e) {
      if (isClosed) return;
      AppLogger.logError('Error creating category', error: e);
      emit(FoodCategoryError('Failed to create category: $e'));
    }
  }

  Future<void> updateCategory({
    required FoodCategoryEntity category,
    String? name,
    String? description,
    int? displayOrder,
    bool? isActive,
  }) async {
    if (isClosed) return;
    try {
      emit(FoodCategoryLoading());
      AppLogger.logInfo('Updating category: ${category.id}');

      final updatedCategory = FoodCategoryEntity(
        id: category.id,
        restaurantId: category.restaurantId,
        name: name ?? category.name,
        description: description ?? category.description,
        displayOrder: displayOrder ?? category.displayOrder,
        isActive: isActive ?? category.isActive,
        createdAt: category.createdAt,
        updatedAt: DateTime.now(),
      );

      final result = await repository.updateCategory(updatedCategory);

      if (isClosed) return;
      result.fold(
        (failure) {
          if (isClosed) return;
          AppLogger.logError('Failed to update category', error: failure.message);
          emit(FoodCategoryError(failure.message));
        },
        (_) {
          if (isClosed) return;
          AppLogger.logSuccess('Category updated successfully');
          emit(FoodCategoryUpdated());
          // Reload categories
          loadRestaurantCategories(category.restaurantId);
        },
      );
    } catch (e) {
      if (isClosed) return;
      AppLogger.logError('Error updating category', error: e);
      emit(FoodCategoryError('Failed to update category: $e'));
    }
  }

  Future<void> deleteCategory(String categoryId, String restaurantId) async {
    if (isClosed) return;
    try {
      emit(FoodCategoryLoading());
      AppLogger.logInfo('Deleting category: $categoryId');

      final result = await repository.deleteCategory(categoryId);

      if (isClosed) return;
      result.fold(
        (failure) {
          if (isClosed) return;
          AppLogger.logError('Failed to delete category', error: failure.message);
          emit(FoodCategoryError(failure.message));
        },
        (_) {
          if (isClosed) return;
          AppLogger.logSuccess('Category deleted successfully');
          emit(FoodCategoryDeleted());
          // Reload categories
          loadRestaurantCategories(restaurantId);
        },
      );
    } catch (e) {
      if (isClosed) return;
      AppLogger.logError('Error deleting category', error: e);
      emit(FoodCategoryError('Failed to delete category: $e'));
    }
  }

  Future<void> toggleCategoryStatus(
    String categoryId,
    bool isActive,
    String restaurantId,
  ) async {
    if (isClosed) return;
    try {
      AppLogger.logInfo('Toggling category status: $categoryId');

      final result = await repository.toggleCategoryStatus(categoryId, isActive);

      if (isClosed) return;
      result.fold(
        (failure) {
          if (isClosed) return;
          AppLogger.logError('Failed to toggle category status', error: failure.message);
          emit(FoodCategoryError(failure.message));
        },
        (_) {
          if (isClosed) return;
          AppLogger.logSuccess('Category status updated');
          // Reload categories
          loadRestaurantCategories(restaurantId);
        },
      );
    } catch (e) {
      if (isClosed) return;
      AppLogger.logError('Error toggling category status', error: e);
      emit(FoodCategoryError('Failed to toggle category status: $e'));
    }
  }
}

