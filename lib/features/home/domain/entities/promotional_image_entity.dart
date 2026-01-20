import 'package:equatable/equatable.dart';

/// Entity representing a promotional image displayed on the customer home page.
/// These images appear below the banners section and can be managed by admin.
class PromotionalImageEntity extends Equatable {
  final String id;
  final String imageUrl;
  final String? title;
  final String? subtitle;
  final String? deepLink;
  final bool isActive;
  final int priority;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PromotionalImageEntity({
    required this.id,
    required this.imageUrl,
    this.title,
    this.subtitle,
    this.deepLink,
    this.isActive = true,
    this.priority = 0,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    imageUrl,
    title,
    subtitle,
    deepLink,
    isActive,
    priority,
    createdAt,
    updatedAt,
  ];
}
