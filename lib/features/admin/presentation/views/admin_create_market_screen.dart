import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/market_product_categories.dart'; // Import constants
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/back_button_handler.dart';
import '../cubits/admin_cubit.dart';

class AdminCreateMarketScreen extends StatefulWidget {
  const AdminCreateMarketScreen({super.key});

  @override
  State<AdminCreateMarketScreen> createState() =>
      _AdminCreateMarketScreenState();
}

class _AdminCreateMarketScreenState extends State<AdminCreateMarketScreen> {
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

  // Fixed Market Categories
  late final List<Map<String, String>> _fixedMarketCategories;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    // Define the fixed categories for markets
    _fixedMarketCategories = [
      {
        'id': MarketProductCategories.fruitsVegetables,
        'name': MarketProductCategories.getCategoryName(
          MarketProductCategories.fruitsVegetables,
          l10n,
        ),
      },
      {
        'id': MarketProductCategories.pharmacy,
        'name': MarketProductCategories.getCategoryName(
          MarketProductCategories.pharmacy,
          l10n,
        ),
      },
      {
        'id': MarketProductCategories.cakeAndCoffee,
        'name': MarketProductCategories.getCategoryName(
          MarketProductCategories.cakeAndCoffee,
          l10n,
        ),
      },
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
        source: ImageSource.camera,
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
    setState(() {
      _selectedLocation = const LatLng(30.0444, 31.2357);
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
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(l10n.selectCategories),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _fixedMarketCategories.length,
                itemBuilder: (context, index) {
                  final category = _fixedMarketCategories[index];
                  final catId = category['id']!;
                  return CheckboxListTile(
                    title: Text(category['name']!),
                    value: _selectedCategoryIds.contains(catId),
                    onChanged: (selected) {
                      setStateDialog(() {
                        if (selected == true) {
                          _selectedCategoryIds.add(catId);
                        } else {
                          _selectedCategoryIds.remove(catId);
                        }
                      });
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
      ),
    );
  }

  void _submitForm() {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImage == null) {
      context.showErrorSnackBar(l10n.pleaseSelectImage);
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

    if (_passwordController.text != _confirmPasswordController.text) {
      context.showErrorSnackBar(l10n.passwordsDoNotMatch);
      return;
    }

    context.read<AdminCubit>().createRestaurant(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      categoryIds: _selectedCategoryIds,
      location: _selectedLocation!,
      imageFile: _selectedImage!,
      deliveryFee: double.parse(_deliveryFeeController.text),
      minOrderAmount: double.parse(_minOrderAmountController.text),
      estimatedDeliveryTime: int.parse(_estimatedDeliveryController.text),
      commercialRegistrationPhotoFile: _commercialRegistrationPhoto,
    );
  }

  bool get _hasUnsavedChanges {
    return _nameController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty ||
        _addressController.text.isNotEmpty ||
        _phoneController.text.isNotEmpty ||
        _emailController.text.isNotEmpty ||
        _selectedImage != null ||
        _commercialRegistrationPhoto != null ||
        _selectedCategoryIds.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return UnsavedChangesHandler(
      hasUnsavedChanges: _hasUnsavedChanges,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.createMarket)),
        body: BlocConsumer<AdminCubit, AdminState>(
          listener: (context, state) {
            if (state is RestaurantCreatedSuccess) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => AlertDialog(
                  title: Text(l10n.marketCreatedSuccessfully),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.provideCredentialsToMarket,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildCredentialRow(
                        '${l10n.email}:',
                        _emailController.text,
                      ),
                      const SizedBox(height: 8),
                      _buildCredentialRow(
                        '${l10n.password}:',
                        _passwordController.text,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.marketCanChangePasswordAfterLogin,
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        context.read<AdminCubit>().resetState();
                        context.go('/admin/restaurants');
                      },
                      child: Text(l10n.ok),
                    ),
                  ],
                ),
              );
            } else if (state is AdminError) {
              context.showErrorSnackBar(state.message);
            }
          },
          builder: (context, state) {
            if (state is AdminLoading) {
              return LoadingWidget(message: l10n.creatingMarket);
            }

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildImageUploadSection(l10n),
                    const SizedBox(height: 24),

                    _buildSectionTitle(l10n.basicInformation),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _nameController,
                      label: l10n.marketName,
                      icon: Icons.store_mall_directory,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.fieldRequired;
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
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _passwordController,
                      label: l10n.password,
                      icon: Icons.lock,
                      obscureText: _obscurePassword,
                      onToggleObscure: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.pleaseEnterPassword;
                        }
                        if (value.length < 6) {
                          return l10n.passwordMustBeAtLeast6Characters;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: l10n.confirmPassword,
                      icon: Icons.lock_outline,
                      obscureText: _obscureConfirmPassword,
                      onToggleObscure: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.pleaseConfirmPassword;
                        }
                        if (value != _passwordController.text) {
                          return l10n.passwordsDoNotMatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle(l10n.commercialRegistrationPhoto),
                    const SizedBox(height: 12),
                    _buildCommercialRegistrationPhotoSection(l10n),
                    const SizedBox(height: 24),

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

                    _buildSectionTitle(l10n.marketCategory),
                    const SizedBox(height: 12),
                    _buildCategorySelector(l10n),
                    const SizedBox(height: 24),

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

                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(
                        l10n.createMarket,
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
                      l10n.tapToUploadMarketImage,
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
                    children: _selectedCategoryIds.map((categoryId) {
                      final categoryName = _fixedMarketCategories.firstWhere(
                        (c) => c['id'] == categoryId,
                        orElse: () => {'name': 'Unknown'},
                      )['name']!;

                      return Chip(
                        label: Text(categoryName),
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
            color: Colors.grey,
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

  Widget _buildCredentialRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: SelectableText(value)), // Copy-paste friendly
      ],
    );
  }

  Widget _buildCommercialRegistrationPhotoSection(AppLocalizations l10n) {
    return Container(
      height: 150,
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
                    height: 150,
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
          : InkWell(
              onTap: _takeCommercialRegistrationPhoto,
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      l10n.takePhoto,
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
}
