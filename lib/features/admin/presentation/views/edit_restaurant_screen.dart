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
import '../cubits/admin_cubit.dart';

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
  final List<String> _selectedCategories = [];
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoadingRestaurant = true;
  RestaurantEntity? _currentRestaurant;

  @override
  void initState() {
    super.initState();
    _loadRestaurant();
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
    _minOrderAmountController.text = restaurant.minOrderAmount.toStringAsFixed(2);
    _estimatedDeliveryController.text = restaurant.estimatedDeliveryTime.toString();
    _selectedCategories.addAll(restaurant.categories);
    
    // Set location
    if (restaurant.location.containsKey('latitude') && 
        restaurant.location.containsKey('longitude')) {
      _selectedLocation = LatLng(
        (restaurant.location['latitude'] as num).toDouble(),
        (restaurant.location['longitude'] as num).toDouble(),
      );
    }
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
      // Specific Arabian dishes
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
      // International categories
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
    final categories = _getAvailableCategories(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectCategories),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return CheckboxListTile(
                title: Text(category),
                value: _selectedCategories.contains(category),
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedCategories.add(category);
                    } else {
                      _selectedCategories.remove(category);
                    }
                  });
                  Navigator.pop(context);
                  _showCategoryPicker();
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
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLocation == null) {
      context.showErrorSnackBar(l10n.pleaseSelectLocation);
      return;
    }

    if (_selectedCategories.isEmpty) {
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

    context.read<AdminCubit>().updateRestaurant(
      restaurantId: widget.restaurantId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      newPassword: newPassword,
      categories: _selectedCategories,
      location: _selectedLocation!,
      imageFile: _selectedImage,
      deliveryFee: double.parse(_deliveryFeeController.text),
      minOrderAmount: double.parse(_minOrderAmountController.text),
      estimatedDeliveryTime: int.parse(_estimatedDeliveryController.text),
      commercialRegistrationPhotoFile: _commercialRegistrationPhoto,
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
                    if (value != null && value.isNotEmpty && value.length < 6) {
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
        child: _selectedCategories.isEmpty
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
            : Column(
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
                    children: _selectedCategories
                        .map(
                          (category) => Chip(
                            label: Text(category),
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setState(() {
                                _selectedCategories.remove(category);
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
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
}

