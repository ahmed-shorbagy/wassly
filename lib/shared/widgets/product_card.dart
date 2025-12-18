import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_size_text/auto_size_text.dart';
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
          borderRadius: BorderRadius.circular((MediaQuery.of(context).size.width * 0.04).clamp(12.0, 18.0)),
          side: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product Image Section with Heart and Add Button
            AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular((MediaQuery.of(context).size.width * 0.04).clamp(12.0, 18.0)),
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
                              width: (MediaQuery.of(context).size.width * 0.08).clamp(28.0, 36.0),
                              height: (MediaQuery.of(context).size.width * 0.08).clamp(28.0, 36.0),
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
                                size: (MediaQuery.of(context).size.width * 0.045).clamp(16.0, 20.0),
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
                        width: (MediaQuery.of(context).size.width * 0.09).clamp(32.0, 40.0),
                        height: (MediaQuery.of(context).size.width * 0.09).clamp(32.0, 40.0),
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
                          size: (MediaQuery.of(context).size.width * 0.05).clamp(18.0, 22.0),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Product Info Section - Constrained to prevent overflow
            Flexible(
              child: Padding(
                padding: EdgeInsets.all((MediaQuery.of(context).size.width * 0.025).clamp(6.0, 12.0)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Price - Takes only what it needs
                    AutoSizeText(
                      '${price.toStringAsFixed(2)} ${AppLocalizations.of(context)?.currencySymbol ?? 'ج.م'}',
                      style: TextStyle(
                        fontSize: (MediaQuery.of(context).size.width * 0.038).clamp(13.0, 17.0),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      minFontSize: 10,
                      maxFontSize: (MediaQuery.of(context).size.width * 0.038).clamp(13.0, 17.0).roundToDouble(),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: (MediaQuery.of(context).size.height * 0.006).clamp(4.0, 8.0)),
                    // Product Name/Description - Optimized for Arabic text with flexible height
                    AutoSizeText(
                      description.isNotEmpty ? description : productName,
                      style: TextStyle(
                        fontSize: (MediaQuery.of(context).size.width * 0.028).clamp(9.0, 13.0),
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      minFontSize: 8,
                      maxFontSize: (MediaQuery.of(context).size.width * 0.028).clamp(9.0, 13.0).roundToDouble(),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      wrapWords: false,
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
        l10n?.marketProductsOrderingComingSoon ?? 'طلب منتجات الماركت قريباً',
      );
      return;
    }
    
    // Trigger onTap which will handle adding to cart
    if (onTap != null) {
      onTap!();
    }
  }
}

