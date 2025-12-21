import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../features/ads/domain/entities/startup_ad_entity.dart';

/// Popup dialog widget for displaying startup ads
/// Matches the design structure with rounded corners and close button
class StartupAdPopup extends StatelessWidget {
  final StartupAdEntity ad;

  const StartupAdPopup({
    super.key,
    required this.ad,
  });

  static Future<void> show(
    BuildContext context,
    StartupAdEntity ad,
  ) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => StartupAdPopup(ad: ad),
    );
  }

  void _handleAdTap(BuildContext context) {
    Navigator.of(context).pop();
    // Navigate to restaurant page if restaurantId is available
    if (ad.restaurantId != null && ad.restaurantId!.isNotEmpty) {
      try {
        context.push('/restaurant/${ad.restaurantId}');
      } catch (e) {
        // Handle error silently
      }
    } else if (ad.deepLink != null && ad.deepLink!.isNotEmpty) {
      try {
        context.push(ad.deepLink!);
      } catch (e) {
        // Handle error silently
      }
    }
  }

  void _handleClose(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Responsive dimensions for startup ads
    final double dialogWidth = 328.w;
    final double dialogHeight = 600.h;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: ResponsiveHelper.padding(
        horizontal: 16,
        vertical: 40,
      ),
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20.r,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Content - Simple design: Image + Restaurant Name
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ad Image - Clickable, Clean Image Only (No Text Overlay)
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _handleAdTap(context),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28.r),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(28.r),
                          ),
                          child: SizedBox(
                            width: dialogWidth,
                            height: dialogHeight - 80.h, // Reserve space for restaurant name
                            child: CachedNetworkImage(
                              imageUrl: ad.imageUrl,
                              width: dialogWidth,
                              fit: BoxFit.cover,
                              // No overlays, gradients, or text - just the pure image
                              placeholder: (context, url) => Container(
                                color: AppColors.surface,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.surface,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Restaurant Name - Below Image
                  if (ad.restaurantName != null && ad.restaurantName!.isNotEmpty)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _handleAdTap(context),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(28.r),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: ResponsiveHelper.padding(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(28.r),
                            ),
                          ),
                          child: Text(
                            ad.restaurantName!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.fontSize(18),
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    )
                  else
                    // Fallback: show title if restaurant name not available
                    if (ad.title != null && ad.title!.isNotEmpty)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _handleAdTap(context),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(28.r),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: ResponsiveHelper.padding(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(28.r),
                              ),
                            ),
                            child: Text(
                              ad.title!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: ResponsiveHelper.fontSize(18),
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                ],
              ),
              
              // Close Button - White X in top right (placed last to be on top)
              Positioned(
                top: 16.h,
                right: 16.w,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _handleClose(context),
                    borderRadius: BorderRadius.circular(14.r),
                    child: Container(
                      width: 28.w,
                      height: 28.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.black87,
                        size: ResponsiveHelper.iconSize(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

