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
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _deepLinkController;
  late final TextEditingController _priorityController;

  File? _selectedImage;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.ad != null) {
      _titleController = TextEditingController(text: widget.ad!.title ?? '');
      _descriptionController = TextEditingController(text: widget.ad!.description ?? '');
      _deepLinkController = TextEditingController(text: widget.ad!.deepLink ?? '');
      _priorityController = TextEditingController(text: widget.ad!.priority.toString());
      _isActive = widget.ad!.isActive;
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _deepLinkController = TextEditingController();
      _priorityController = TextEditingController(text: '0');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _deepLinkController.dispose();
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

    final priority = int.tryParse(_priorityController.text.trim()) ?? 0;
    final imageUrl = widget.ad?.imageUrl ?? '';

    context.read<AdManagementCubit>().updateStartupAd(
          adId: widget.adId,
          imageUrl: imageUrl,
          title: _titleController.text.trim().isEmpty
              ? null
              : _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          deepLink: _deepLinkController.text.trim().isEmpty
              ? null
              : _deepLinkController.text.trim(),
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
      body: BlocConsumer<AdManagementCubit, AdManagementState>(
        listener: (context, state) {
          if (state is StartupAdUpdated) {
            context.showSuccessSnackBar(l10n.adUpdatedSuccessfully);
            context.pop();
          } else if (state is AdManagementError) {
            context.showErrorSnackBar(state.message);
          }
        },
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

                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: l10n.adTitle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.adDescription,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Deep Link
                  TextFormField(
                    controller: _deepLinkController,
                    decoration: InputDecoration(
                      labelText: l10n.deepLink,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.link),
                      hintText: 'https://example.com',
                    ),
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
    );
  }
}

