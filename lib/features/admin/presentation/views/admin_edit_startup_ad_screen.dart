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
import '../../../ads/domain/entities/startup_ad_entity.dart';
import '../../../restaurants/domain/entities/restaurant_entity.dart';
import '../../../restaurants/presentation/cubits/restaurant_cubit.dart';
import '../cubits/ad_management_cubit.dart';

class AdminEditStartupAdScreen extends StatefulWidget {
  final String adId;
  final StartupAdEntity? ad;

  const AdminEditStartupAdScreen({
    super.key,
    required this.adId,
    this.ad,
  });

  @override
  State<AdminEditStartupAdScreen> createState() => _AdminEditStartupAdScreenState();
}

class _AdminEditStartupAdScreenState extends State<AdminEditStartupAdScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _priorityController;

  File? _selectedImage;
  bool _isActive = true;
  String? _selectedRestaurantId;
  String? _selectedRestaurantName;
  List<RestaurantEntity> _restaurants = [];

  @override
  void initState() {
    super.initState();
    if (widget.ad != null) {
      _priorityController = TextEditingController(text: widget.ad!.priority.toString());
      _isActive = widget.ad!.isActive;
      _selectedRestaurantId = widget.ad!.restaurantId;
      _selectedRestaurantName = widget.ad!.restaurantName;
    } else {
      _priorityController = TextEditingController(text: '0');
    }
    // Load restaurants
    context.read<RestaurantCubit>().getAllRestaurants();
  }

  @override
  void dispose() {
    _priorityController.dispose();
    super.dispose();
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

    if (_selectedRestaurantId == null || _selectedRestaurantName == null) {
      context.showErrorSnackBar('Please select a restaurant');
      return;
    }

    final priority = int.tryParse(_priorityController.text.trim()) ?? 0;
    final imageUrl = widget.ad?.imageUrl ?? '';

    context.read<AdManagementCubit>().updateStartupAd(
          adId: widget.adId,
          imageUrl: imageUrl,
          restaurantId: _selectedRestaurantId,
          restaurantName: _selectedRestaurantName,
          imageFile: _selectedImage,
          isActive: _isActive,
          priority: priority,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeNavigationWrapper(
      fallbackRoute: '/admin/ads/startup',
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.editStartupAd),
          backgroundColor: Colors.purple,
        ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AdManagementCubit, AdManagementState>(
            listener: (context, state) {
              if (state is StartupAdUpdated) {
                context.showSuccessSnackBar(l10n.adUpdatedSuccessfully);
                context.pop();
              } else if (state is AdManagementError) {
                context.showErrorSnackBar(state.message);
              }
            },
          ),
          BlocListener<RestaurantCubit, RestaurantState>(
            listener: (context, state) {
              if (state is RestaurantsLoaded) {
                setState(() {
                  _restaurants = state.restaurants;
                });
              }
            },
          ),
        ],
        child: BlocBuilder<AdManagementCubit, AdManagementState>(
          builder: (context, state) {
            if (state is AdManagementLoading) {
              return LoadingWidget(message: l10n.updatingAd);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ad Image
                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        height: 250,
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
                            : widget.ad?.imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.ad!.imageUrl,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) {
                                        return Column(
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

                    // Restaurant Selector
                    DropdownButtonFormField<String>(
                      value: _selectedRestaurantId,
                      decoration: InputDecoration(
                        labelText: 'Select Restaurant',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.restaurant),
                      ),
                      items: _restaurants.map((restaurant) {
                        return DropdownMenuItem<String>(
                          value: restaurant.id,
                          child: Text(restaurant.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRestaurantId = value;
                          _selectedRestaurantName = _restaurants
                              .firstWhere((r) => r.id == value)
                              .name;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a restaurant';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Priority
                    TextFormField(
                      controller: _priorityController,
                      decoration: InputDecoration(
                        labelText: l10n.priority,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.sort),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Active Status
                    SwitchListTile(
                      title: Text(l10n.active),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
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
                      child: Text(l10n.updateAd),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      ),
    );
  }
}

