import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../home/domain/entities/banner_entity.dart';
import '../cubits/ad_management_cubit.dart';

class AdminBannerAdsScreen extends StatefulWidget {
  const AdminBannerAdsScreen({super.key});

  @override
  State<AdminBannerAdsScreen> createState() => _AdminBannerAdsScreenState();
}

class _AdminBannerAdsScreenState extends State<AdminBannerAdsScreen> {
  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  void _loadBanners() {
    context.read<AdManagementCubit>().loadAllBannerAds();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bannerAds),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBanners,
            tooltip: l10n.edit,
          ),
        ],
      ),
      body: BlocConsumer<AdManagementCubit, AdManagementState>(
        listener: (context, state) {
          if (state is BannerAdAdded) {
            context.showSuccessSnackBar(l10n.adAddedSuccessfully);
            _loadBanners();
          } else if (state is BannerAdUpdated) {
            context.showSuccessSnackBar(l10n.adUpdatedSuccessfully);
            _loadBanners();
          } else if (state is BannerAdDeleted) {
            context.showSuccessSnackBar(l10n.adDeletedSuccessfully);
            _loadBanners();
          } else if (state is AdManagementError) {
            context.showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          if (state is AdManagementLoading) {
            return LoadingWidget(message: l10n.loading);
          }

          if (state is AdManagementError) {
            return ErrorDisplayWidget(
              message: state.message,
              onRetry: _loadBanners,
            );
          }

          if (state is BannerAdsLoaded) {
            if (state.banners.isEmpty) {
              return _buildEmptyState(l10n);
            }
            return _buildBannersList(state.banners, l10n);
          }

          return _buildEmptyState(l10n);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/ads/banners/add'),
        icon: const Icon(Icons.add),
        label: Text(l10n.addBanner),
        backgroundColor: Colors.purple,
      ),
    );
  }

  Widget _buildBannersList(List<BannerEntity> banners, AppLocalizations l10n) {
    return RefreshIndicator(
      onRefresh: () async => _loadBanners(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: banners.length,
        itemBuilder: (context, index) {
          return _buildBannerCard(banners[index], l10n);
        },
      ),
    );
  }

  Widget _buildBannerCard(BannerEntity banner, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Banner Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: CachedNetworkImage(
              imageUrl: banner.imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,
                color: AppColors.surface,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: AppColors.surface,
                child: const Icon(Icons.image_not_supported, size: 50),
              ),
            ),
          ),
          // Banner Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (banner.title != null) ...[
                  Text(
                    banner.title!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (banner.deepLink != null) ...[
                  Row(
                    children: [
                      Icon(Icons.link, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          banner.deepLink!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _navigateToEdit(banner),
                  tooltip: l10n.edit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(banner, l10n),
                  tooltip: l10n.remove,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 100,
              color: AppColors.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noBannerAds,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.startByAddingYourFirstBannerAd,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push('/admin/ads/banners/add'),
              icon: const Icon(Icons.add),
              label: Text(l10n.addBanner),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BannerEntity banner, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteBanner),
        content: Text('${l10n.areYouSureDeleteBanner} "${banner.title ?? l10n.banner}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AdManagementCubit>().deleteBannerAd(banner.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.deleteBanner),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(BannerEntity banner) {
    context.push('/admin/ads/banners/edit/${banner.id}', extra: banner);
  }
}

