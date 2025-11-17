import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/safe_navigation_wrapper.dart';
import '../../../restaurants/domain/entities/product_entity.dart';
import '../cubits/admin_product_cubit.dart';

class AdminEditProductScreen extends StatefulWidget {
  final String restaurantId;
  final String productId;
  final dynamic product;

  const AdminEditProductScreen({
    super.key,
    required this.restaurantId,
    required this.productId,
    this.product,
  });

  @override
  State<AdminEditProductScreen> createState() => _AdminEditProductScreenState();
}

class _AdminEditProductScreenState extends State<AdminEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _categoryController;

  File? _selectedImage;
  bool _isAvailable = true;
  String? _selectedCategory;
  ProductEntity? _productEntity;

  @override
  void initState() {
    super.initState();
    // Initialize product entity from extra parameter
    if (widget.product is ProductEntity) {
      _productEntity = widget.product as ProductEntity;
    } else if (widget.product is Map) {
      // Handle if product is passed as Map
      final productMap = widget.product as Map<String, dynamic>;
      _productEntity = ProductEntity(
        id: productMap['id'] ?? widget.productId,
        restaurantId: productMap['restaurantId'] ?? widget.restaurantId,
        name: productMap['name'] ?? '',
        description: productMap['description'] ?? '',
        price: (productMap['price'] ?? 0.0).toDouble(),
        imageUrl: productMap['imageUrl'],
        category: productMap['category'],
        isAvailable: productMap['isAvailable'] ?? true,
        createdAt: productMap['createdAt'] is DateTime
            ? productMap['createdAt'] as DateTime
            : DateTime.now(),
      );
    }

    // Initialize controllers with product data
    _nameController = TextEditingController(text: _productEntity?.name ?? '');
    _descriptionController = TextEditingController(text: _productEntity?.description ?? '');
    _priceController = TextEditingController(text: _productEntity?.price.toString() ?? '');
    _categoryController = TextEditingController(text: _productEntity?.category ?? '');
    _selectedCategory = _productEntity?.category;
    _isAvailable = _productEntity?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  List<String> _getAvailableCategories(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      // Arabian categories
      l10n.arabic,
      l10n.egyptian,
      l10n.lebanese,
      l10n.syrian,
      l10n.palestinian,
      l10n.jordanian,
      l10n.saudi,
      l10n.emirati,
      l10n.gulf,
      l10n.moroccan,
      l10n.tunisian,
      l10n.algerian,
      l10n.yemeni,
      l10n.iraqi,
      // Specific dishes
      l10n.kebabs,
      l10n.shawarma,
      l10n.falafel,
      l10n.hummus,
      l10n.mezze,
      l10n.koshary,
      l10n.mansaf,
      l10n.mandi,
      l10n.kabsa,
      l10n.majboos,
      l10n.maqluba,
      l10n.musakhan,
      l10n.waraqEnab,
      l10n.mahshi,
      l10n.kofta,
      l10n.samosa,
      l10n.grilledMeat,
      l10n.bakedGoods,
      l10n.orientalSweets,
      // International
      l10n.fastFood,
      l10n.italian,
      l10n.chinese,
      l10n.indian,
      l10n.mexican,
      l10n.japanese,
      l10n.thai,
      l10n.mediterranean,
      l10n.american,
      l10n.vegetarian,
      l10n.vegan,
      l10n.desserts,
      l10n.beverages,
      l10n.healthy,
      l10n.bbq,
      l10n.seafood,
    ];
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        context.showErrorSnackBar(l10n.failedToPickImage(e.toString()));
      }
    }
  }

  void _showCategoryPicker() {
    final l10n = AppLocalizations.of(context)!;
    final categories = _getAvailableCategories(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.productCategory),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                title: Text(category),
                selected: _selectedCategory == category,
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                    _categoryController.text = category;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.done),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_productEntity == null) {
      context.showErrorSnackBar('Product data not available');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AdminProductCubit>().updateProduct(
      product: _productEntity!,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text),
      category: _selectedCategory,
      imageFile: _selectedImage,
      isAvailable: _isAvailable,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_productEntity == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.editProduct),
          backgroundColor: Colors.purple,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(l10n.restaurantNotFound),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: Text(l10n.back),
              ),
            ],
          ),
        ),
      );
    }

    return SafeNavigationWrapper(
      fallbackRoute: '/admin/restaurants/${widget.restaurantId}/products',
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.editProduct),
          backgroundColor: Colors.purple,
        ),
        body: BlocConsumer<AdminProductCubit, AdminProductState>(
          listener: (context, state) {
            if (state is AdminProductUpdated) {
              context.pop();
            } else if (state is AdminProductError) {
              context.showErrorSnackBar(state.message);
            }
          },
          builder: (context, state) {
            if (state is AdminProductLoading) {
              return LoadingWidget(message: l10n.creatingProduct);
            }

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Image Upload Section
                  _buildImageUploadSection(l10n),
                  const SizedBox(height: 24),

                  // Basic Information
                  _buildSectionTitle(l10n.basicInformation),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _nameController,
                    label: l10n.productName,
                    icon: Icons.fastfood,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.pleaseEnterProductName;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descriptionController,
                    label: l10n.productDescription,
                    icon: Icons.description,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.pleaseEnterProductDescription;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _priceController,
                    label: l10n.productPrice,
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseEnterProductPrice;
                      }
                      if (double.tryParse(value) == null) {
                        return l10n.invalidNumber;
                      }
                      if (double.parse(value) <= 0) {
                        return l10n.invalidNumber;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Category
                  _buildSectionTitle(l10n.productCategory),
                  const SizedBox(height: 12),
                  _buildCategorySelector(l10n),
                  const SizedBox(height: 24),

                  // Availability
                  _buildSectionTitle(l10n.productAvailable),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: Text(
                      _isAvailable
                          ? l10n.productAvailable
                          : l10n.productUnavailable,
                    ),
                    value: _isAvailable,
                    onChanged: (value) {
                      setState(() {
                        _isAvailable = value;
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      l10n.editProduct,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageUploadSection(AppLocalizations l10n) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: _selectedImage != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedImage!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.edit),
                    label: Text(l10n.change),
                  ),
                ),
              ],
            )
          : _productEntity?.imageUrl != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: _productEntity!.imageUrl!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: double.infinity,
                          height: 200,
                          color: AppColors.surface,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: double.infinity,
                          height: 200,
                          color: AppColors.surface,
                          child: const Icon(Icons.fastfood, size: 40),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.edit),
                        label: Text(l10n.change),
                      ),
                    ),
                  ],
                )
              : InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_photo_alternate,
                          size: 60,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.tapToUploadRestaurantImage,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(AppLocalizations l10n) {
    return InkWell(
      onTap: _showCategoryPicker,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.category, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedCategory ?? l10n.tapToSelectCategories,
                style: TextStyle(
                  fontSize: 14,
                  color: _selectedCategory != null
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

