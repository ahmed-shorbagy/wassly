import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/food_category_entity.dart';

abstract class FoodCategoryRepository {
  /// Get all categories for a restaurant
  Future<Either<Failure, List<FoodCategoryEntity>>> getRestaurantCategories(
    String restaurantId,
  );

  /// Get a category by ID
  Future<Either<Failure, FoodCategoryEntity>> getCategoryById(String categoryId);

  /// Create a new category
  Future<Either<Failure, FoodCategoryEntity>> createCategory(
    FoodCategoryEntity category,
  );

  /// Update a category
  Future<Either<Failure, void>> updateCategory(FoodCategoryEntity category);

  /// Delete a category
  Future<Either<Failure, void>> deleteCategory(String categoryId);

  /// Toggle category active status
  Future<Either<Failure, void>> toggleCategoryStatus(
    String categoryId,
    bool isActive,
  );
}

