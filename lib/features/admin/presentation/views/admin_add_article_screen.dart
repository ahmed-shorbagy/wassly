import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../articles/presentation/cubits/article_cubit.dart';
import '../../../articles/presentation/cubits/article_state.dart';
import '../../../articles/domain/entities/article_entity.dart';

class AdminAddArticleScreen extends StatefulWidget {
  const AdminAddArticleScreen({super.key});

  @override
  State<AdminAddArticleScreen> createState() => _AdminAddArticleScreenState();
}

class _AdminAddArticleScreenState extends State<AdminAddArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _authorController = TextEditingController();

  File? _selectedImage;
  bool _isPublished = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _authorController.dispose();
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

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    try {
      final result = await InjectionContainer().imageUploadHelper.uploadFile(
        file: _selectedImage!,
        bucketName: 'articles',
      );
      return result.fold((failure) {
        if (mounted) {
          context.showErrorSnackBar(
            'Failed to upload image: ${failure.message}',
          );
        }
        return null;
      }, (imageUrl) => imageUrl);
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Failed to upload image: $e');
      }
      return null;
    }
  }

  Future<void> _saveArticle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final imageUrl = await _uploadImage();

    final article = ArticleEntity(
      id: '', // Will be set by repository
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      imageUrl: imageUrl,
      author: _authorController.text.trim().isEmpty
          ? null
          : _authorController.text.trim(),
      isPublished: _isPublished,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<ArticleCubit>().createArticle(article);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Article'),
        backgroundColor: Colors.purple,
        actions: [
          BlocListener<ArticleCubit, ArticleState>(
            listener: (context, state) {
              if (state is ArticleLoaded && _isLoading) {
                setState(() => _isLoading = false);
                context.showSuccessSnackBar('Article created successfully');
                context.pop();
              } else if (state is ArticleError && _isLoading) {
                setState(() => _isLoading = false);
                context.showErrorSnackBar(state.message);
              }
            },
            child: const SizedBox.shrink(),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Picker
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderDark),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 48,
                                    color: AppColors.textSecondary,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Tap to add image',
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
                      decoration: const InputDecoration(
                        labelText: 'Title *',
                        hintText: 'Enter article title',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Author
                    TextFormField(
                      controller: _authorController,
                      decoration: const InputDecoration(
                        labelText: 'Author',
                        hintText: 'Enter author name (optional)',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Content
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Content *',
                        hintText: 'Enter article content',
                      ),
                      maxLines: 10,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Content is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Published Toggle
                    SwitchListTile(
                      title: const Text('Publish Article'),
                      subtitle: Text(
                        _isPublished
                            ? 'Article will be visible on the website'
                            : 'Article will be saved as draft',
                      ),
                      value: _isPublished,
                      onChanged: (value) {
                        setState(() => _isPublished = value);
                      },
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    ElevatedButton(
                      onPressed: _saveArticle,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Save Article'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
