import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String? categoryId; // Reference to FoodCategoryEntity
  final String? category; // Keep for backward compatibility, will be deprecated
  final bool isAvailable;
  final DateTime createdAt;

  const ProductEntity({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.categoryId,
    this.category,
    required this.isAvailable,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    restaurantId,
    name,
    description,
    price,
    imageUrl,
    categoryId,
    category,
    isAvailable,
    createdAt,
  ];
}
