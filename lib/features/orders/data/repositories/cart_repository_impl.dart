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
    if (userId.isEmpty) {
      return Stream.error('User ID is required');
    }

    try {
      return firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('cart')
          .snapshots()
          .map((snapshot) {
        try {
          return snapshot.docs
              .map((doc) {
                try {
                  return CartItemModel.fromFirestore(doc);
                } catch (e) {
                  // Skip invalid documents
                  return null;
                }
              })
              .where((item) => item != null)
              .cast<CartItemEntity>()
              .toList();
        } catch (e) {
          // Return empty list if parsing fails
          return <CartItemEntity>[];
        }
      }).handleError((error) {
        throw ServerException('Failed to get cart stream: ${error.toString()}');
      });
    } catch (e) {
      return Stream.error(ServerException('Failed to get cart stream: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> addItem(
    String userId,
    CartItemEntity item,
  ) async {
    try {
      // Validate inputs
      if (userId.isEmpty) {
        return const Left(ServerFailure('User ID is required'));
      }
      
      if (item.product.id.isEmpty) {
        return const Left(ServerFailure('Product ID is required'));
      }

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
      // Validate inputs
      if (userId.isEmpty) {
        return const Left(ServerFailure('User ID is required'));
      }
      
      if (productId.isEmpty) {
        return const Left(ServerFailure('Product ID is required'));
      }

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
      // Validate inputs
      if (userId.isEmpty) {
        return const Left(ServerFailure('User ID is required'));
      }
      
      if (productId.isEmpty) {
        return const Left(ServerFailure('Product ID is required'));
      }

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
      // Validate input
      if (userId.isEmpty) {
        return const Left(ServerFailure('User ID is required'));
      }

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

