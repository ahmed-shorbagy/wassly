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
        isMarket: false,
        displayOrder: displayOrder,
      );
    } else {
      if (_selectedImage == null) {
        final l10n = AppLocalizations.of(context)!;
        context.showErrorSnackBar(l10n.pleaseSelectImage);
        return;
      }
      context.read<AdminRestaurantCategoryCubit>().createCategory(
        name: name,
        imageFile: _selectedImage,
        isMarket: false,
        displayOrder: displayOrder,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editCategory : l10n.addCategory),
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                  children: [
                                    const Icon(
                                      Icons.add_a_photo,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.tapToAddImage,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: l10n.categoryName,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.pleaseEnterCategoryName;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _displayOrderController,
                        decoration: InputDecoration(
                          labelText: l10n.displayOrder,
                          border: const OutlineInputBorder(),
                          helperText: l10n.displayOrderHelper,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.pleaseEnterOrder;
                          }
                          if (int.tryParse(value) == null) {
                            return l10n.pleaseEnterValidNumber;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          _isEditing ? l10n.editCategory : l10n.addCategory,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}
