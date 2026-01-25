import 'package:equatable/equatable.dart';

class RestaurantCategoryEntity extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final bool isActive;
  final bool isMarket;
  final int displayOrder;
  final DateTime createdAt;

  const RestaurantCategoryEntity({
    required this.id,
    required this.name,
    this.imageUrl,
    this.isActive = true,
    this.isMarket = false,
    this.displayOrder = 0,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    imageUrl,
    isActive,
    isMarket,
    displayOrder,
    createdAt,
  ];
}
