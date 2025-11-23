import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
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
    if (ad.deepLink != null && ad.deepLink!.isNotEmpty) {
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
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Section with Background Color (if title exists)
                if (ad.title != null || ad.description != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ad.title != null)
                          Text(
                            ad.title!,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        if (ad.description != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            ad.description!,
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                
                // Ad Image
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _handleAdTap(context),
                    borderRadius: BorderRadius.only(
                      bottomLeft: const Radius.circular(28),
                      bottomRight: const Radius.circular(28),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: const Radius.circular(28),
                        bottomRight: const Radius.circular(28),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: ad.imageUrl,
                        width: double.infinity,
                        height: 450,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: double.infinity,
                          height: 450,
                          color: AppColors.surface,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: double.infinity,
                          height: 450,
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
              ],
            ),
            
            // Close Button - White X in top right (placed last to be on top)
            Positioned(
              top: 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _handleClose(context),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.black87,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

