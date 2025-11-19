import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../restaurants/presentation/cubits/food_category_cubit.dart';
import '../../../restaurants/domain/entities/food_category_entity.dart';

class AdminCategoryListScreen extends StatelessWidget {
  final String restaurantId;

  const AdminCategoryListScreen({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) =>
          context.read<FoodCategoryCubit>()
            ..loadRestaurantCategories(restaurantId),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.foodCategories),
          backgroundColor: Colors.purple,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                context.push('/admin/restaurants/$restaurantId/categories/add');
              },
            ),
          ],
        ),
        body: BlocBuilder<FoodCategoryCubit, FoodCategoryState>(
          builder: (context, state) {
            if (state is FoodCategoryLoading) {
              return const LoadingWidget();
            }

            if (state is FoodCategoryError) {
              return ErrorDisplayWidget(
                message: state.message,
                onRetry: () {
                  context.read<FoodCategoryCubit>().loadRestaurantCategories(
                    restaurantId,
                  );
                },
              );
            }

            if (state is FoodCategoryLoaded) {
              if (state.categories.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 64,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noCategoriesFound,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.push(
                            '/admin/restaurants/$restaurantId/categories/add',
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: Text(l10n.addCategory),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  return _buildCategoryCard(context, category, restaurantId);
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    FoodCategoryEntity category,
    String restaurantId,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.category, color: Colors.purple),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: category.description != null
            ? Text(
                category.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: category.isActive,
              onChanged: (value) {
                context.read<FoodCategoryCubit>().toggleCategoryStatus(
                  category.id,
                  value,
                  restaurantId,
                );
              },
            ),
            const SizedBox(width: 8),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Icons.edit, size: 20),
                      const SizedBox(width: 8),
                      Text(l10n.edit),
                    ],
                  ),
                  onTap: () {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      context.push(
                        '/admin/restaurants/$restaurantId/categories/${category.id}/edit',
                      );
                    });
                  },
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Icons.delete, size: 20, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        l10n.deleteCategory,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                  onTap: () {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      _showDeleteConfirmation(context, category, restaurantId);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    FoodCategoryEntity category,
    String restaurantId,
  ) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(l10n.areYouSureDeleteCategory(category.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<FoodCategoryCubit>().deleteCategory(
                category.id,
                restaurantId,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.deleteCategory),
          ),
        ],
      ),
    );
  }
}
