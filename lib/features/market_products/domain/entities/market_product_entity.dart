import 'package:equatable/equatable.dart';

class MarketProductEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String? category;
  final bool isAvailable;
  final String? restaurantId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MarketProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.category,
    required this.isAvailable,
    this.restaurantId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    imageUrl,
    category,
    isAvailable,
    createdAt,
    updatedAt,
  ];
}
