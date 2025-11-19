import 'package:equatable/equatable.dart';

class FoodCategoryEntity extends Equatable {
  final String id;
  final String restaurantId;
  final String name;
  final String? description;
  final int displayOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FoodCategoryEntity({
    required this.id,
    required this.restaurantId,
    required this.name,
    this.description,
    this.displayOrder = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        restaurantId,
        name,
        description,
        displayOrder,
        isActive,
        createdAt,
        updatedAt,
      ];
}

