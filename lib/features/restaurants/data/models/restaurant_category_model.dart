import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/restaurant_category_entity.dart';

class RestaurantCategoryModel extends RestaurantCategoryEntity {
  const RestaurantCategoryModel({
    required super.id,
    required super.name,
    super.imageUrl,
    super.isActive,
    super.displayOrder,
    required super.createdAt,
  });

  factory RestaurantCategoryModel.fromJson(Map<String, dynamic> json) {
    return RestaurantCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
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
      displayOrder: entity.displayOrder,
      createdAt: entity.createdAt,
    );
  }
}
