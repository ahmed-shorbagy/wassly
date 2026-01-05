import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/restaurant_category_entity.dart';
import '../../domain/repositories/restaurant_category_repository.dart';
import '../models/restaurant_category_model.dart';

class RestaurantCategoryRepositoryImpl implements RestaurantCategoryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  RestaurantCategoryRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  }) : _firestore = firestore,
       _storage = storage;

  @override
  Future<Either<Failure, List<RestaurantCategoryEntity>>>
  getCategories() async {
    try {
      final snapshot = await _firestore
          .collection('restaurant_categories')
          .orderBy('displayOrder')
          .get();

      final categories = snapshot.docs
          .map((doc) => RestaurantCategoryModel.fromJson(doc.data()))
          .toList();

      return Right(categories);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RestaurantCategoryEntity>> createCategory({
    required String name,
    File? imageFile,
    int displayOrder = 0,
  }) async {
    try {
      final id = const Uuid().v4();
      String? imageUrl;

      if (imageFile != null) {
        final ref = _storage
            .ref()
            .child('restaurant_categories')
            .child('$id.jpg');
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
      }

      final category = RestaurantCategoryModel(
        id: id,
        name: name,
        imageUrl: imageUrl,
        isActive: true,
        displayOrder: displayOrder,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('restaurant_categories')
          .doc(id)
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
        final ref = _storage
            .ref()
            .child('restaurant_categories')
            .child('$id.jpg');
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
      }

      final updatedCategory = RestaurantCategoryModel(
        id: id,
        name: name ?? currentCategory.name,
        imageUrl: imageUrl,
        isActive: isActive ?? currentCategory.isActive,
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
