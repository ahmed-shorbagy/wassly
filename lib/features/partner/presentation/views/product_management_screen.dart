import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../restaurants/domain/entities/product_entity.dart';
import '../../../restaurants/domain/entities/food_category_entity.dart';
import '../../../restaurants/presentation/cubits/restaurant_cubit.dart';
import '../../../restaurants/presentation/cubits/food_category_cubit.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../cubits/product_management_cubit.dart';
import '../../../../core/utils/logger.dart';

class ProductManagementScreen extends StatefulWidget {
  final bool isMarket;

  const ProductManagementScreen({super.key, this.isMarket = false});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  String? _restaurantId;
  List<FoodCategoryEntity> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadRestaurantAndProducts();
  }

  void _loadRestaurantAndProducts() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      // Fallback: Fetch all restaurants and find match client-side
      // because getRestaurantByOwnerId is failing for some users
      context.read<RestaurantCubit>().getAllRestaurants();
    }
  }

  void _loadProducts(String restaurantId) {
    context.read<RestaurantCubit>().getRestaurantProducts(restaurantId);
    context.read<FoodCategoryCubit>().loadRestaurantCategories(restaurantId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FoodCategoryCubit, FoodCategoryState>(
      listener: (context, state) {
        if (state is FoodCategoryLoaded) {
          setState(() {
            _categories = state.categories;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.myProducts),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                if (_restaurantId != null) {
                  _loadProducts(_restaurantId!);
                } else {
                  _loadRestaurantAndProducts();
                }
              },
              tooltip: context.l10n.refresh,
            ),
          ],
        ),
        body: BlocConsumer<ProductManagementCubit, ProductManagementState>(
          listener: (context, state) {
            if (state is ProductDeleted) {
              context.showSuccessSnackBar(
                context.l10n.productDeletedSuccessfully,
              );
              if (_restaurantId != null) {
                _loadProducts(_restaurantId!);
              }
            } else if (state is ProductAvailabilityToggled) {
              context.showSuccessSnackBar(context.l10n.availabilityUpdated);
              if (_restaurantId != null) {
                _loadProducts(_restaurantId!);
              }
            } else if (state is ProductManagementError) {
              context.showErrorSnackBar(state.message);
            }
          },
          builder: (context, managementState) {
            return BlocConsumer<RestaurantCubit, RestaurantState>(
              listener: (context, state) {
                if (state is RestaurantLoaded) {
                  setState(() {
                    _restaurantId = state.restaurant.id;
                  });
                  _loadProducts(state.restaurant.id);
                } else if (state is RestaurantsLoaded) {
                  final authState = context.read<AuthCubit>().state;
                  if (authState is AuthAuthenticated) {
                    AppLogger.logInfo(
                      'DEBUG: Checking for owner match. User: ${authState.user.id}',
                    );
                    for (var r in state.restaurants) {
                      AppLogger.logInfo(
                        'DEBUG: Restaurant: ${r.name}, Owner: ${r.ownerId}',
                      );
                    }

                    try {
                      final myRestaurant = state.restaurants.firstWhere(
                        (r) => r.ownerId == authState.user.id,
                      );
                      setState(() {
                        _restaurantId = myRestaurant.id;
                      });
                      _loadProducts(myRestaurant.id);
                    } catch (_) {
                      AppLogger.logWarning(
                        'DEBUG: No matching restaurant found for user in list of ${state.restaurants.length}',
                      );
                    }
                  }
                }
              },
              builder: (context, state) {
                if (state is RestaurantLoading) {
                  return const LoadingWidget();
                }

                if (state is RestaurantError) {
                  return ErrorDisplayWidget(
                    message: state.message,
                    onRetry: _loadRestaurantAndProducts,
                  );
                }

                if (state is RestaurantLoaded && _restaurantId == null) {
                  // Restaurant loaded but products not yet loaded
                  return const LoadingWidget();
                }

                // Show specific error if no restaurant found after loading
                if (state is RestaurantsLoaded && _restaurantId == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.store,
                            size: 80,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Market Found',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your account is not linked to any market.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'User ID: ${context.read<AuthCubit>().state is AuthAuthenticated ? (context.read<AuthCubit>().state as AuthAuthenticated).user.id : "Unknown"}',
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is ProductsLoaded) {
                  if (state.products.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildProductList(state.products);
                }

                return _buildEmptyState();
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _navigateToAddProduct(),
          icon: const Icon(Icons.add),
          label: Text(context.l10n.addProduct),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }

  Widget _buildProductList(List<ProductEntity> products) {
    return RefreshIndicator(
      onRefresh: () async {
        if (_restaurantId != null) {
          _loadProducts(_restaurantId!);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _buildProductCard(products[index]);
        },
      ),
    );
  }

  Widget _buildProductCard(ProductEntity product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: product.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 120,
                          height: 120,
                          color: AppColors.surface,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 120,
                          height: 120,
                          color: AppColors.surface,
                          child: const Icon(Icons.fastfood, size: 40),
                        ),
                      )
                    : Container(
                        width: 120,
                        height: 120,
                        color: AppColors.surface,
                        child: const Icon(Icons.fastfood, size: 40),
                      ),
              ),

              // Product Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Category
                      if (product.categoryId != null ||
                          product.category != null)
                        Builder(
                          builder: (context) {
                            String categoryName = product.category ?? '';
                            if (product.categoryId != null) {
                              try {
                                final category = _categories.firstWhere(
                                  (c) => c.id == product.categoryId,
                                );
                                categoryName = category.name;
                              } catch (e) {
                                // Category not found, use fallback
                                if (categoryName.isEmpty) {
                                  categoryName = context.l10n.unknownCategory;
                                }
                              }
                            }
                            if (categoryName.isNotEmpty) {
                              return Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      categoryName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),

                      // Description
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                // Availability Toggle
                Expanded(
                  child: Row(
                    children: [
                      Switch(
                        value: product.isAvailable,
                        onChanged: (value) =>
                            _toggleAvailability(product.id, value),
                        activeThumbColor: Colors.green,
                      ),
                      Text(
                        product.isAvailable
                            ? context.l10n.productAvailable
                            : context.l10n.productUnavailable,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: product.isAvailable
                              ? Colors.green
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),

                // Edit Button
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _navigateToEditProduct(product),
                  tooltip: context.l10n.edit,
                ),

                // Delete Button
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(product),
                  tooltip: context.l10n.delete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 100,
              color: AppColors.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.noProductsYet,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.startByAddingYourFirstProduct,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToAddProduct(),
              icon: const Icon(Icons.add),
              label: Text(context.l10n.addFirstProduct),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleAvailability(String productId, bool isAvailable) {
    context.read<ProductManagementCubit>().toggleAvailability(
      productId,
      isAvailable,
    );
  }

  void _showDeleteDialog(ProductEntity product) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.deleteProduct),
        content: Text(
          context.l10n.areYouSureDeleteProductWithName(product.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ProductManagementCubit>().deleteProduct(product.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
  }

  void _navigateToAddProduct() {
    if (_restaurantId == null) {
      _loadRestaurantAndProducts();
      context.showInfoSnackBar('Loading data, please try again...');
      return;
    }
    if (widget.isMarket) {
      context.push(
        '/market/products/add',
        extra: {'restaurantId': _restaurantId},
      );
    } else {
      context.push(
        '/restaurant/products/add',
        extra: {'restaurantId': _restaurantId},
      );
    }
  }

  void _navigateToEditProduct(ProductEntity product) {
    if (_restaurantId == null) {
      _loadRestaurantAndProducts();
      context.showInfoSnackBar('Loading data, please try again...');
      return;
    }
    if (widget.isMarket) {
      context.push('/market/products/edit/${product.id}');
    } else {
      context.push('/restaurant/products/edit/${product.id}');
    }
  }
}
