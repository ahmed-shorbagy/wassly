import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
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
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24.r,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              flex: 12,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.r),
                      topRight: Radius.circular(24.r),
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
                  // Redesigned modern discount badge
                  if (restaurant.isDiscountActive)
                    Positioned(
                      top: 12.h,
                      left: 12.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accentFood,
                              const Color(0xFFFF5C00), // Deeper Orange
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentFood.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_offer,
                              color: Colors.white,
                              size: 12.r,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'خصم', // Localized would be better, but keeping as is for now or use l10n
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              flex: 9,
              child: Padding(
                padding: EdgeInsets.all(14.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      restaurant.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Rating and Reviews Grouped
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 16,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                restaurant.rating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFB8860B), // Dark Gold
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '(${restaurant.totalReviews} reviews)',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    // Delivery Info Row
                    Row(
                      children: [
                        _buildFeatureIcon(
                          Icons.timer_outlined,
                          '${restaurant.estimatedDeliveryTime}',
                        ),
                        SizedBox(width: 12.w),
                        _buildFeatureIcon(
                          Icons.pedal_bike_rounded,
                          restaurant.deliveryFee.toStringAsFixed(0),
                          isCurrency: true,
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

  Widget _buildFeatureIcon(
    IconData icon,
    String value, {
    bool isCurrency = false,
  }) {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.sp, color: AppColors.primaryDark),
            SizedBox(width: 4.w),
            Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (!isCurrency) ...[
              SizedBox(width: 2.w),
              Text(
                l10n.minutesAbbreviation,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              SizedBox(width: 2.w),
              Text(
                l10n.currencySymbol,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
