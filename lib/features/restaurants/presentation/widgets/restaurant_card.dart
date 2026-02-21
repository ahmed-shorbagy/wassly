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
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          bool isMarketStore = false;
          try {
            final homeState = context.read<HomeCubit>().state;
            if (homeState is HomeLoaded) {
              isMarketStore = homeState.categories.any((category) {
                return restaurant.categoryIds.contains(category.id) &&
                    category.isMarket;
              });
            }
          } catch (e) {
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
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image on the Right for RTL (First child in Row for RTL)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      width: 90.w,
                      height: 90.w,
                      color: AppColors.surface,
                      child: CachedNetworkImage(
                        imageUrl:
                            (restaurant.imageUrl != null &&
                                restaurant.imageUrl!.isNotEmpty)
                            ? restaurant.imageUrl!
                            : '',
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/images/resturants.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  if (restaurant.isDiscountActive)
                    Positioned(
                      top: 4.r,
                      left: 4.r,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentFood,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'خصم',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 12.w),

              // 2. Info on the Left for RTL
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (restaurant.rating >= 4.0)
                          Container(
                            margin: EdgeInsets.only(left: 6.w),
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6200EE),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            restaurant.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '(${restaurant.totalReviews})',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          restaurant.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFB8860B),
                          ),
                        ),
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 16,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 12.h,
                    ), // Replaced spacer with fixed height for better control
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.start, // RIGHT in RTL
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
            ],
          ),
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
