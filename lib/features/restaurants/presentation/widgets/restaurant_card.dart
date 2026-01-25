import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../../../home/presentation/cubits/home_cubit.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantEntity restaurant;

  const RestaurantCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Check if this restaurant belongs to a "Market" category (e.g., Pharmacy, Supermarket)
          bool isMarketStore = false;

          try {
            // Access HomeCubit to get loaded categories
            // We use read here because we just want the current state, not to listen
            // However, depending on where this is used, we might need to be careful.
            // But usually HomeCubit is high up.

            // Note: We need to import HomeCubit and HomeState
            final homeState = context.read<HomeCubit>().state;
            if (homeState is HomeLoaded) {
              // Check if any of the restaurant's categories have isMarket == true
              isMarketStore = homeState.categories.any((category) {
                return restaurant.categoryIds.contains(category.id) &&
                    category.isMarket;
              });
            }
          } catch (e) {
            // Fallback or ignore if HomeCubit not found (unlikely in main flow)
            // Existing hardcoded check as fallback
            isMarketStore = restaurant.categoryIds.any(
              (cid) =>
                  cid.toLowerCase().contains('groceries') ||
                  cid.toLowerCase().contains('supermarket'),
            );
          }

          if (isMarketStore) {
            context.push(
              '/market-products?restaurantId=${restaurant.id}&restaurantName=${Uri.encodeComponent(restaurant.name)}',
            );
          } else {
            context.push('/restaurant/${restaurant.id}');
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top image section - Image First Optimization
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: AppColors.surface,
                      child: CachedNetworkImage(
                        imageUrl:
                            (restaurant.imageUrl != null &&
                                restaurant.imageUrl!.isNotEmpty)
                            ? restaurant.imageUrl!
                            : '',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (context, url) => Container(
                          color: AppColors.surface,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.surface,
                          child: Icon(
                            Icons.restaurant,
                            size: 40.w,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Optional discount badge on image
                  if (restaurant.isDiscountActive)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          'خصم',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveHelper.fontSize(10),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Bottom info section - More compact
            Expanded(
              flex: 2,
              child: Padding(
                padding: ResponsiveHelper.padding(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      restaurant.name,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.fontSize(14),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        SizedBox(width: 4.w),
                        Text(
                          restaurant.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: ResponsiveHelper.fontSize(12),
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '(${restaurant.totalReviews})',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.fontSize(10),
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12.w,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4.w),
                        Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            return Text(
                              '${restaurant.estimatedDeliveryTime} ${l10n.minutesAbbreviation}',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.fontSize(11),
                                color: AppColors.textSecondary,
                              ),
                            );
                          },
                        ),
                        const Spacer(),
                        Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            return Text(
                              '${restaurant.deliveryFee.toStringAsFixed(0)} ${l10n.currencySymbol}',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.fontSize(12),
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            );
                          },
                        ),
                      ],
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
}
