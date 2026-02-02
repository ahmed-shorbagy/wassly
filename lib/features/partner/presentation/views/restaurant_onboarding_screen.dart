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
      appBar: AppBar(
        title: Text(context.l10n.restaurantDashboardTitle),
        elevation: 0,
      ),
      body: BlocConsumer<RestaurantOnboardingCubit, RestaurantOnboardingState>(
        listener: (context, state) {
          if (state is RestaurantOnboardingSuccess) {
            context.showSuccessSnackBar(
              context.l10n.restaurantCreatedSuccessfully,
            );
            context.go('/restaurant');
          } else if (state is RestaurantOnboardingError) {
            context.showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          if (state is RestaurantOnboardingLoading) {
            return LoadingWidget(message: context.l10n.creatingRestaurant);
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
                            child: Text(context.l10n.continueText),
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
                            child: Text(
                              context.l10n.completeSetup,
                              style: const TextStyle(
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
                          child: Text(context.l10n.back),
                        ),
                      ],
                    ],
                  ),
                );
              },
              steps: [
                Step(
                  title: Text(context.l10n.basicInformation),
                  content: _buildBasicInfoStep(),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0
                      ? StepState.complete
                      : StepState.indexed,
                ),
                Step(
                  title: Text(context.l10n.categories),
                  content: _buildCategoriesStep(),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1
                      ? StepState.complete
                      : StepState.indexed,
                ),
                Step(
                  title: Text(context.l10n.restaurantImage),
                  content: _buildImageStep(),
                  isActive: _currentStep >= 2,
                  state: _currentStep > 2
                      ? StepState.complete
                      : StepState.indexed,
                ),
                Step(
                  title: Text(context.l10n.contactAndLocation),
                  content: _buildContactStep(),
                  isActive: _currentStep >= 3,
                  state: _currentStep > 3
                      ? StepState.complete
                      : StepState.indexed,
                ),
                Step(
                  title: Text(context.l10n.accountPassword),
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
        Text(
          context.l10n.tellUsAboutRestaurant,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: context.l10n.restaurantNameAsterisk,
            hintText: context.l10n.restaurantNameHint,
            prefixIcon: const Icon(Icons.restaurant),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return context.l10n.pleaseEnterRestaurantName;
            }
            if (value.trim().length < 3) {
              return context.l10n.nameAtLeast3Chars;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: context.l10n.descriptionAsterisk,
            hintText: context.l10n.descriptionHint,
            prefixIcon: const Icon(Icons.description),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return context.l10n.descriptionRequired;
            }
            if (value.trim().length < 10) {
              return context.l10n.descriptionAtLeast10Chars;
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
        Text(
          context.l10n.whatCuisineDoYouServe,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
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
                Expanded(
                  child: Text(
                    context.l10n.noCategoriesSelected,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
                OutlinedButton(
                  onPressed: _showCategoryPicker,
                  child: Text(context.l10n.select),
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
                            Text(
                              context.l10n.selectedCategories,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextButton(
                              onPressed: _showCategoryPicker,
                              child: Text(context.l10n.edit),
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
                                name: context.l10n.unknownCategory,
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
                  context.l10n.selectAtLeastOneCategoryHint,
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
                  title: Text(context.l10n.error),
                  content: Text(state.message),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(context.l10n.ok),
                    ),
                  ],
                );
              }

              if (state is AdminRestaurantCategoriesLoaded) {
                final categories = state.categories;
                return StatefulBuilder(
                  builder: (context, setStateDialog) {
                    return AlertDialog(
                      title: Text(context.l10n.selectCategories),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: categories.isEmpty
                            ? Center(
                                child: Text(context.l10n.noCategoriesAvailable),
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
                          child: Text(context.l10n.done),
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
        Text(
          context.l10n.addBeautifulRestaurantImage,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
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
                          context.l10n.tapToUploadRestaurantImage,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.recommendedImageSize,
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
                context.l10n.imageSelected,
                style: const TextStyle(
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
        Text(
          context.l10n.howReachYou,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: context.l10n.emailAddressAsterisk,
            hintText: context.l10n.restaurantEmailHint,
            prefixIcon: const Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return context.l10n.pleaseEnterEmail;
            }
            if (!value.isValidEmail) {
              return context.l10n.pleaseEnterValidEmail;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: context.l10n.phoneNumberAsterisk,
            hintText: context.l10n.phoneHint,
            prefixIcon: const Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return context.l10n.phoneNumberRequired;
            }
            if (value.trim().length < 10) {
              return context.l10n.invalidPhoneNumber;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          decoration: InputDecoration(
            labelText: context.l10n.fullAddressAsterisk,
            hintText: context.l10n.addressHint,
            prefixIcon: const Icon(Icons.location_on),
          ),
          maxLines: 2,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return context.l10n.addressRequired;
            }
            if (value.trim().length < 10) {
              return context.l10n.completeAddressRequired;
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
                  context.l10n.updateDetailsFromProfileHint,
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
        Text(
          context.l10n.createPasswordForRestaurant,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: context.l10n.passwordAsterisk,
            hintText: context.l10n.passwordHint,
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
              return context.l10n.pleaseEnterPassword;
            }
            if (value.length < 6) {
              return context.l10n.passwordMustBeAtLeast6Characters;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: context.l10n.confirmPasswordAsterisk,
            hintText: context.l10n.confirmPasswordHint,
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
              return context.l10n.pleaseConfirmPassword;
            }
            if (value != _passwordController.text) {
              return context.l10n.passwordsDoNotMatch;
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
                  context.l10n.passwordSecureHint,
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
        context.showSuccessSnackBar(context.l10n.imageSelectedSuccessfully);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(context.l10n.failedToPickImage(e.toString()));
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
        context.showErrorSnackBar(context.l10n.selectAtLeastOneCategoryHint);
        return;
      }
      setState(() {
        _currentStep = 2;
      });
    } else if (_currentStep == 2) {
      if (_selectedImage == null) {
        context.showErrorSnackBar(context.l10n.pleaseSelectImage);
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
      context.showErrorSnackBar(context.l10n.pleaseSelectImage);
      setState(() {
        _currentStep = 2;
      });
      return;
    }

    if (_selectedCategoryIds.isEmpty) {
      context.showErrorSnackBar(context.l10n.selectAtLeastOneCategoryHint);
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
