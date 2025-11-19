import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/food_category_entity.dart';

class FoodCategoryModel extends FoodCategoryEntity {
  const FoodCategoryModel({
    required super.id,
    required super.restaurantId,
    required super.name,
    super.description,
    super.displayOrder,
    super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory FoodCategoryModel.fromJson(Map<String, dynamic> json) {
    return FoodCategoryModel(
      id: json['id'] ?? '',
      restaurantId: json['restaurantId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      displayOrder: json['displayOrder'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  factory FoodCategoryModel.fromEntity(FoodCategoryEntity entity) {
    return FoodCategoryModel(
      id: entity.id,
      restaurantId: entity.restaurantId,
      name: entity.name,
      description: entity.description,
      displayOrder: entity.displayOrder,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'displayOrder': displayOrder,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toFirestore() => toJson();

  factory FoodCategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FoodCategoryModel.fromJson({...data, 'id': doc.id});
  }

  FoodCategoryModel copyWith({
    String? id,
    String? restaurantId,
    String? name,
    String? description,
    int? displayOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoodCategoryModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      description: description ?? this.description,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

