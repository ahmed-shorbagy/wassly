import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../../restaurants/data/models/product_model.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.product,
    required super.quantity,
  });

  factory CartItemModel.fromEntity(CartItemEntity entity) {
    return CartItemModel(
      product: entity.product,
      quantity: entity.quantity,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': (product as ProductModel).toJson(),
      'quantity': quantity,
    };
  }

  factory CartItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItemModel.fromJson(data);
  }
}

