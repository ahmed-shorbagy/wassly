import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// Enhanced market product card matching user request:
/// - Minimized whitespace
/// - Image takes up most of the card
/// - + Button overlaid on image (bottom-right)
/// - Price and Name below image
/// - No extra padding
class MarketProductCard extends StatefulWidget {
  final String productId;
  final String productName;
  final String description;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final VoidCallback? onTap;
  final Future<bool> Function()? onAddToCart;
  final String? promotionalLabel;
  final String? volume;
  final bool showAddButton;

  const MarketProductCard({
    super.key,
    required this.productId,
    required this.productName,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.isAvailable,
    this.onTap,
    this.onAddToCart,
    this.promotionalLabel,
    this.volume,
    this.showAddButton = true,
  });

  @override
  State<MarketProductCard> createState() => _MarketProductCardState();
}

class _MarketProductCardState extends State<MarketProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleAddToCart() async {
    if (_isLoading || !widget.isAvailable) return;

    setState(() {
      _isLoading = true;
      _isSuccess = false;
    });

    await _animationController.forward();
    await _animationController.reverse();

    try {
      bool success = false;
      if (widget.onAddToCart != null) {
        success = await widget.onAddToCart!();
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
        success = true; // Simulate success if no callback
      }

      if (mounted) {
        if (success) {
          setState(() {
            _isLoading = false;
            _isSuccess = true;
          });

          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) {
            setState(() {
              _isSuccess = false;
            });
          }
        } else {
          // Failed (toast already shown by Cubit usually, or just return false)
          setState(() {
            _isLoading = false;
            _isSuccess = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSuccess = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          // Removed shadow as per "cleaner" look request usually implies flatter
          // but kept subtle one for depth if needed. Let's make it very subtle.
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Image Section (Takes most space)
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16.r),
                      // Apply bottom radius only if content is very minimal,
                      // but we have text below, so keep vertical top.
                    ),
                    child: Container(
                      color: const Color(0xFFF8F8F8),
                      child:
                          widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: widget.imageUrl!,
                              fit: BoxFit
                                  .cover, // Changed to cover to minimize whitespace
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.shopping_bag_outlined,
                                size: 40.w,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.shopping_bag_outlined,
                              size: 40.w,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.5,
                              ),
                            ),
                    ),
                  ),

                  // Promotional Label (top-right based on image provided)
                  if (widget.promotionalLabel != null)
                    Positioned(
                      top: 8.h,
                      right: 8.w, // Moved to right based on image
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.promotionalLabel!,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold, // Bolder
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),

                  // Add to Cart Button (Overlaid on bottom-right of image section)
                  if (widget.showAddButton)
                    Positioned(
                      bottom: 8.h,
                      right: 8.w, // Bottom right of image
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: GestureDetector(
                          onTap: _handleAddToCart,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: _isSuccess ? 36.w : 32.w, // Slightly smaller
                            height: _isSuccess ? 36.w : 32.w,
                            decoration: BoxDecoration(
                              gradient: widget.isAvailable && !_isSuccess
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFFFF6B6B),
                                        Color(0xFFFF8E53),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: _isSuccess
                                  ? const Color(0xFF4CAF50)
                                  : (widget.isAvailable
                                        ? null
                                        : Colors.grey[400]),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _isSuccess
                                      ? const Color(
                                          0xFF4CAF50,
                                        ).withValues(alpha: 0.4)
                                      : (widget.isAvailable
                                            ? const Color(
                                                0xFFFF6B6B,
                                              ).withValues(alpha: 0.4)
                                            : Colors.grey.withValues(
                                                alpha: 0.3,
                                              )),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(child: _buildButtonContent()),
                          ),
                        ),
                      ),
                    ),

                  // Unavailable overlay
                  if (!widget.isAvailable)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16.r),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[600],
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'غير متوفر',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Use minimal space for text
            Padding(
              padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 10.h),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Shrink wrap
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align text to start (right)
                children: [
                  // Product Name
                  Text(
                    widget.productName,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  ),

                  SizedBox(height: 4.h), // Minimal gap
                  // Price
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.start, // Align price to start (right)
                    children: [
                      Text(
                        widget.price.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary, // Black price
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        l10n?.currencySymbol ?? 'ج.م',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (_isLoading) {
      return SizedBox(
        width: 16.w,
        height: 16.w,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (_isSuccess) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Icon(Icons.check, color: Colors.white, size: 18.w),
          );
        },
      );
    }

    return Icon(Icons.add, color: Colors.white, size: 20.w);
  }
}
