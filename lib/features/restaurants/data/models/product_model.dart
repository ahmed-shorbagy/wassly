import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/product_options.dart';
import '../../../../core/utils/logger.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.restaurantId,
    required super.name,
    required super.description,
    required super.price,
    super.imageUrl,
    super.categoryId,
    super.category,
    required super.isAvailable,
    required super.createdAt,
    super.optionGroups = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Ensure ID is never empty - use provided id or throw error
    final id = json['id'];
    if (id == null || (id is String && id.isEmpty)) {
      throw FormatException('Product ID is required and cannot be empty');
    }

    double parsePrice(dynamic value) {
      if (value == null) {
        // AppLogger.logWarning('ProductModel: Price is null for id: $id');
        return 0.0;
      }
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed == null) {
          AppLogger.logError(
            'ProductModel: Failed to parse price string: $value for id: $id',
          );
        }
        return parsed ?? 0.0;
      }
      AppLogger.logError(
        'ProductModel: Unknown price type: ${value.runtimeType} for id: $id',
      );
      return 0.0;
    }

    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    // Log problematic entries
    if (json['price'] == null || json['price'] == 0) {
      AppLogger.logInfo(
        'ProductModel: Parsed product with 0/null price. ID: $id, Raw Price: ${json['price']}',
      );
    }

    return ProductModel(
      id: id as String,
      restaurantId: json['restaurantId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: parsePrice(json['price']),
      imageUrl: json['imageUrl'] as String?,
      categoryId: json['categoryId'] as String?,
      category: json['category'] as String?, // Keep for backward compatibility
      isAvailable: json['isAvailable'] as bool? ?? true,
      createdAt: parseDate(json['createdAt']),
      optionGroups:
          (json['optionGroups'] as List<dynamic>?)
              ?.map((e) => ProductOptionGroup.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      restaurantId: entity.restaurantId,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      imageUrl: entity.imageUrl,
      categoryId: entity.categoryId,
      category: entity.category,
      isAvailable: entity.isAvailable,
      createdAt: entity.createdAt,
      optionGroups: entity.optionGroups,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'category': category, // Keep for backward compatibility
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
      'optionGroups': optionGroups.map((e) => e.toJson()).toList(),
    };
  }

  /// Converts to Firestore format - excludes 'id' field since document ID is the ID
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // Remove id field - document ID is the ID
    return json;
  }

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Remove any existing 'id' field from data and use document ID
    final cleanData = Map<String, dynamic>.from(data);
    cleanData.remove('id'); // Remove any id field from data
    cleanData['id'] = doc.id; // Always use document ID
    return ProductModel.fromJson(cleanData);
  }

  ProductModel copyWith({
    String? id,
    String? restaurantId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? categoryId,
    String? category,
    bool? isAvailable,
    DateTime? createdAt,
    List<ProductOptionGroup>? optionGroups,
  }) {
    return ProductModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      optionGroups: optionGroups ?? this.optionGroups,
    );
  }
}
