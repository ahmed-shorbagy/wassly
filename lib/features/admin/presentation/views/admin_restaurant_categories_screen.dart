import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cached_network_image/cached_network_image.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../shared/widgets/loading_widget.dart';
import '../cubits/admin_restaurant_category_cubit.dart';
import 'admin_add_edit_restaurant_category_screen.dart';

class AdminRestaurantCategoriesScreen extends StatefulWidget {
  const AdminRestaurantCategoriesScreen({super.key});

  @override
  State<AdminRestaurantCategoriesScreen> createState() =>
      _AdminRestaurantCategoriesScreenState();
}

class _AdminRestaurantCategoriesScreenState
    extends State<AdminRestaurantCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminRestaurantCategoryCubit>().loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant Categories'), // TODO: Localize
        backgroundColor: Colors.purple,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const AdminAddEditRestaurantCategoryScreen(),
            ),
          ).then((_) {
            // Reload is handled by the screen pop usually or we can reload here
            context.read<AdminRestaurantCategoryCubit>().loadCategories();
          });
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
      ),
      body:
          BlocBuilder<
            AdminRestaurantCategoryCubit,
            AdminRestaurantCategoryState
          >(
            builder: (context, state) {
              if (state is AdminRestaurantCategoryLoading) {
                return LoadingWidget(message: l10n.loading);
              } else if (state is AdminRestaurantCategoryError) {
                return Center(child: Text(state.message));
              } else if (state is AdminRestaurantCategoriesLoaded) {
                if (state.categories.isEmpty) {
                  return Center(child: Text(l10n.noCategoriesFound));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final category = state.categories[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: category.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: category.imageUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                )
                              : const Icon(Icons.category, color: Colors.grey),
                        ),
                        title: Text(
                          category.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AdminAddEditRestaurantCategoryScreen(
                                          category: category,
                                        ),
                                  ),
                                ).then((_) {
                                  context
                                      .read<AdminRestaurantCategoryCubit>()
                                      .loadCategories();
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showDeleteConfirmation(context, category.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String categoryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('Are you sure you want to delete this category?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AdminRestaurantCategoryCubit>().deleteCategory(
                categoryId,
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
