import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/market_product_categories.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/safe_navigation_wrapper.dart';
import '../../../market_products/domain/entities/market_product_entity.dart';
import '../../../market_products/presentation/cubits/market_product_cubit.dart';

class AdminEditMarketProductScreen extends StatefulWidget {
  final String productId;
  final MarketProductEntity? product;

  const AdminEditMarketProductScreen({
    super.key,
    required this.productId,
    this.product,
  });

  @override
  State<AdminEditMarketProductScreen> createState() =>
      _AdminEditMarketProductScreenState();
}

class _AdminEditMarketProductScreenState
    extends State<AdminEditMarketProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;

  File? _selectedImage;
  bool _isAvailable = true;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController = TextEditingController(text: widget.product!.name);
      _descriptionController =
          TextEditingController(text: widget.product!.description);
      _priceController =
          TextEditingController(text: widget.product!.price.toString());
      _selectedCategory = widget.product!.category;
      _isAvailable = widget.product!.isAvailable;
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _priceController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  List<String> _getAvailableCategories(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MarketProductCategories.getCategories(l10n);
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Failed to pick image: $e');
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Failed to take photo: $e');
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      context.showErrorSnackBar('Please enter a valid price');
      return;
    }

    // Validate category is selected
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      context.showErrorSnackBar('Please select a category');
      return;
    }

    context.read<MarketProductCubit>().updateMarketProduct(
          productId: widget.productId,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: price,
          category: _selectedCategory!,
          imageFile: _selectedImage,
          isAvailable: _isAvailable,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeNavigationWrapper(
      fallbackRoute: '/admin/market-products',
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.editProduct),
          backgroundColor: Colors.purple,
        ),
      body: BlocConsumer<MarketProductCubit, MarketProductState>(
        listener: (context, state) {
          if (state is MarketProductUpdated) {
            context.showSuccessSnackBar(l10n.productUpdatedSuccessfully);
            context.pop();
          } else if (state is MarketProductError) {
            context.showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          if (state is MarketProductLoading) {
            return LoadingWidget(message: l10n.updatingProduct);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Product Image
                  GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : widget.product?.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    widget.product!.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_photo_alternate,
                                            size: 64,
                                            color: AppColors.textSecondary,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            l10n.tapToUploadRestaurantImage,
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 64,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.tapToUploadRestaurantImage,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Product Name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.productName,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.fastfood),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.pleaseEnterProductName;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.productDescription,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.description),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.pleaseEnterProductDescription;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Price
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: l10n.productPrice,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.attach_money),
                      suffixText: l10n.currencySymbol,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.pleaseEnterProductPrice;
                      }
                      final price = double.tryParse(value.trim());
                      if (price == null || price <= 0) {
                        return l10n.invalidNumber;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category - Required
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: l10n.productCategory,
                      hintText: l10n.pleaseSelectCategory,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.category),
                    ),
                    items: _getAvailableCategories(context)
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseSelectCategory;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Availability
                  SwitchListTile(
                    title: Text(l10n.productAvailable),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.updateRestaurant),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      ),
    );
  }
}

