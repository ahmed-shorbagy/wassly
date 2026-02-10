import 'package:equatable/equatable.dart';

class ProductOption extends Equatable {
  final String id;
  final String name;
  final double priceModifier; // Additional cost (can be 0)
  final bool isAvailable;

  const ProductOption({
    required this.id,
    required this.name,
    required this.priceModifier,
    this.isAvailable = true,
  });

  @override
  List<Object?> get props => [id, name, priceModifier, isAvailable];

  ProductOption copyWith({
    String? id,
    String? name,
    double? priceModifier,
    bool? isAvailable,
  }) {
    return ProductOption(
      id: id ?? this.id,
      name: name ?? this.name,
      priceModifier: priceModifier ?? this.priceModifier,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'priceModifier': priceModifier,
      'isAvailable': isAvailable,
    };
  }

  factory ProductOption.fromJson(Map<String, dynamic> json) {
    return ProductOption(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      priceModifier: (json['priceModifier'] as num?)?.toDouble() ?? 0.0,
      isAvailable: json['isAvailable'] ?? true,
    );
  }
}

class ProductOptionGroup extends Equatable {
  final String id;
  final String name; // e.g., "Size", "Toppings"
  final bool isRequired; // e.g., Size is required, Toppings might not be
  final bool allowMultiple; // e.g., Size is single select, Toppings multi
  final int minSelection; // 0 if not required, 1 if required
  final int? maxSelection; // null for unlimited
  final List<ProductOption> options;

  const ProductOptionGroup({
    required this.id,
    required this.name,
    required this.isRequired,
    required this.allowMultiple,
    required this.options,
    this.minSelection = 0,
    this.maxSelection,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    isRequired,
    allowMultiple,
    minSelection,
    maxSelection,
    options,
  ];

  ProductOptionGroup copyWith({
    String? id,
    String? name,
    bool? isRequired,
    bool? allowMultiple,
    int? minSelection,
    int? maxSelection,
    List<ProductOption>? options,
  }) {
    return ProductOptionGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      isRequired: isRequired ?? this.isRequired,
      allowMultiple: allowMultiple ?? this.allowMultiple,
      minSelection: minSelection ?? this.minSelection,
      maxSelection: maxSelection ?? this.maxSelection,
      options: options ?? this.options,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isRequired': isRequired,
      'allowMultiple': allowMultiple,
      'minSelection': minSelection,
      'maxSelection': maxSelection,
      'options': options.map((e) => e.toJson()).toList(),
    };
  }

  factory ProductOptionGroup.fromJson(Map<String, dynamic> json) {
    return ProductOptionGroup(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      isRequired: json['isRequired'] ?? false,
      allowMultiple: json['allowMultiple'] ?? false,
      minSelection: json['minSelection'] ?? 0,
      maxSelection: json['maxSelection'],
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => ProductOption.fromJson(e))
              .toList() ??
          [],
    );
  }
}
