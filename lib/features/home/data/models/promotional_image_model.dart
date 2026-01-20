import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/promotional_image_entity.dart';

/// Firestore model for promotional images with serialization support.
class PromotionalImageModel extends PromotionalImageEntity {
  const PromotionalImageModel({
    required super.id,
    required super.imageUrl,
    super.title,
    super.subtitle,
    super.deepLink,
    super.isActive = true,
    super.priority = 0,
    super.createdAt,
    super.updatedAt,
  });

  factory PromotionalImageModel.fromJson(Map<String, dynamic> json) {
    return PromotionalImageModel(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      title: json['title'],
      subtitle: json['subtitle'],
      deepLink: json['deepLink'],
      isActive: json['isActive'] ?? true,
      priority: json['priority'] ?? 0,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  factory PromotionalImageModel.fromEntity(PromotionalImageEntity entity) {
    return PromotionalImageModel(
      id: entity.id,
      imageUrl: entity.imageUrl,
      title: entity.title,
      subtitle: entity.subtitle,
      deepLink: entity.deepLink,
      isActive: entity.isActive,
      priority: entity.priority,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory PromotionalImageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PromotionalImageModel.fromJson({...data, 'id': doc.id});
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'title': title,
      'subtitle': subtitle,
      'deepLink': deepLink,
      'isActive': isActive,
      'priority': priority,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'imageUrl': imageUrl,
      'title': title,
      'subtitle': subtitle,
      'deepLink': deepLink,
      'isActive': isActive,
      'priority': priority,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  PromotionalImageModel copyWith({
    String? id,
    String? imageUrl,
    String? title,
    String? subtitle,
    String? deepLink,
    bool? isActive,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PromotionalImageModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      deepLink: deepLink ?? this.deepLink,
      isActive: isActive ?? this.isActive,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
