import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final FirebaseFirestore firestore;

  CartRepositoryImpl({required this.firestore});

  @override
  Stream<List<CartItemEntity>> getCartStream(String userId) {
    try {
      return firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('cart')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => CartItemModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw ServerException('Failed to get cart stream: ${e.toString()}');
    }
  }

  @override
  Future<Either<Failure, void>> addItem(
    String userId,
    CartItemEntity item,
  ) async {
    try {
      final cartRef = firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('cart')
          .doc(item.product.id);

      // Check if item already exists
      final existingDoc = await cartRef.get();
      if (existingDoc.exists) {
        // Update quantity
        final existingData = existingDoc.data()!;
        final currentQuantity = existingData['quantity'] as int;
        await cartRef.update({
          'quantity': currentQuantity + item.quantity,
        });
      } else {
        // Add new item
        await cartRef.set(CartItemModel.fromEntity(item).toJson());
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to add item to cart: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateItemQuantity(
    String userId,
    String productId,
    int quantity,
  ) async {
    try {
      if (quantity <= 0) {
        // Remove item if quantity is 0 or less
        return await removeItem(userId, productId);
      }

      await firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .update({'quantity': quantity});

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure('Failed to update item quantity: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> removeItem(
    String userId,
    String productId,
  ) async {
    try {
      await firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .delete();

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure('Failed to remove item from cart: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> clearCart(String userId) async {
    try {
      final cartSnapshot = await firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('cart')
          .get();

      final batch = firestore.batch();
      for (var doc in cartSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to clear cart: ${e.toString()}'));
    }
  }
}

