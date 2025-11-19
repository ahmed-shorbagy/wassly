import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../restaurants/presentation/cubits/food_category_cubit.dart';
import '../../../restaurants/domain/entities/food_category_entity.dart';

class AdminEditCategoryScreen extends StatefulWidget {
  final String restaurantId;
  final String categoryId;

  const AdminEditCategoryScreen({
    super.key,
    required this.restaurantId,
    required this.categoryId,
  });

  @override
  State<AdminEditCategoryScreen> createState() =>
      _AdminEditCategoryScreenState();
}

class _AdminEditCategoryScreenState extends State<AdminEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late int _displayOrder;
  FoodCategoryEntity? _category;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _displayOrder = 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadCategory() {
    context.read<FoodCategoryCubit>().loadRestaurantCategories(
      widget.restaurantId,
    );
  }

  void _submitForm() {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate() || _category == null) {
      return;
    }

    context.read<FoodCategoryCubit>().updateCategory(
      category: _category!,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      displayOrder: _displayOrder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => context.read<FoodCategoryCubit>()
        ..loadRestaurantCategories(widget.restaurantId),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.editCategory),
          backgroundColor: Colors.purple,
        ),
        body: BlocConsumer<FoodCategoryCubit, FoodCategoryState>(
          listener: (context, state) {
            if (state is FoodCategoryLoaded) {
              final category = state.categories.firstWhere(
                (c) => c.id == widget.categoryId,
                orElse: () => state.categories.first,
              );
              if (category.id == widget.categoryId) {
                setState(() {
                  _category = category;
                  _nameController.text = category.name;
                  _descriptionController.text = category.description ?? '';
                  _displayOrder = category.displayOrder;
                });
              }
            } else if (state is FoodCategoryUpdated) {
              context.pop();
              context.showSuccessSnackBar(l10n.categoryUpdatedSuccessfully);
            } else if (state is FoodCategoryError) {
              context.showErrorSnackBar(state.message);
            }
          },
          builder: (context, state) {
            if (state is FoodCategoryLoading && _category == null) {
              return const LoadingWidget();
            }

            if (_category == null) {
              return Center(
                child: Text(l10n.categoryNotFound),
              );
            }

            if (state is FoodCategoryLoading) {
              return LoadingWidget(message: l10n.updatingCategory);
            }

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionTitle(l10n.categoryName),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nameController,
                    label: l10n.categoryName,
                    icon: Icons.category,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.pleaseEnterCategoryName;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descriptionController,
                    label: l10n.description,
                    icon: Icons.description,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle(l10n.displayOrder),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _displayOrder.toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 100,
                          label: _displayOrder.toString(),
                          onChanged: (value) {
                            setState(() {
                              _displayOrder = value.toInt();
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 60,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _displayOrder.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      l10n.updateCategory,
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
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}

