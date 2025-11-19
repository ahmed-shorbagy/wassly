import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/food_category_entity.dart';
import '../../domain/repositories/food_category_repository.dart';
import '../models/food_category_model.dart';

class FoodCategoryRepositoryImpl implements FoodCategoryRepository {
  final FirebaseFirestore firestore;
  final NetworkInfo networkInfo;

  FoodCategoryRepositoryImpl({
    required this.firestore,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<FoodCategoryEntity>>> getRestaurantCategories(
    String restaurantId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final snapshot = await firestore
            .collection(AppConstants.foodCategoriesCollection)
            .where('restaurantId', isEqualTo: restaurantId)
            .where('isActive', isEqualTo: true)
            .orderBy('displayOrder')
            .orderBy('name')
            .get();

        final categories = snapshot.docs
            .map((doc) => FoodCategoryModel.fromFirestore(doc))
            .toList();

        AppLogger.logSuccess(
          'Loaded ${categories.length} categories for restaurant: $restaurantId',
        );
        return Right(categories);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        AppLogger.logError('Failed to load categories', error: e);
        return Left(ServerFailure('Failed to load categories: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, FoodCategoryEntity>> getCategoryById(
    String categoryId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final doc = await firestore
            .collection(AppConstants.foodCategoriesCollection)
            .doc(categoryId)
            .get();

        if (doc.exists) {
          final category = FoodCategoryModel.fromFirestore(doc);
          return Right(category);
        } else {
          return const Left(ServerFailure('Category not found'));
        }
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        AppLogger.logError('Failed to load category', error: e);
        return Left(ServerFailure('Failed to load category: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, FoodCategoryEntity>> createCategory(
    FoodCategoryEntity category,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final categoryModel = FoodCategoryModel.fromEntity(category);
        final docRef = firestore
            .collection(AppConstants.foodCategoriesCollection)
            .doc();

        final categoryData = categoryModel.toFirestore();
        categoryData['id'] = docRef.id;

        await docRef.set(categoryData);

        final createdCategory = FoodCategoryModel.fromFirestore(
          await docRef.get(),
        );

        AppLogger.logSuccess('Category created: ${createdCategory.id}');
        return Right(createdCategory);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        AppLogger.logError('Failed to create category', error: e);
        return Left(ServerFailure('Failed to create category: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> updateCategory(
    FoodCategoryEntity category,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final categoryModel = FoodCategoryModel.fromEntity(category);
        final categoryData = categoryModel.toFirestore();
        categoryData['updatedAt'] = Timestamp.fromDate(DateTime.now());

        await firestore
            .collection(AppConstants.foodCategoriesCollection)
            .doc(category.id)
            .update(categoryData);

        AppLogger.logSuccess('Category updated: ${category.id}');
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        AppLogger.logError('Failed to update category', error: e);
        return Left(ServerFailure('Failed to update category: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String categoryId) async {
    if (await networkInfo.isConnected) {
      try {
        await firestore
            .collection(AppConstants.foodCategoriesCollection)
            .doc(categoryId)
            .delete();

        AppLogger.logSuccess('Category deleted: $categoryId');
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        AppLogger.logError('Failed to delete category', error: e);
        return Left(ServerFailure('Failed to delete category: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleCategoryStatus(
    String categoryId,
    bool isActive,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        await firestore
            .collection(AppConstants.foodCategoriesCollection)
            .doc(categoryId)
            .update({
          'isActive': isActive,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });

        AppLogger.logSuccess('Category status toggled: $categoryId');
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        AppLogger.logError('Failed to toggle category status', error: e);
        return Left(
          ServerFailure('Failed to toggle category status: ${e.toString()}'),
        );
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}

