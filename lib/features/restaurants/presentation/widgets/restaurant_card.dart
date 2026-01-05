import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/restaurant_entity.dart';

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
          context.push('/restaurant/${restaurant.id}');
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
