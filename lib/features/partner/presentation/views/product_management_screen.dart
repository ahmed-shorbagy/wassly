import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../restaurants/domain/entities/product_entity.dart';
import '../../../restaurants/presentation/cubits/restaurant_cubit.dart';
import '../cubits/product_management_cubit.dart';

class ProductManagementScreen extends StatefulWidget {
  final String restaurantId;

  const ProductManagementScreen({super.key, required this.restaurantId});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    context.read<RestaurantCubit>().getRestaurantProducts(widget.restaurantId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocConsumer<ProductManagementCubit, ProductManagementState>(
        listener: (context, state) {
          if (state is ProductDeleted) {
            context.showSuccessSnackBar('Product deleted successfully');
            _loadProducts();
          } else if (state is ProductAvailabilityToggled) {
            context.showSuccessSnackBar('Availability updated');
            _loadProducts();
          } else if (state is ProductManagementError) {
            context.showErrorSnackBar(state.message);
          }
        },
        builder: (context, managementState) {
          return BlocBuilder<RestaurantCubit, RestaurantState>(
            builder: (context, state) {
              if (state is RestaurantLoading) {
                return const LoadingWidget();
              }

              if (state is RestaurantError) {
                return ErrorDisplayWidget(
                  message: state.message,
                  onRetry: _loadProducts,
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
        label: const Text('Add Product'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildProductList(List<ProductEntity> products) {
    return RefreshIndicator(
      onRefresh: () async => _loadProducts(),
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
                      if (product.category != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.category!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

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
                        product.isAvailable ? 'Available' : 'Unavailable',
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
                  tooltip: 'Edit',
                ),

                // Delete Button
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(product),
                  tooltip: 'Delete',
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
              color: AppColors.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Products Yet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Start building your menu by adding your first product',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToAddProduct(),
              icon: const Icon(Icons.add),
              label: const Text('Add First Product'),
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
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ProductManagementCubit>().deleteProduct(product.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddProduct() {
    // TODO: Navigate to add product screen
    context.showInfoSnackBar('Add Product screen - Coming soon!');
  }

  void _navigateToEditProduct(ProductEntity product) {
    // TODO: Navigate to edit product screen
    context.showInfoSnackBar('Edit Product screen - Coming soon!');
  }
}
