import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../../restaurants/data/models/product_model.dart';
import '../../../../core/utils/logger.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({required super.product, required super.quantity});

  factory CartItemModel.fromEntity(CartItemEntity entity) {
    return CartItemModel(product: entity.product, quantity: entity.quantity);
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    if (json['product'] == null) {
      AppLogger.logError('CartItemModel: Product is missing in cart item');
      throw const FormatException('Product is missing in cart item');
    }

    final quantity = (json['quantity'] as num?)?.toInt() ?? 1;
    AppLogger.logInfo(
      'CartItemModel: Parsed item. Quantity: $quantity, Raw Qty: ${json['quantity']}',
    );

    return CartItemModel(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': ProductModel.fromEntity(product).toJson(),
      'quantity': quantity,
    };
  }

  factory CartItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItemModel.fromJson(data);
  }
}
