import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/safe_navigation_wrapper.dart';
import '../../../restaurants/domain/entities/restaurant_entity.dart';
import '../../../restaurants/domain/entities/product_entity.dart';
import '../../../restaurants/domain/entities/restaurant_category_entity.dart';
import '../cubits/admin_cubit.dart';
import '../cubits/admin_restaurant_category_cubit.dart';

class EditRestaurantScreen extends StatefulWidget {
  final String restaurantId;
  final RestaurantEntity? restaurant;

  const EditRestaurantScreen({
    super.key,
    required this.restaurantId,
    this.restaurant,
  });

  @override
  State<EditRestaurantScreen> createState() => _EditRestaurantScreenState();
}

class _EditRestaurantScreenState extends State<EditRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _deliveryFeeController = TextEditingController(text: '0.0');
  final _minOrderAmountController = TextEditingController(text: '0.0');
  final _estimatedDeliveryController = TextEditingController(text: '30');

  File? _selectedImage;
  File? _commercialRegistrationPhoto;
  LatLng? _selectedLocation;
  final List<String> _selectedCategoryIds = [];
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoadingRestaurant = true;
  RestaurantEntity? _currentRestaurant;

  // Discount fields
  final _discountPercentageController = TextEditingController();
  final _discountDescriptionController = TextEditingController();
  bool _hasDiscount = false;
  DateTime? _discountStartDate;
  DateTime? _discountEndDate;
  File? _discountImage;
  String? _selectedTargetProductId;
  List<ProductEntity> _products = [];
  bool _isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    context.read<AdminRestaurantCategoryCubit>().loadCategories();
    _loadRestaurant();
    context.read<AdminCubit>().getRestaurantProducts(widget.restaurantId);
  }

  Future<void> _loadRestaurant() async {
    if (widget.restaurant != null) {
      setState(() {
        _currentRestaurant = widget.restaurant as RestaurantEntity;
        _isLoadingRestaurant = false;
      });
      _populateForm();
    } else {
      // Fetch restaurant by ID using AdminCubit
      context.read<AdminCubit>().getRestaurantById(widget.restaurantId);
    }
  }

  void _handleCubitState(AdminState state) {
    if (state is RestaurantLoaded) {
      setState(() {
        _currentRestaurant = state.restaurant;
        _isLoadingRestaurant = false;
      });
      _populateForm();
    } else if (state is AdminError) {
      setState(() {
        _isLoadingRestaurant = false;
      });
    } else if (state is AdminProductsLoaded) {
      setState(() {
        _products = state.products;
        _isLoadingProducts = false;
      });
    }
  }

  void _populateForm() {
    if (_currentRestaurant == null) return;

    final restaurant = _currentRestaurant!;
    _nameController.text = restaurant.name;
    _descriptionController.text = restaurant.description;
    _addressController.text = restaurant.address;
    _phoneController.text = restaurant.phone;
    _emailController.text = restaurant.email ?? '';
    _deliveryFeeController.text = restaurant.deliveryFee.toStringAsFixed(2);
    _minOrderAmountController.text = restaurant.minOrderAmount.toStringAsFixed(
      2,
    );
    _estimatedDeliveryController.text = restaurant.estimatedDeliveryTime
        .toString();
    _selectedCategoryIds.clear();
    _selectedCategoryIds.addAll(restaurant.categoryIds);

    // Populate discount fields
    _hasDiscount = restaurant.hasDiscount;
    _discountPercentageController.text =
        restaurant.discountPercentage?.toStringAsFixed(0) ?? '';
    _discountDescriptionController.text = restaurant.discountDescription ?? '';
    _discountStartDate = restaurant.discountStartDate;
    _discountStartDate = restaurant.discountStartDate;
    _discountEndDate = restaurant.discountEndDate;
    _selectedTargetProductId = restaurant.discountTargetProductId;

    // Set location
    if (restaurant.location.containsKey('latitude') &&
        restaurant.location.containsKey('longitude')) {
      _selectedLocation = LatLng(
        (restaurant.location['latitude'] as num).toDouble(),
        (restaurant.location['longitude'] as num).toDouble(),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _deliveryFeeController.dispose();
    _minOrderAmountController.dispose();
    _estimatedDeliveryController.dispose();
    _discountPercentageController.dispose();
    _discountDescriptionController.dispose();
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

  Future<void> _takeCommercialRegistrationPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera, // Camera only
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _commercialRegistrationPhoto = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        context.showErrorSnackBar(l10n.failedToPickImage(e.toString()));
      }
    }
  }

  Future<void> _pickLocation() async {
    // For now, use a default location
    setState(() {
      _selectedLocation = _selectedLocation ?? const LatLng(30.0444, 31.2357);
    });
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      context.showInfoSnackBar(l10n.locationSetToCairo);
    }
  }

  void _showCategoryPicker() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) =>
          BlocBuilder<
            AdminRestaurantCategoryCubit,
            AdminRestaurantCategoryState
          >(
            builder: (context, state) {
              if (state is AdminRestaurantCategoryLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is AdminRestaurantCategoryError) {
                return AlertDialog(
                  title: Text(l10n.error),
                  content: Text(state.message),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.ok),
                    ),
                  ],
                );
              }

              if (state is AdminRestaurantCategoriesLoaded) {
                final categories = state.categories;
                // Use StatefulBuilder to update checkboxes within dialog
                return StatefulBuilder(
                  builder: (context, setStateDialog) {
                    return AlertDialog(
                      title: Text(l10n.selectCategories),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: categories.isEmpty
                            ? Center(child: Text(l10n.noCategoriesAvailable))
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  final category = categories[index];
                                  return CheckboxListTile(
                                    title: Text(category.name),
                                    value: _selectedCategoryIds.contains(
                                      category.id,
                                    ),
                                    onChanged: (selected) {
                                      setStateDialog(() {
                                        if (selected == true) {
                                          _selectedCategoryIds.add(category.id);
                                        } else {
                                          _selectedCategoryIds.remove(
                                            category.id,
                                          );
                                        }
                                      });
                                      // Also update the main screen state
                                      setState(() {});
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
                    );
                  },
                );
              }
              return const SizedBox();
            },
          ),
    );
  }

  void _submitForm() {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLocation == null) {
      context.showErrorSnackBar(l10n.pleaseSelectLocation);
      return;
    }

    if (_selectedCategoryIds.isEmpty) {
      context.showErrorSnackBar(l10n.pleaseSelectAtLeastOneCategory);
      return;
    }

    // Validate password if provided
    String? newPassword;
    if (_passwordController.text.trim().isNotEmpty) {
      if (_passwordController.text != _confirmPasswordController.text) {
        context.showErrorSnackBar(l10n.passwordsDoNotMatch);
        return;
      }
      if (_passwordController.text.length < 6) {
        context.showErrorSnackBar(l10n.passwordMustBeAtLeast6Characters);
        return;
      }
      newPassword = _passwordController.text.trim();
    }

    // Validate discount if enabled
    if (_hasDiscount && _discountPercentageController.text.isEmpty) {
      context.showErrorSnackBar(l10n.discountPercentage);
      return;
    }

    context.read<AdminCubit>().updateRestaurant(
      restaurantId: widget.restaurantId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      newPassword: newPassword,
      categoryIds: _selectedCategoryIds,
      location: _selectedLocation!,
      imageFile: _selectedImage,
      deliveryFee: double.parse(_deliveryFeeController.text),
      minOrderAmount: double.parse(_minOrderAmountController.text),
      estimatedDeliveryTime: int.parse(_estimatedDeliveryController.text),
      commercialRegistrationPhotoFile: _commercialRegistrationPhoto,
      hasDiscount: _hasDiscount,
      discountPercentage:
          _hasDiscount && _discountPercentageController.text.isNotEmpty
          ? double.tryParse(_discountPercentageController.text)
          : null,
      discountDescription:
          _hasDiscount && _discountDescriptionController.text.isNotEmpty
          ? _discountDescriptionController.text.trim()
          : null,
      discountStartDate: _hasDiscount ? _discountStartDate : null,
      discountEndDate: _hasDiscount ? _discountEndDate : null,
      discountImageFile: _hasDiscount ? _discountImage : null,
      discountTargetProductId: _hasDiscount ? _selectedTargetProductId : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoadingRestaurant) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.editRestaurant)),
        body: LoadingWidget(message: l10n.loading),
      );
    }

    if (_currentRestaurant == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.editRestaurant)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(l10n.restaurantNotFound),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/admin/restaurants'),
                child: Text(l10n.back),
              ),
            ],
          ),
        ),
      );
    }

    return SafeNavigationWrapper(
      fallbackRoute: '/admin/restaurants',
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.editRestaurant),
          backgroundColor: Colors.purple,
        ),
        body: BlocConsumer<AdminCubit, AdminState>(
          listener: (context, state) {
            if (state is RestaurantLoaded) {
              _handleCubitState(state);
            } else if (state is RestaurantUpdatedSuccess) {
              context.showSuccessSnackBar(l10n.restaurantUpdatedSuccessfully);
              context.pop();
            } else if (state is AdminError) {
              context.showErrorSnackBar(state.message);
              _handleCubitState(state);
            }
          },
          builder: (context, state) {
            if (state is AdminLoading) {
              return LoadingWidget(message: l10n.updatingRestaurant);
            }

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Upload Section
                    _buildImageUploadSection(l10n),
                    const SizedBox(height: 24),

                    // Basic Information
                    _buildSectionTitle(l10n.basicInformation),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _nameController,
                      label: l10n.restaurantName,
                      icon: Icons.restaurant,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.pleaseEnterRestaurantName;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descriptionController,
                      label: l10n.description,
                      icon: Icons.description,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.pleaseEnterDescription;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Contact Information
                    _buildSectionTitle(l10n.contactInformation),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _phoneController,
                      label: l10n.phoneNumber,
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.pleaseEnterPhoneNumber;
                        }
                        if (!value.isValidPhone) {
                          return l10n.pleaseEnterValidPhoneNumber;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: l10n.email,
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.pleaseEnterEmail;
                        }
                        if (!value.isValidEmail) {
                          return l10n.pleaseEnterValidEmail;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Password Section
                    _buildSectionTitle(l10n.updatePassword),
                    const SizedBox(height: 12),
                    Text(
                      l10n.leavePasswordEmptyToKeepCurrent,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      controller: _passwordController,
                      label: l10n.newPassword,
                      icon: Icons.lock,
                      obscureText: _obscurePassword,
                      onToggleObscure: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            value.length < 6) {
                          return l10n.passwordMustBeAtLeast6Characters;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: l10n.confirmNewPassword,
                      icon: Icons.lock_outline,
                      obscureText: _obscureConfirmPassword,
                      onToggleObscure: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      validator: (value) {
                        if (_passwordController.text.isNotEmpty) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.pleaseConfirmPassword;
                          }
                          if (value != _passwordController.text) {
                            return l10n.passwordsDoNotMatch;
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Commercial Registration Photo
                    _buildSectionTitle(l10n.commercialRegistrationPhoto),
                    const SizedBox(height: 12),
                    _buildCommercialRegistrationPhotoSection(l10n),
                    const SizedBox(height: 24),

                    // Location
                    _buildSectionTitle(l10n.location),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _addressController,
                      label: l10n.address,
                      icon: Icons.location_on,
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.pleaseEnterAddress;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildLocationPicker(l10n),
                    const SizedBox(height: 24),

                    // Categories
                    _buildSectionTitle(l10n.categories),
                    const SizedBox(height: 12),
                    _buildCategorySelector(l10n),
                    const SizedBox(height: 24),

                    // Delivery Settings
                    _buildSectionTitle(l10n.deliverySettings),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _deliveryFeeController,
                            label: l10n.deliveryFee,
                            icon: Icons.delivery_dining,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.required;
                              }
                              if (double.tryParse(value) == null) {
                                return l10n.invalidNumber;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _minOrderAmountController,
                            label: l10n.minOrder,
                            icon: Icons.shopping_cart,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.required;
                              }
                              if (double.tryParse(value) == null) {
                                return l10n.invalidNumber;
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _estimatedDeliveryController,
                      label: l10n.estimatedDeliveryTime,
                      icon: Icons.timer,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.required;
                        }
                        if (int.tryParse(value) == null) {
                          return l10n.invalidNumber;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Discount Management Section
                    _buildSectionTitle(l10n.discount),
                    const SizedBox(height: 12),
                    _buildDiscountSection(l10n),
                    const SizedBox(height: 32),

                    // Update Button
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        l10n.updateRestaurant,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
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
          : _currentRestaurant?.imageUrl != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _currentRestaurant!.imageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage(l10n);
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
          : _buildPlaceholderImage(l10n),
    );
  }

  Widget _buildPlaceholderImage(AppLocalizations l10n) {
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(12),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate, size: 60, color: Colors.grey),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscureText,
    required VoidCallback onToggleObscure,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
            color: AppColors.textSecondary,
          ),
          onPressed: onToggleObscure,
        ),
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

  Widget _buildLocationPicker(AppLocalizations l10n) {
    return InkWell(
      onTap: _pickLocation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.map, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedLocation != null
                    ? l10n.locationSet(
                        _selectedLocation!.latitude.toStringAsFixed(4),
                        _selectedLocation!.longitude.toStringAsFixed(4),
                      )
                    : l10n.tapToSelectLocationOnMap,
                style: TextStyle(
                  fontSize: 14,
                  color: _selectedLocation != null
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

  Widget _buildCategorySelector(AppLocalizations l10n) {
    return InkWell(
      onTap: _showCategoryPicker,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _selectedCategoryIds.isEmpty
            ? Row(
                children: [
                  const Icon(Icons.category, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.tapToSelectCategories,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              )
            : BlocBuilder<
                AdminRestaurantCategoryCubit,
                AdminRestaurantCategoryState
              >(
                builder: (context, state) {
                  List<RestaurantCategoryEntity> categories = [];
                  if (state is AdminRestaurantCategoriesLoaded) {
                    categories = state.categories;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.selectedCategories,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: _showCategoryPicker,
                            child: Text(l10n.edit),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedCategoryIds.map((categoryId) {
                          final category = categories
                              .cast<RestaurantCategoryEntity>()
                              .firstWhere(
                                (c) => c.id == categoryId,
                                orElse: () => RestaurantCategoryEntity(
                                  id: categoryId,
                                  name: l10n.unknown,
                                  imageUrl: '',
                                  isActive: true,
                                  displayOrder: 0,
                                  createdAt: DateTime.now(),
                                ),
                              );

                          return Chip(
                            label: Text(category.name),
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setState(() {
                                _selectedCategoryIds.remove(categoryId);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildCommercialRegistrationPhotoSection(AppLocalizations l10n) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: _commercialRegistrationPhoto != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _commercialRegistrationPhoto!,
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
                        _commercialRegistrationPhoto = null;
                      });
                    },
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: ElevatedButton.icon(
                    onPressed: _takeCommercialRegistrationPhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(l10n.change),
                  ),
                ),
              ],
            )
          : _currentRestaurant?.commercialRegistrationPhotoUrl != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _currentRestaurant!.commercialRegistrationPhotoUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildCommercialRegistrationPlaceholder(l10n);
                    },
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: ElevatedButton.icon(
                    onPressed: _takeCommercialRegistrationPhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(l10n.change),
                  ),
                ),
              ],
            )
          : _buildCommercialRegistrationPlaceholder(l10n),
    );
  }

  Widget _buildCommercialRegistrationPlaceholder(AppLocalizations l10n) {
    return InkWell(
      onTap: _takeCommercialRegistrationPhoto,
      borderRadius: BorderRadius.circular(12),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              l10n.openCamera,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.commercialRegistrationPhoto,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enable Discount Switch
          SwitchListTile(
            title: Text(l10n.enableDiscount),
            value: _hasDiscount,
            onChanged: (value) {
              setState(() {
                _hasDiscount = value;
              });
            },
          ),
          const SizedBox(height: 16),

          if (_hasDiscount) ...[
            // Discount Percentage
            _buildTextField(
              controller: _discountPercentageController,
              label: l10n.discountPercentage,
              icon: Icons.percent,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (_hasDiscount && (value == null || value.isEmpty)) {
                  return l10n.discountPercentage;
                }
                if (value != null && value.isNotEmpty) {
                  final percentage = double.tryParse(value);
                  if (percentage == null ||
                      percentage < 0 ||
                      percentage > 100) {
                    return '${l10n.discountPercentage} (0-100)';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Discount Description
            _buildTextField(
              controller: _discountDescriptionController,
              label: l10n.discountDescription,
              icon: Icons.description,
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Discount Image
            Text(
              '${l10n.discountImage} (${l10n.optional})',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            _buildDiscountImageSection(l10n),
            const SizedBox(height: 16),

            // Target Product (Optional)
            Text(
              '${l10n.linkedProduct} (${l10n.optional})',
              // TODO: Add localization key for 'Linked Product'
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            _isLoadingProducts
                ? const LinearProgressIndicator()
                : DropdownButtonFormField<String>(
                    initialValue: _selectedTargetProductId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      hintText: l10n.selectProductToLink,
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text(l10n.noLinkedProduct),
                      ),
                      ..._products.map((product) {
                        return DropdownMenuItem<String>(
                          value: product.id,
                          child: Text(
                            product.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedTargetProductId = value;
                      });
                    },
                  ),
            const SizedBox(height: 16),

            // Start Date
            ListTile(
              leading: const Icon(
                Icons.calendar_today,
                color: AppColors.primary,
              ),
              title: Text(l10n.discountStartDate),
              subtitle: Text(
                _discountStartDate != null
                    ? '${_discountStartDate!.day}/${_discountStartDate!.month}/${_discountStartDate!.year}'
                    : '${l10n.discountStartDate} (${l10n.optional})',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _discountStartDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    _discountStartDate = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 8),

            // End Date
            ListTile(
              leading: const Icon(Icons.event, color: AppColors.primary),
              title: Text(l10n.discountEndDate),
              subtitle: Text(
                _discountEndDate != null
                    ? '${_discountEndDate!.day}/${_discountEndDate!.month}/${_discountEndDate!.year}'
                    : '${l10n.discountEndDate} (${l10n.optional})',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate:
                      _discountEndDate ??
                      (_discountStartDate ?? DateTime.now()).add(
                        const Duration(days: 7),
                      ),
                  firstDate: _discountStartDate ?? DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    _discountEndDate = picked;
                  });
                }
              },
            ),

            // Current discount status
            if (_currentRestaurant != null &&
                _currentRestaurant!.isDiscountActive)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${l10n.discount} : ${l10n.active}',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiscountImageSection(AppLocalizations l10n) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: _discountImage != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _discountImage!,
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
                        _discountImage = null;
                      });
                    },
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: ElevatedButton.icon(
                    onPressed: _pickDiscountImage,
                    icon: const Icon(Icons.edit),
                    label: Text(l10n.change),
                  ),
                ),
              ],
            )
          : _currentRestaurant?.discountImageUrl != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _currentRestaurant!.discountImageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDiscountImagePlaceholder(l10n);
                    },
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: ElevatedButton.icon(
                    onPressed: _pickDiscountImage,
                    icon: const Icon(Icons.edit),
                    label: Text(l10n.change),
                  ),
                ),
              ],
            )
          : _buildDiscountImagePlaceholder(l10n),
    );
  }

  Widget _buildDiscountImagePlaceholder(AppLocalizations l10n) {
    return InkWell(
      onTap: _pickDiscountImage,
      borderRadius: BorderRadius.circular(12),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              l10n.tapToUploadDiscountImage,
              // Use hardcoded string as 'tapToUploadDiscountImage' key doesn't exist
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDiscountImage() async {
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
          _discountImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        context.showErrorSnackBar(l10n.failedToPickImage(e.toString()));
      }
    }
  }
}
