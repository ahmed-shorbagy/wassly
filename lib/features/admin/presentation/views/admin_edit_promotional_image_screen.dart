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
import '../../../home/domain/entities/promotional_image_entity.dart';
import '../cubits/ad_management_cubit.dart';

class AdminEditPromotionalImageScreen extends StatefulWidget {
  final String imageId;
  final PromotionalImageEntity? image;

  const AdminEditPromotionalImageScreen({
    super.key,
    required this.imageId,
    this.image,
  });

  @override
  State<AdminEditPromotionalImageScreen> createState() =>
      _AdminEditPromotionalImageScreenState();
}

class _AdminEditPromotionalImageScreenState
    extends State<AdminEditPromotionalImageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _deepLinkController = TextEditingController();
  final _priorityController = TextEditingController();

  File? _selectedImage;
  String _existingImageUrl = '';

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  void _populateFields() {
    if (widget.image != null) {
      _titleController.text = widget.image!.title ?? '';
      _subtitleController.text = widget.image!.subtitle ?? '';
      _deepLinkController.text = widget.image!.deepLink ?? '';
      _priorityController.text = widget.image!.priority.toString();
      _existingImageUrl = widget.image!.imageUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
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

    if (_existingImageUrl.isEmpty && _selectedImage == null) {
      context.showErrorSnackBar('Please select an image');
      return;
    }

    final priority = int.tryParse(_priorityController.text.trim()) ?? 0;

    context.read<AdManagementCubit>().updatePromotionalImage(
      imageId: widget.imageId,
      imageUrl: _existingImageUrl,
      title: _titleController.text.trim().isEmpty
          ? null
          : _titleController.text.trim(),
      subtitle: _subtitleController.text.trim().isEmpty
          ? null
          : _subtitleController.text.trim(),
      deepLink: _deepLinkController.text.trim().isEmpty
          ? null
          : _deepLinkController.text.trim(),
      imageFile: _selectedImage,
      priority: priority,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeNavigationWrapper(
      fallbackRoute: '/admin/ads/promotional',
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.editPromotionalImage),
          backgroundColor: Colors.purple,
        ),
        body: BlocConsumer<AdManagementCubit, AdManagementState>(
          listener: (context, state) {
            if (state is PromotionalImageUpdated) {
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
                    // Image Picker/Preview
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
                            : _existingImageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: _existingImageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                          ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          l10n.tapToChangeImage,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
                                    l10n.tapToUploadImage,
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
                        labelText: l10n.title,
                        hintText: l10n.optionalTitleHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Subtitle
                    TextFormField(
                      controller: _subtitleController,
                      decoration: InputDecoration(
                        labelText: l10n.subtitle,
                        hintText: l10n.optionalSubtitleHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.subtitles),
                      ),
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
                        hintText: 'https://example.com or /restaurants',
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
                        hintText: '0',
                      ),
                      keyboardType: TextInputType.number,
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
                      child: Text(l10n.saveChanges),
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
