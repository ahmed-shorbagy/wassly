import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/network/supabase_service.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../domain/entities/restaurant_category_entity.dart';
import '../../domain/repositories/restaurant_category_repository.dart';
import '../models/restaurant_category_model.dart';

class RestaurantCategoryRepositoryImpl implements RestaurantCategoryRepository {
  final FirebaseFirestore _firestore;
  final SupabaseService _supabaseService;

  RestaurantCategoryRepositoryImpl({
    required FirebaseFirestore firestore,
    required SupabaseService supabaseService,
  }) : _firestore = firestore,
       _supabaseService = supabaseService;

  @override
  Future<Either<Failure, List<RestaurantCategoryEntity>>>
  getCategories() async {
    try {
      final snapshot = await _firestore
          .collection('restaurant_categories')
          .orderBy('displayOrder')
          .get();

      final List<RestaurantCategoryEntity> categories = snapshot.docs
          .map((doc) => RestaurantCategoryModel.fromFirestore(doc))
          .toList();

      return Right(categories);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RestaurantCategoryEntity>> createCategory({
    required String name,
    String? id,
    File? imageFile,
    bool isMarket = false,
    int displayOrder = 0,
  }) async {
    try {
      final categoryId = id ?? const Uuid().v4();
      String? imageUrl;

      if (imageFile != null) {
        AppLogger.logInfo('Uploading category image to Supabase...');
        final result = await _supabaseService.uploadImage(
          file: imageFile,
          bucketName: SupabaseConstants.restaurantImagesBucket,
          folder: 'categories',
          fileName: '$categoryId.jpg',
        );

        result.fold(
          (failure) {
            AppLogger.logError(
              'Failed to upload category image',
              error: failure.message,
            );
            throw Exception('Failed to upload image: ${failure.message}');
          },
          (url) {
            imageUrl = url;
          },
        );
      }

      final category = RestaurantCategoryModel(
        id: categoryId,
        name: name,
        imageUrl: imageUrl,
        isActive: true,
        isMarket: isMarket,
        displayOrder: displayOrder,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('restaurant_categories')
          .doc(categoryId)
          .set(category.toJson());

      return Right(category);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RestaurantCategoryEntity>> updateCategory({
    required String id,
    String? name,
    File? imageFile,
    bool? isActive,
    bool? isMarket,
    int? displayOrder,
  }) async {
    try {
      final docRef = _firestore.collection('restaurant_categories').doc(id);
      final doc = await docRef.get();

      if (!doc.exists) {
        return Left(ServerFailure('Category not found'));
      }

      final currentCategory = RestaurantCategoryModel.fromJson(doc.data()!);
      String? imageUrl = currentCategory.imageUrl;

      if (imageFile != null) {
        AppLogger.logInfo('Uploading updated category image to Supabase...');
        final result = await _supabaseService.uploadImage(
          file: imageFile,
          bucketName: SupabaseConstants.restaurantImagesBucket,
          folder: 'categories',
          fileName: '$id.jpg',
        );

        result.fold(
          (failure) {
            AppLogger.logError(
              'Failed to upload category image',
              error: failure.message,
            );
            throw Exception('Failed to upload image: ${failure.message}');
          },
          (url) {
            imageUrl = url;
          },
        );
      }

      final updatedCategory = RestaurantCategoryModel(
        id: id,
        name: name ?? currentCategory.name,
        imageUrl: imageUrl,
        isActive: isActive ?? currentCategory.isActive,
        isMarket: isMarket ?? currentCategory.isMarket,
        displayOrder: displayOrder ?? currentCategory.displayOrder,
        createdAt: currentCategory.createdAt,
      );

      await docRef.update(updatedCategory.toJson());

      return Right(updatedCategory);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await _firestore.collection('restaurant_categories').doc(id).delete();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
