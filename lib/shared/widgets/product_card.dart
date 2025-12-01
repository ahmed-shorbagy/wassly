import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../core/utils/extensions.dart';
import '../../features/restaurants/presentation/cubits/favorites_cubit.dart';

/// Reusable product card widget matching the design
/// Features:
/// - Heart icon (favorite) in top-left
/// - Product image centered
/// - Circular add to cart button overlaid on bottom-left of image
/// - Price displayed below image
/// - Product description (Arabic text) below price
class ProductCard extends StatelessWidget {
  final String productId;
  final String productName;
  final String description;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final VoidCallback? onTap;
  final String? restaurantId;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final bool isMarketProduct;

  const ProductCard({
    super.key,
    required this.productId,
    required this.productName,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.isAvailable,
    this.onTap,
    this.restaurantId,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.isMarketProduct = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Section with Heart and Add Button
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: imageUrl != null && imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.border,
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.border,
                              child: const Icon(
                                Icons.fastfood,
                                size: 40,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.border,
                            child: const Icon(
                              Icons.fastfood,
                              size: 40,
                              color: AppColors.textSecondary,
                            ),
                          ),
                  ),
                  
                  // Heart Icon (Favorite) - Top Left
                  if (restaurantId != null)
                    BlocBuilder<FavoritesCubit, FavoritesState>(
                      builder: (context, favState) {
                        final isFav = favState.favoriteRestaurantIds.contains(restaurantId);
                        return Positioned(
                          top: 8,
                          left: 8,
                          child: GestureDetector(
                            onTap: () {
                              context.read<FavoritesCubit>().toggleRestaurant(restaurantId!);
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                size: 18,
                                color: isFav ? Colors.red : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  
                  // Circular Add to Cart Button - Bottom Left
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: GestureDetector(
                      onTap: isAvailable ? () => _handleAddToCart(context) : null,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isAvailable ? AppColors.primary : AppColors.textSecondary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.add,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Product Info Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price
                    Text(
                      '${price.toStringAsFixed(2)} ${AppLocalizations.of(context)?.currencySymbol ?? 'ج.م'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Product Description
                    Expanded(
                      child: Text(
                        description.isNotEmpty ? description : productName,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAddToCart(BuildContext context) {
    if (isMarketProduct) {
      final l10n = AppLocalizations.of(context);
      context.showInfoSnackBar(
        l10n?.marketProductsOrderingComingSoon ?? 'طلب منتجات السوق قريباً',
      );
      return;
    }
    
    // Trigger onTap which will handle adding to cart
    if (onTap != null) {
      onTap!();
    }
  }
}

