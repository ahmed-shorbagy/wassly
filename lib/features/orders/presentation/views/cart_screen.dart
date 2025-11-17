import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../restaurants/presentation/cubits/restaurant_cubit.dart';
import '../cubits/cart_cubit.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cart),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state is CartLoaded && state.items.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.clearCart,
                  onPressed: () => _showClearCartDialog(context, l10n),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<CartCubit, CartState>(
        listener: (context, state) {
          if (state is CartError) {
            context.showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          if (state is CartLoading) {
            return const LoadingWidget();
          }

          if (state is CartError) {
            return ErrorDisplayWidget(
              message: state.message,
              onRetry: () {
                // Cart will reload automatically via stream
              },
            );
          }

          if (state is CartInitial ||
              (state is CartLoaded && state.items.isEmpty)) {
            return _buildEmptyCart(context, l10n);
          }

          if (state is CartLoaded) {
            return _buildCartContent(context, state, l10n);
          }

          return const LoadingWidget();
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 80,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.cartEmpty,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.startAddingProductsFromRestaurants,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.restaurant_menu),
              label: Text(l10n.browseRestaurants),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(
    BuildContext context,
    CartLoaded state,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        // Cart Items List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return _CartItemCard(item: item, l10n: l10n);
            },
          ),
        ),

        // Total and Checkout Section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Subtotal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.subtotal,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    '${state.totalPrice.toStringAsFixed(2)} ر.س',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Delivery Fee (if applicable)
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(l10n.deliveryFee),
              //     Text('10.00 ر.س'),
              //   ],
              // ),
              const Divider(height: 24),
              // Grand Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.grandTotal,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '${state.totalPrice.toStringAsFixed(2)} ر.س',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _proceedToCheckout(context, state),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    l10n.proceedToCheckout,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _proceedToCheckout(
    BuildContext context,
    CartLoaded state,
  ) async {
    if (state.items.isEmpty) return;

    final restaurantId = state.restaurantId ?? state.items.first.product.restaurantId;

    // Fetch restaurant data
    await context.read<RestaurantCubit>().getRestaurantById(restaurantId);

    // Get the restaurant from cubit state
    final restaurantState = context.read<RestaurantCubit>().state;
    if (restaurantState is RestaurantLoaded) {
      // Navigate to checkout with restaurant data
      context.push('/checkout', extra: restaurantState.restaurant);
    } else {
      context.showErrorSnackBar('فشل تحميل بيانات المطعم');
    }
  }

  Future<void> _showClearCartDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearCart),
        content: Text(l10n.areYouSureClearCart),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.back),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.clearCart),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<CartCubit>().clearCart();
    }
  }
}

class _CartItemCard extends StatelessWidget {
  final dynamic item; // CartItemEntity
  final AppLocalizations l10n;

  const _CartItemCard({
    required this.item,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.product.imageUrl != null &&
                      item.product.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.product.imageUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 80,
                        height: 80,
                        color: AppColors.surface,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 80,
                        height: 80,
                        color: AppColors.surface,
                        child: const Icon(Icons.fastfood),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: AppColors.surface,
                      child: const Icon(Icons.fastfood),
                    ),
            ),
            const SizedBox(width: 12),

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.product.price.toStringAsFixed(2)} ر.س',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.quantity}: ${item.quantity}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity Controls
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        context.read<CartCubit>().updateQuantity(
                              item.product.id,
                              item.quantity - 1,
                            );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        context.read<CartCubit>().updateQuantity(
                              item.product.id,
                              item.quantity + 1,
                            );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    context.read<CartCubit>().removeItem(item.product.id);
                  },
                  child: Text(
                    l10n.remove,
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
