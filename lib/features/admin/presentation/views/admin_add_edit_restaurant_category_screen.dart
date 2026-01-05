import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../restaurants/domain/entities/restaurant_category_entity.dart';
import '../cubits/admin_restaurant_category_cubit.dart';

class AdminAddEditRestaurantCategoryScreen extends StatefulWidget {
  final RestaurantCategoryEntity? category;

  const AdminAddEditRestaurantCategoryScreen({super.key, this.category});

  @override
  State<AdminAddEditRestaurantCategoryScreen> createState() =>
      _AdminAddEditRestaurantCategoryScreenState();
}

class _AdminAddEditRestaurantCategoryScreenState
    extends State<AdminAddEditRestaurantCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _displayOrderController = TextEditingController(text: '0');
  File? _selectedImage;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.category!.name;
      _displayOrderController.text = widget.category!.displayOrder.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _displayOrderController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final displayOrder = int.tryParse(_displayOrderController.text) ?? 0;

    if (_isEditing) {
      context.read<AdminRestaurantCategoryCubit>().updateCategory(
        id: widget.category!.id,
        name: name,
        imageFile: _selectedImage,
        displayOrder: displayOrder,
      );
    } else {
      if (_selectedImage == null) {
        context.showErrorSnackBar('Please select an image'); // TODO: Localize
        return;
      }
      context.read<AdminRestaurantCategoryCubit>().createCategory(
        name: name,
        imageFile: _selectedImage,
        displayOrder: displayOrder,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Category' : 'Add Category'),
        backgroundColor: Colors.purple,
      ),
      body:
          BlocConsumer<
            AdminRestaurantCategoryCubit,
            AdminRestaurantCategoryState
          >(
            listener: (context, state) {
              if (state is AdminRestaurantCategoryOperationSuccess) {
                context.showSuccessSnackBar(state.message);
                Navigator.pop(context);
              } else if (state is AdminRestaurantCategoryError) {
                context.showErrorSnackBar(state.message);
              }
            },
            builder: (context, state) {
              if (state is AdminRestaurantCategoryLoading) {
                return LoadingWidget(message: l10n.loading);
              }

              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : _isEditing && widget.category!.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  widget.category!.imageUrl!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Tap to add image',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter category name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _displayOrderController,
                      decoration: const InputDecoration(
                        labelText: 'Display Order',
                        border: OutlineInputBorder(),
                        helperText: 'Lower numbers appear first',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter order';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _isEditing ? 'Update Category' : 'Create Category',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}
