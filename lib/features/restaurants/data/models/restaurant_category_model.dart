import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/restaurant_category_entity.dart';

class RestaurantCategoryModel extends RestaurantCategoryEntity {
  const RestaurantCategoryModel({
    required super.id,
    required super.name,
    super.imageUrl,
    super.isActive,
    super.isMarket,
    super.displayOrder,
    required super.createdAt,
  });

  factory RestaurantCategoryModel.fromJson(Map<String, dynamic> json) {
    return RestaurantCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      isMarket: json['isMarket'] as bool? ?? false,
      displayOrder: json['displayOrder'] as int? ?? 0,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'isMarket': isMarket,
      'displayOrder': displayOrder,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RestaurantCategoryModel.fromEntity(RestaurantCategoryEntity entity) {
    return RestaurantCategoryModel(
      id: entity.id,
      name: entity.name,
      imageUrl: entity.imageUrl,
      isActive: entity.isActive,
      isMarket: entity.isMarket,
      displayOrder: entity.displayOrder,
      createdAt: entity.createdAt,
    );
  }
  factory RestaurantCategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RestaurantCategoryModel.fromJson({...data, 'id': doc.id});
  }
}
