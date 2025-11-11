import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../cubits/admin_cubit.dart';

class CreateRestaurantScreen extends StatefulWidget {
  const CreateRestaurantScreen({super.key});

  @override
  State<CreateRestaurantScreen> createState() => _CreateRestaurantScreenState();
}

class _CreateRestaurantScreenState extends State<CreateRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _deliveryFeeController = TextEditingController(text: '0.0');
  final _minOrderAmountController = TextEditingController(text: '0.0');
  final _estimatedDeliveryController = TextEditingController(text: '30');

  File? _selectedImage;
  LatLng? _selectedLocation;
  final List<String> _selectedCategories = [];
  final List<String> _availableCategories = [
    'Fast Food',
    'Italian',
    'Chinese',
    'Indian',
    'Mexican',
    'Japanese',
    'Thai',
    'Mediterranean',
    'American',
    'Vegetarian',
    'Vegan',
    'Desserts',
    'Beverages',
    'Healthy',
    'BBQ',
    'Seafood',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
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
        context.showErrorSnackBar('Failed to pick image: $e');
      }
    }
  }

  Future<void> _pickLocation() async {
    // For now, use a default location (Cairo, Egypt)
    // In production, you'd integrate with Google Maps Place Picker
    setState(() {
      _selectedLocation = const LatLng(30.0444, 31.2357);
    });
    if (mounted) {
      context.showInfoSnackBar('Location set to Cairo, Egypt');
    }
  }

  void _showCategoryPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Categories'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _availableCategories.length,
            itemBuilder: (context, index) {
              final category = _availableCategories[index];
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
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImage == null) {
      context.showErrorSnackBar('Please select a restaurant image');
      return;
    }

    if (_selectedLocation == null) {
      context.showErrorSnackBar('Please select a location');
      return;
    }

    if (_selectedCategories.isEmpty) {
      context.showErrorSnackBar('Please select at least one category');
      return;
    }

    context.read<AdminCubit>().createRestaurant(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          address: _addressController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          categories: _selectedCategories,
          location: _selectedLocation!,
          imageFile: _selectedImage!,
          deliveryFee: double.parse(_deliveryFeeController.text),
          minOrderAmount: double.parse(_minOrderAmountController.text),
          estimatedDeliveryTime: int.parse(_estimatedDeliveryController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Restaurant'),
        backgroundColor: Colors.purple,
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is RestaurantCreatedSuccess) {
            context.showSuccessSnackBar('Restaurant created successfully!');
            context.go('/admin/restaurants');
          } else if (state is AdminError) {
            context.showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          if (state is AdminLoading) {
            return const LoadingWidget();
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Image Upload Section
                _buildImageUploadSection(),
                const SizedBox(height: 24),

                // Basic Information
                _buildSectionTitle('Basic Information'),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _nameController,
                  label: 'Restaurant Name',
                  icon: Icons.restaurant,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter restaurant name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  icon: Icons.description,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Contact Information
                _buildSectionTitle('Contact Information'),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter phone number';
                    }
                    if (!value.isValidPhone) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter email';
                    }
                    if (!value.isValidEmail) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Location
                _buildSectionTitle('Location'),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _addressController,
                  label: 'Address',
                  icon: Icons.location_on,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildLocationPicker(),
                const SizedBox(height: 24),

                // Categories
                _buildSectionTitle('Categories'),
                const SizedBox(height: 12),
                _buildCategorySelector(),
                const SizedBox(height: 24),

                // Delivery Settings
                _buildSectionTitle('Delivery Settings'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _deliveryFeeController,
                        label: 'Delivery Fee (\$)',
                        icon: Icons.delivery_dining,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _minOrderAmountController,
                        label: 'Min Order (\$)',
                        icon: Icons.shopping_cart,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid number';
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
                  label: 'Estimated Delivery Time (minutes)',
                  icon: Icons.timer,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter estimated delivery time';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Invalid number';
                    }
                    return null;
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
                  child: const Text(
                    'Create Restaurant',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageUploadSection() {
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
                    label: const Text('Change'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                  ),
                ),
              ],
            )
          : InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(12),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, size: 60, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'Tap to upload restaurant image',
                      style: TextStyle(
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
        color: Colors.purple,
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
        prefixIcon: Icon(icon, color: Colors.purple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.purple, width: 2),
        ),
      ),
    );
  }

  Widget _buildLocationPicker() {
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
            const Icon(Icons.map, color: Colors.purple),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedLocation != null
                    ? 'Location: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}'
                    : 'Tap to select location on map',
                style: TextStyle(
                  fontSize: 14,
                  color: _selectedLocation != null ? Colors.black : Colors.grey,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
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
                  const Icon(Icons.category, color: Colors.purple),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Tap to select categories',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Selected Categories:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: _showCategoryPicker,
                        child: const Text('Edit'),
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
                            backgroundColor: Colors.purple.withValues(alpha: 0.1),
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
}

