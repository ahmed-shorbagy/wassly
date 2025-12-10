import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../articles/presentation/cubits/article_cubit.dart';
import '../../../articles/presentation/cubits/article_state.dart';
import '../../../articles/domain/entities/article_entity.dart';

class AdminEditArticleScreen extends StatefulWidget {
  final String articleId;

  const AdminEditArticleScreen({super.key, required this.articleId});

  @override
  State<AdminEditArticleScreen> createState() => _AdminEditArticleScreenState();
}

class _AdminEditArticleScreenState extends State<AdminEditArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _authorController = TextEditingController();

  File? _selectedImage;
  String? _currentImageUrl;
  bool _isPublished = false;
  bool _isLoading = false;
  bool _isInitialLoading = true;
  ArticleEntity? _article;

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _loadArticle() async {
    context.read<ArticleCubit>().loadAllArticles();
    // Wait a bit for articles to load, then find the one we need
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      final state = context.read<ArticleCubit>().state;
      if (state is ArticleLoaded) {
        final article = state.articles.firstWhere(
          (a) => a.id == widget.articleId,
          orElse: () => throw Exception('Article not found'),
        );
        setState(() {
          _article = article;
          _titleController.text = article.title;
          _contentController.text = article.content;
          _authorController.text = article.author ?? '';
          _isPublished = article.isPublished;
          _currentImageUrl = article.imageUrl;
          _isInitialLoading = false;
        });
      } else {
        setState(() => _isInitialLoading = false);
        context.showErrorSnackBar('Failed to load article');
      }
    }
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
          _currentImageUrl = null; // Clear old image when new one is selected
        });
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Failed to pick image: $e');
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return _currentImageUrl;

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
        return _currentImageUrl;
      }, (imageUrl) => imageUrl);
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Failed to upload image: $e');
      }
      return _currentImageUrl;
    }
  }

  Future<void> _updateArticle() async {
    if (!_formKey.currentState!.validate() || _article == null) return;

    setState(() => _isLoading = true);

    final imageUrl = await _uploadImage();

    final updatedArticle = _article!.copyWith(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      imageUrl: imageUrl,
      author: _authorController.text.trim().isEmpty
          ? null
          : _authorController.text.trim(),
      isPublished: _isPublished,
      updatedAt: DateTime.now(),
    );

    context.read<ArticleCubit>().updateArticle(updatedArticle);
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Article'),
          backgroundColor: Colors.purple,
        ),
        body: const LoadingWidget(),
      );
    }

    if (_article == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Article'),
          backgroundColor: Colors.purple,
        ),
        body: const Center(child: Text('Article not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Article'),
        backgroundColor: Colors.purple,
        actions: [
          BlocListener<ArticleCubit, ArticleState>(
            listener: (context, state) {
              if (state is ArticleLoaded && _isLoading) {
                setState(() => _isLoading = false);
                context.showSuccessSnackBar('Article updated successfully');
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
                    // Image Display/Upload
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
                            : _currentImageUrl != null &&
                                  _currentImageUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: _currentImageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
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

                    // Update Button
                    ElevatedButton(
                      onPressed: _updateArticle,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Update Article'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

extension on ArticleEntity {
  ArticleEntity copyWith({
    String? title,
    String? content,
    String? imageUrl,
    String? author,
    bool? isPublished,
    DateTime? updatedAt,
  }) {
    return ArticleEntity(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      author: author ?? this.author,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
