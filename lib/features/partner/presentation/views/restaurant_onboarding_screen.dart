import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../restaurants/domain/entities/restaurant_category_entity.dart';
import '../../../admin/presentation/cubits/admin_restaurant_category_cubit.dart';
import '../cubits/restaurant_onboarding_cubit.dart';

class RestaurantOnboardingScreen extends StatefulWidget {
  const RestaurantOnboardingScreen({super.key});

  @override
  State<RestaurantOnboardingScreen> createState() =>
      _RestaurantOnboardingScreenState();
}

class _RestaurantOnboardingScreenState
    extends State<RestaurantOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  XFile? _selectedImage;
  int _currentStep = 0;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final List<String> _selectedCategoryIds = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<AdminRestaurantCategoryCubit>().loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant Setup'), elevation: 0),
      body: BlocConsumer<RestaurantOnboardingCubit, RestaurantOnboardingState>(
        listener: (context, state) {
          if (state is RestaurantOnboardingSuccess) {
            context.showSuccessSnackBar('Restaurant created successfully!');
            context.go('/restaurant');
          } else if (state is RestaurantOnboardingError) {
            context.showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          if (state is RestaurantOnboardingLoading) {
            return const LoadingWidget(message: 'Creating your restaurant...');
          }

          return Form(
            key: _formKey,
            child: Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepContinue: _onStepContinue,
              onStepCancel: _onStepCancel,
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Row(
                    children: [
                      if (_currentStep < 4)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: details.onStepContinue,
                            child: const Text('Continue'),
                          ),
                        ),
                      if (_currentStep == 4)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Complete Setup',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      if (_currentStep > 0) ...[
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: details.onStepCancel,
                          child: const Text('Back'),
                        ),
                      ],
                    ],
                  ),
                );
              },
              steps: [
                Step(
                  title: const Text('Basic Information'),
                  content: _buildBasicInfoStep(),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0
                      ? StepState.complete
                      : StepState.indexed,
                ),
                Step(
                  title: const Text('Categories'),
                  content: _buildCategoriesStep(),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1
                      ? StepState.complete
                      : StepState.indexed,
                ),
                Step(
                  title: const Text('Restaurant Image'),
                  content: _buildImageStep(),
                  isActive: _currentStep >= 2,
                  state: _currentStep > 2
                      ? StepState.complete
                      : StepState.indexed,
                ),
                Step(
                  title: const Text('Contact & Location'),
                  content: _buildContactStep(),
                  isActive: _currentStep >= 3,
                  state: _currentStep > 3
                      ? StepState.complete
                      : StepState.indexed,
                ),
                Step(
                  title: const Text('Account Password'),
                  content: _buildPasswordStep(),
                  isActive: _currentStep >= 4,
                  state: StepState.indexed,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tell us about your restaurant',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Restaurant Name *',
            hintText: 'e.g., Mario\'s Pizza',
            prefixIcon: Icon(Icons.restaurant),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Restaurant name is required';
            }
            if (value.trim().length < 3) {
              return 'Name must be at least 3 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description *',
            hintText: 'Describe your cuisine and specialties',
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Description is required';
            }
            if (value.trim().length < 10) {
              return 'Description must be at least 10 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategoriesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What type of cuisine do you serve?',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        const SizedBox(height: 24),
        if (_selectedCategoryIds.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.category, color: Colors.grey),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'No categories selected',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
                OutlinedButton(
                  onPressed: _showCategoryPicker,
                  child: const Text('Select'),
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                BlocBuilder<
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
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedCategoryIds.map((categoryId) {
                            final category = categories.firstWhere(
                              (c) => c.id == categoryId,
                              orElse: () => RestaurantCategoryEntity(
                                id: categoryId,
                                name: 'Unknown',
                                imageUrl: '',
                                isActive: true,
                                displayOrder: 0,
                                createdAt: DateTime.now(),
                              ),
                            );
                            return Chip(
                              label: Text(category.name),
                              backgroundColor: Colors.green.withValues(
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
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Select at least one category to help customers find your restaurant',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCategoryPicker() {
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
                  title: const Text('Error'),
                  content: Text(state.message),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                );
              }

              if (state is AdminRestaurantCategoriesLoaded) {
                final categories = state.categories;
                return StatefulBuilder(
                  builder: (context, setStateDialog) {
                    return AlertDialog(
                      title: const Text('Select Categories'),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: categories.isEmpty
                            ? const Center(
                                child: Text('No categories available'),
                              )
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
                                      // Update main screen
                                      setState(() {});
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
                    );
                  },
                );
              }
              return const SizedBox();
            },
          ),
    );
  }

  Widget _buildImageStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add a beautiful image of your restaurant',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedImage != null
                      ? Colors.green
                      : AppColors.border,
                  width: 2,
                ),
              ),
              child: _selectedImage != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            File(_selectedImage!.path),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 64,
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tap to add restaurant image',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Recommended: 1200x600px',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        if (_selectedImage != null) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Image selected',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildContactStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How can customers reach you?',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email Address *',
            hintText: 'restaurant@example.com',
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email is required';
            }
            if (!value.isValidEmail) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number *',
            hintText: '+1 (555) 123-4567',
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Phone number is required';
            }
            if (value.trim().length < 10) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Full Address *',
            hintText: '123 Main St, City, State, ZIP',
            prefixIcon: Icon(Icons.location_on),
          ),
          maxLines: 2,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Address is required';
            }
            if (value.trim().length < 10) {
              return 'Please enter a complete address';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You can update these details anytime from your profile settings.',
                  style: TextStyle(fontSize: 14, color: Colors.green.shade700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create a password for your restaurant account',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password *',
            hintText: 'Enter a secure password',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Password is required';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Confirm Password *',
            hintText: 'Confirm your password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'This password will be used to log into your restaurant account. Make sure to keep it secure.',
                  style: TextStyle(fontSize: 14, color: Colors.blue.shade700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
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

      if (image != null && mounted) {
        setState(() {
          _selectedImage = image;
        });
        context.showSuccessSnackBar('Image selected successfully');
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Failed to pick image: $e');
      }
    }
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentStep = 1;
        });
      }
    } else if (_currentStep == 1) {
      if (_selectedCategoryIds.isEmpty) {
        context.showErrorSnackBar('Please select at least one category');
        return;
      }
      setState(() {
        _currentStep = 2;
      });
    } else if (_currentStep == 2) {
      if (_selectedImage == null) {
        context.showErrorSnackBar('Please select a restaurant image');
        return;
      }
      setState(() {
        _currentStep = 3;
      });
    } else if (_currentStep == 3) {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentStep = 4;
        });
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImage == null) {
      context.showErrorSnackBar('Please select a restaurant image');
      setState(() {
        _currentStep = 2;
      });
      return;
    }

    if (_selectedCategoryIds.isEmpty) {
      context.showErrorSnackBar('Please select at least one category');
      setState(() {
        _currentStep = 1;
      });
      return;
    }

    // Validate password match
    if (_passwordController.text != _confirmPasswordController.text) {
      context.showErrorSnackBar('Passwords do not match');
      setState(() {
        _currentStep = 4;
      });
      return;
    }

    if (_passwordController.text.length < 6) {
      context.showErrorSnackBar('Password must be at least 6 characters');
      setState(() {
        _currentStep = 4;
      });
      return;
    }

    // Get current user
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      context.showErrorSnackBar('Please log in to continue');
      return;
    }

    // Create restaurant
    context.read<RestaurantOnboardingCubit>().createRestaurant(
      ownerId: authState.user.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      categoryIds: _selectedCategoryIds,
      imagePath: _selectedImage!.path,
    );
  }
}
