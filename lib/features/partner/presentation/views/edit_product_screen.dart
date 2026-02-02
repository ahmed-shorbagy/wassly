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
import '../../../../features/auth/presentation/cubits/auth_cubit.dart';
import '../../../../features/restaurants/presentation/cubits/food_category_cubit.dart';
import '../../../../features/restaurants/domain/entities/food_category_entity.dart';
import '../../../../features/admin/presentation/cubits/admin_product_cubit.dart';
import '../../../../features/restaurants/presentation/cubits/restaurant_cubit.dart';
import '../../../../features/restaurants/domain/entities/product_entity.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;
  const EditProductScreen({super.key, required this.productId});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  File? _selectedImage;
  bool _isAvailable = true;
  String? _selectedCategoryId;
  String? _restaurantId;
  ProductEntity? _product;

  @override
  void initState() {
    super.initState();
    _loadRestaurantAndProduct();
  }

  void _loadRestaurantAndProduct() {
    // 1. Get Restaurant ID
    final restaurantState = context.read<RestaurantCubit>().state;
    if (restaurantState is RestaurantLoaded) {
      _restaurantId = restaurantState.restaurant.id;
    } else if (restaurantState is RestaurantsLoaded) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        try {
          final myRestaurant = restaurantState.restaurants.firstWhere(
            (r) => r.ownerId == authState.user.id,
          );
          _restaurantId = myRestaurant.id;
        } catch (_) {}
      }
    }

    if (_restaurantId != null) {
      _loadCategories();
      _findProductInState();
    }
  }

  void _findProductInState() {
    // Try to find product in the loaded products list
    final productsState = context.read<RestaurantCubit>().state;

    if (productsState is ProductsLoaded) {
      try {
        _product = productsState.products.firstWhere(
          (p) => p.id == widget.productId,
        );
        _initializeForm();
      } catch (_) {}
    }
  }

  void _initializeForm() {
    if (_product == null) return;
    _nameController.text = _product!.name;
    _descriptionController.text = _product!.description;
    _priceController.text = _product!.price.toString();
    _selectedCategoryId = _product!.categoryId;
    _isAvailable = _product!.isAvailable;
    setState(() {});
  }

  void _loadCategories() {
    if (_restaurantId != null) {
      context.read<FoodCategoryCubit>().loadRestaurantCategories(
        _restaurantId!,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
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

  void _showCategoryPicker(
    BuildContext context,
    List<FoodCategoryEntity> categories,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (categories.isEmpty) {
      context.showErrorSnackBar(l10n.noCategoriesFound);
      return;
    }
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
                title: Text(category.name),
                selected: _selectedCategoryId == category.id,
                onTap: () {
                  setState(() {
                    _selectedCategoryId = category.id;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_restaurantId == null) {
      context.showErrorSnackBar('Restaurant ID not found. Please reload.');
      return;
    }
    if (_selectedCategoryId == null) {
      context.showErrorSnackBar(l10n.pleaseSelectProductCategory);
      return;
    }

    if (_product == null) {
      context.showErrorSnackBar('Product not loaded');
      return;
    }

    context.read<AdminProductCubit>().updateProduct(
      product: _product!,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text),
      categoryId: _selectedCategoryId,
      imageFile: _selectedImage, // Optional for update
      isAvailable: _isAvailable,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProduct),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<AdminProductCubit, AdminProductState>(
        listener: (context, state) {
          if (state is AdminProductUpdated) {
            context.read<AdminProductCubit>().resetState();
            context.pop();
          } else if (state is AdminProductError) {
            context.showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          if (state is AdminProductLoading) {
            return LoadingWidget(message: l10n.updatingProduct);
          }

          if (_restaurantId == null) {
            return const Center(
              child: LoadingWidget(message: 'Loading data...'),
            );
          }

          if (_product == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Product not found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Retry finding it
                      _loadRestaurantAndProduct();
                      setState(() {});
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildImageUploadSection(l10n),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _nameController,
                  label: l10n.productName,
                  icon: Icons.fastfood,
                  validator: (value) =>
                      value!.isEmpty ? l10n.pleaseEnterProductName : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: l10n.productDescription,
                  icon: Icons.description,
                  maxLines: 3,
                  validator: (value) => value!.isEmpty
                      ? l10n.pleaseEnterProductDescription
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _priceController,
                  label: l10n.productPrice,
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? l10n.pleaseEnterProductPrice : null,
                ),
                const SizedBox(height: 24),
                BlocBuilder<FoodCategoryCubit, FoodCategoryState>(
                  builder: (context, state) {
                    if (state is FoodCategoryLoaded) {
                      return _buildCategorySelector(
                        context,
                        l10n,
                        state.categories,
                      );
                    }
                    return _buildCategorySelector(context, l10n, []);
                  },
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: Text(
                    _isAvailable
                        ? l10n.productAvailable
                        : l10n.productUnavailable,
                  ),
                  value: _isAvailable,
                  onChanged: (val) => setState(() => _isAvailable = val),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(l10n.saveChanges),
                ),
              ],
            ),
          );
        },
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
      child: Stack(
        children: [
          if (_selectedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _selectedImage!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            )
          else if (_product?.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: _product!.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            )
          else
            Center(
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
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

          Positioned(
            bottom: 8,
            right: 8,
            child: IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
              onPressed: _pickImage,
            ),
          ),
        ],
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
      ),
    );
  }

  Widget _buildCategorySelector(
    BuildContext context,
    AppLocalizations l10n,
    List<FoodCategoryEntity> categories,
  ) {
    String displayName = l10n.tapToSelectCategories;
    if (_selectedCategoryId != null && categories.isNotEmpty) {
      try {
        final selectedCategory = categories.firstWhere(
          (c) => c.id == _selectedCategoryId,
        );
        displayName = selectedCategory.name;
      } catch (_) {}
    }

    return InkWell(
      onTap: () => _showCategoryPicker(context, categories),
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
            Expanded(child: Text(displayName)),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
