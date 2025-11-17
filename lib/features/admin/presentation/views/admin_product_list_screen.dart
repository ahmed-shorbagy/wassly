import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../restaurants/domain/entities/product_entity.dart';
import '../cubits/admin_product_cubit.dart';

class AdminProductListScreen extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;

  const AdminProductListScreen({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  State<AdminProductListScreen> createState() => _AdminProductListScreenState();
}

class _AdminProductListScreenState extends State<AdminProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductEntity> _filteredProducts = [];
  List<ProductEntity> _allProducts = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    context.read<AdminProductCubit>().loadRestaurantProducts(widget.restaurantId);
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = List.from(_allProducts);
      } else {
        _filteredProducts = _allProducts.where((product) {
          final nameMatch = product.name.toLowerCase().contains(query);
          final descMatch = product.description.toLowerCase().contains(query);
          final categoryMatch = product.category?.toLowerCase().contains(query) ?? false;
          return nameMatch || descMatch || categoryMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.restaurantProducts} - ${widget.restaurantName}'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
            tooltip: l10n.edit,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: StatefulBuilder(
              builder: (context, setState) => TextField(
                controller: _searchController,
                onChanged: (_) {
                  setState(() {});
                  _filterProducts();
                },
                decoration: InputDecoration(
                  hintText: l10n.searchProducts,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                            _filterProducts();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          // Products List
          Expanded(
            child: BlocConsumer<AdminProductCubit, AdminProductState>(
              listener: (context, state) {
                if (state is AdminProductAdded) {
                  context.showSuccessSnackBar(l10n.productAddedSuccessfully);
                  _loadProducts();
                } else if (state is AdminProductUpdated) {
                  context.showSuccessSnackBar(l10n.productUpdatedSuccessfully);
                  _loadProducts();
                } else if (state is AdminProductDeleted) {
                  context.showSuccessSnackBar(l10n.productDeletedSuccessfully);
                  _loadProducts();
                } else if (state is AdminProductError) {
                  context.showErrorSnackBar(state.message);
                } else if (state is AdminProductLoaded) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _allProducts = state.products;
                        _filteredProducts = _allProducts;
                      });
                      _filterProducts(); // Apply current search filter
                    }
                  });
                }
              },
              builder: (context, state) {
                if (state is AdminProductLoading) {
                  return LoadingWidget(message: l10n.creatingProduct);
                }

                if (state is AdminProductError) {
                  return ErrorDisplayWidget(
                    message: state.message,
                    onRetry: _loadProducts,
                  );
                }

                if (state is AdminProductLoaded) {
                  // Use filtered list for display
                  final displayList = _filteredProducts.isEmpty && _searchController.text.isEmpty
                      ? state.products
                      : _filteredProducts;
                  
                  if (displayList.isEmpty && _searchController.text.isNotEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: AppColors.textSecondary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noProductsFound,
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  if (displayList.isEmpty) {
                    return _buildEmptyState(l10n);
                  }
                  return _buildProductList(displayList, l10n);
                }

                return _buildEmptyState(l10n);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          '/admin/restaurants/${widget.restaurantId}/products/add',
        ),
        icon: const Icon(Icons.add),
        label: Text(l10n.addProduct),
        backgroundColor: Colors.purple,
      ),
    );
  }

  Widget _buildProductList(List<ProductEntity> products, AppLocalizations l10n) {
    return RefreshIndicator(
      onRefresh: () async => _loadProducts(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _buildProductCard(products[index], l10n);
        },
      ),
    );
  }

  Widget _buildProductCard(ProductEntity product, AppLocalizations l10n) {
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
                      // Name
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Description
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Category
                      if (product.category != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.category!,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),

                      // Price
                      Text(
                        '${product.price.toStringAsFixed(2)} ${l10n.required}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
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
                        onChanged: (value) => _toggleAvailability(
                          product.id,
                          value,
                        ),
                        activeThumbColor: Colors.green,
                      ),
                      Text(
                        product.isAvailable
                            ? l10n.productAvailable
                            : l10n.productUnavailable,
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
                  onPressed: () => _navigateToEdit(product),
                  tooltip: l10n.edit,
                ),

                // Delete Button
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(product, l10n),
                  tooltip: l10n.edit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fastfood,
              size: 100,
              color: AppColors.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noProductsYet,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.startByAddingYourFirstProduct,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push(
                '/admin/restaurants/${widget.restaurantId}/products/add',
              ),
              icon: const Icon(Icons.add),
              label: Text(l10n.addProduct),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
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
    context.read<AdminProductCubit>().toggleProductAvailability(
      productId,
      isAvailable,
      widget.restaurantId,
    );
  }

  void _navigateToEdit(ProductEntity product) {
    context.push(
      '/admin/restaurants/${widget.restaurantId}/products/edit/${product.id}',
      extra: product,
    );
  }

  void _showDeleteDialog(ProductEntity product, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.editProduct),
        content: Text(l10n.areYouSureDeleteProduct),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.done),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AdminProductCubit>().deleteProduct(
                product.id,
                widget.restaurantId,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.editProduct),
          ),
        ],
      ),
    );
  }
}

