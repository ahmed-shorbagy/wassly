import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product_entity.dart';

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
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Ensure ID is never empty - use provided id or throw error
    final id = json['id'];
    if (id == null || (id is String && id.isEmpty)) {
      throw FormatException('Product ID is required and cannot be empty');
    }
    
    return ProductModel(
      id: id as String,
      restaurantId: json['restaurantId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'],
      categoryId: json['categoryId'],
      category: json['category'], // Keep for backward compatibility
      isAvailable: json['isAvailable'] ?? true,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
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
    );
  }
}
