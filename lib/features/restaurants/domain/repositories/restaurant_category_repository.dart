import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/restaurant_category_entity.dart';
import 'dart:io';

abstract class RestaurantCategoryRepository {
  Future<Either<Failure, List<RestaurantCategoryEntity>>> getCategories();

  Future<Either<Failure, RestaurantCategoryEntity>> createCategory({
    required String name,
    File? imageFile,
    bool isMarket = false,
    int displayOrder = 0,
  });

  Future<Either<Failure, RestaurantCategoryEntity>> updateCategory({
    required String id,
    String? name,
    File? imageFile,
    bool? isActive,
    bool? isMarket,
    int? displayOrder,
  });

  Future<Either<Failure, void>> deleteCategory(String id);
}
