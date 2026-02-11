import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../features/auth/presentation/cubits/auth_cubit.dart';
import '../../../../features/restaurants/presentation/cubits/food_category_cubit.dart';
import '../../../../features/restaurants/domain/entities/food_category_entity.dart';
import '../../../../features/admin/presentation/cubits/admin_product_cubit.dart';
import '../../../../features/restaurants/presentation/cubits/restaurant_cubit.dart';
import '../../../../features/restaurants/domain/entities/product_options.dart';

class AddProductScreen extends StatefulWidget {
  final String? restaurantId;
  const AddProductScreen({super.key, this.restaurantId});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  File? _selectedImage;
  bool _isAvailable = true;
  String? _selectedCategoryId;
  String? _restaurantId;
  final List<ProductOptionGroup> _optionGroups = [];

  @override
  void initState() {
    super.initState();
    _restaurantId = widget.restaurantId;
    _loadRestaurantData();
  }

  void _loadRestaurantData() {
    if (_restaurantId != null) {
      _loadCategories();
      return;
    }

    // Try to get restaurant ID from cubit state if available
    final restaurantState = context.read<RestaurantCubit>().state;
    if (restaurantState is RestaurantLoaded) {
      _restaurantId = restaurantState.restaurant.id;
      _loadCategories();
    } else if (restaurantState is RestaurantsLoaded) {
      // Try to find the user's restaurant in the list
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        try {
          final myRestaurant = restaurantState.restaurants.firstWhere(
            (r) => r.ownerId == authState.user.id,
          );
          _restaurantId = myRestaurant.id;
          _loadCategories();
        } catch (_) {
          // No match found
        }
      }
    } else if (restaurantState is ProductsLoaded) {
      // If products are loaded, we might have restaurantId from AuthCubit
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        // We can't easily get it from ProductsLoaded state directly without the restaurant object
        // So we'll trigger a reload of restaurant data
        context.read<RestaurantCubit>().getRestaurantByOwnerId(
          authState.user.id,
        );
      }
    }
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

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_restaurantId == null) {
      context.showErrorSnackBar('Restaurant ID not found. Please reload.');
      return;
    }

    if (_selectedImage == null) {
      context.showErrorSnackBar(l10n.pleaseSelectProductImage);
      return;
    }

    if (_selectedCategoryId == null) {
      context.showErrorSnackBar(l10n.pleaseSelectProductCategory);
      return;
    }

    // Reuse AdminProductCubit as it likely has the usecase logic
    // Alternatively, we should have a PartnerProductCubit
    context.read<AdminProductCubit>().addProduct(
      restaurantId: _restaurantId!,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text),
      categoryId: _selectedCategoryId,
      imageFile: _selectedImage!,
      isAvailable: _isAvailable,
      optionGroups: _optionGroups,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addProduct),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AdminProductCubit, AdminProductState>(
            listener: (context, state) {
              if (state is AdminProductAdded) {
                context.read<AdminProductCubit>().resetState();
                context.pop();
              } else if (state is AdminProductError) {
                context.showErrorSnackBar(state.message);
              }
            },
          ),
          BlocListener<RestaurantCubit, RestaurantState>(
            listener: (context, state) {
              if (state is RestaurantLoaded && _restaurantId == null) {
                setState(() {
                  _restaurantId = state.restaurant.id;
                });
                _loadCategories();
              } else if (state is RestaurantsLoaded && _restaurantId == null) {
                final authState = context.read<AuthCubit>().state;
                if (authState is AuthAuthenticated) {
                  try {
                    final myRestaurant = state.restaurants.firstWhere(
                      (r) => r.ownerId == authState.user.id,
                    );
                    setState(() {
                      _restaurantId = myRestaurant.id;
                    });
                    _loadCategories();
                  } catch (_) {}
                }
              }
            },
          ),
        ],
        child: BlocBuilder<AdminProductCubit, AdminProductState>(
          builder: (context, state) {
            if (state is AdminProductLoading) {
              return LoadingWidget(message: l10n.creatingProduct);
            }

            if (_restaurantId == null) {
              return Center(child: Text('Loading restaurant data...'));
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

                  const SizedBox(height: 24),
                  _buildOptionsSection(l10n),

                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(l10n.addProduct),
                  ),
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
                    onPressed: () => setState(() => _selectedImage = null),
                  ),
                ),
              ],
            )
          : InkWell(
              onTap: _pickImage,
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
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
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

  Widget _buildOptionsSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.productOptions,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _addOptionGroup,
              icon: const Icon(Icons.add),
              label: Text(l10n.addGroup),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_optionGroups.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                l10n.noOptionsAdded,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _optionGroups.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildOptionGroupItem(index, l10n);
            },
          ),
      ],
    );
  }

  void _addOptionGroup() {
    setState(() {
      _optionGroups.add(
        ProductOptionGroup(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: '',
          allowMultiple: false,
          isRequired: false,
          options: [],
        ),
      );
    });
  }

  Widget _buildOptionGroupItem(int groupIndex, AppLocalizations l10n) {
    final group = _optionGroups[groupIndex];
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: group.name,
                    decoration: InputDecoration(
                      labelText: l10n.groupName,
                      hintText: 'e.g., Size, Addons',
                      isDense: true,
                    ),
                    onChanged: (val) {
                      _optionGroups[groupIndex] = group.copyWith(name: val);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => setState(() {
                    _optionGroups.removeAt(groupIndex);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: Text(l10n.multipleSelections),
                    value: group.allowMultiple,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setState(() {
                        _optionGroups[groupIndex] = group.copyWith(
                          allowMultiple: val ?? false,
                        );
                      });
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text(l10n.required),
                    value: group.isRequired,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setState(() {
                        _optionGroups[groupIndex] = group.copyWith(
                          isRequired: val ?? false,
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildOptionsList(groupIndex, l10n),
            TextButton.icon(
              onPressed: () => _addOptionToGroup(groupIndex),
              icon: const Icon(Icons.add_circle_outline),
              label: Text(l10n.addOption),
            ),
          ],
        ),
      ),
    );
  }

  void _addOptionToGroup(int groupIndex) {
    setState(() {
      final group = _optionGroups[groupIndex];
      final newOptions = List<ProductOption>.from(group.options)
        ..add(
          ProductOption(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: '',
            priceModifier: 0,
          ),
        );
      _optionGroups[groupIndex] = group.copyWith(options: newOptions);
    });
  }

  Widget _buildOptionsList(int groupIndex, AppLocalizations l10n) {
    final group = _optionGroups[groupIndex];
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: group.options.length,
      itemBuilder: (context, optionIndex) {
        final option = group.options[optionIndex];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  initialValue: option.name,
                  decoration: InputDecoration(
                    labelText: l10n.optionName,
                    isDense: true,
                  ),
                  onChanged: (val) {
                    final newOptions = List<ProductOption>.from(group.options);
                    newOptions[optionIndex] = option.copyWith(name: val);
                    _optionGroups[groupIndex] = group.copyWith(
                      options: newOptions,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextFormField(
                  initialValue: option.priceModifier.toString(),
                  decoration: InputDecoration(
                    labelText: l10n.price,
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final price = double.tryParse(val) ?? 0;
                    final newOptions = List<ProductOption>.from(group.options);
                    newOptions[optionIndex] = option.copyWith(
                      priceModifier: price,
                    );
                    _optionGroups[groupIndex] = group.copyWith(
                      options: newOptions,
                    );
                  },
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() {
                  final newOptions = List<ProductOption>.from(group.options)
                    ..removeAt(optionIndex);
                  _optionGroups[groupIndex] = group.copyWith(
                    options: newOptions,
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
