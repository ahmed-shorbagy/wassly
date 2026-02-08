import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/logger.dart';

class PartnerTypeSelectionScreen extends StatefulWidget {
  const PartnerTypeSelectionScreen({super.key});

  @override
  State<PartnerTypeSelectionScreen> createState() =>
      _PartnerTypeSelectionScreenState();
}

class _PartnerTypeSelectionScreenState
    extends State<PartnerTypeSelectionScreen> {
  bool _isLoading = false;

  Future<void> _selectPartnerType(String type) async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('partner_type', type);
      AppLogger.logInfo('Partner type selected and saved: $type');

      if (mounted) {
        context.pushReplacement('/login');
      }
    } catch (e) {
      AppLogger.logError('Failed to save partner type: $e');
      if (mounted) {
        context.showErrorSnackBar(
          'Failed to save selection. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Image.asset(
                'assets/images/logo.jpeg',
                height: 100,
                width: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 32),
              Text(
                context.l10n.welcome,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.selectPartnerTypeTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Expanded(
                  child: Column(
                    children: [
                      _TypeCard(
                        title: context.l10n.restaurant,
                        subtitle: context.l10n.manageRestaurantSubtitle,
                        icon: Icons.restaurant_rounded,
                        color: AppColors.primary,
                        onTap: () =>
                            _selectPartnerType(AppConstants.userTypeRestaurant),
                      ),
                      const SizedBox(height: 16),
                      _TypeCard(
                        title: context.l10n.market,
                        subtitle: context.l10n.manageMarketSubtitle,
                        icon: Icons.store_mall_directory_rounded,
                        color: AppColors.secondary,
                        onTap: () =>
                            _selectPartnerType(AppConstants.userTypeMarket),
                      ),
                      const SizedBox(height: 16),
                      _TypeCard(
                        title: context.l10n.driver,
                        subtitle: context.l10n.driverSubtitle,
                        icon: Icons.delivery_dining_rounded,
                        color: AppColors.info,
                        onTap: () =>
                            _selectPartnerType(AppConstants.userTypeDriver),
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
}

class _TypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
