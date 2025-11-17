import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../ads/domain/entities/startup_ad_entity.dart';
import '../cubits/ad_management_cubit.dart';

class AdminStartupAdsScreen extends StatefulWidget {
  const AdminStartupAdsScreen({super.key});

  @override
  State<AdminStartupAdsScreen> createState() => _AdminStartupAdsScreenState();
}

class _AdminStartupAdsScreenState extends State<AdminStartupAdsScreen> {
  @override
  void initState() {
    super.initState();
    _loadAds();
  }

  void _loadAds() {
    context.read<AdManagementCubit>().loadAllStartupAds();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.startupAds),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAds,
            tooltip: l10n.edit,
          ),
        ],
      ),
      body: BlocConsumer<AdManagementCubit, AdManagementState>(
        listener: (context, state) {
          if (state is StartupAdAdded) {
            context.showSuccessSnackBar(l10n.adAddedSuccessfully);
            _loadAds();
          } else if (state is StartupAdUpdated) {
            context.showSuccessSnackBar(l10n.adUpdatedSuccessfully);
            _loadAds();
          } else if (state is StartupAdDeleted) {
            context.showSuccessSnackBar(l10n.adDeletedSuccessfully);
            _loadAds();
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
              onRetry: _loadAds,
            );
          }

          if (state is StartupAdsLoaded) {
            if (state.ads.isEmpty) {
              return _buildEmptyState(l10n);
            }
            return _buildAdsList(state.ads, l10n);
          }

          return _buildEmptyState(l10n);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/admin/ads/startup/add'),
        icon: const Icon(Icons.add),
        label: Text(l10n.addAd),
        backgroundColor: Colors.purple,
      ),
    );
  }

  Widget _buildAdsList(List<StartupAdEntity> ads, AppLocalizations l10n) {
    return RefreshIndicator(
      onRefresh: () async => _loadAds(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ads.length,
        itemBuilder: (context, index) {
          return _buildAdCard(ads[index], l10n);
        },
      ),
    );
  }

  Widget _buildAdCard(StartupAdEntity ad, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Ad Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: CachedNetworkImage(
              imageUrl: ad.imageUrl,
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
          // Ad Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ad.title != null) ...[
                  Text(
                    ad.title!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                if (ad.description != null) ...[
                  Text(
                    ad.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Text(
                      '${l10n.priority}: ${ad.priority}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ad.isActive
                            ? AppColors.success.withValues(alpha: 0.2)
                            : AppColors.error.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        ad.isActive ? l10n.active : l10n.inactive,
                        style: TextStyle(
                          fontSize: 12,
                          color: ad.isActive ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
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
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Switch(
                        value: ad.isActive,
                        onChanged: (value) =>
                            _toggleStatus(ad.id, value),
                        activeThumbColor: Colors.green,
                      ),
                      Text(
                        ad.isActive ? l10n.active : l10n.inactive,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ad.isActive
                              ? Colors.green
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _navigateToEdit(ad),
                  tooltip: l10n.edit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(ad, l10n),
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
              Icons.slideshow_outlined,
              size: 100,
              color: AppColors.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noStartupAds,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.startByAddingYourFirstStartupAd,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/admin/ads/startup/add'),
              icon: const Icon(Icons.add),
              label: Text(l10n.addAd),
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

  void _toggleStatus(String adId, bool isActive) {
    context.read<AdManagementCubit>().toggleStartupAdStatus(adId, isActive);
  }

  void _showDeleteDialog(StartupAdEntity ad, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteAd),
        content: Text('${l10n.areYouSureDeleteAd} "${ad.title ?? l10n.ad}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AdManagementCubit>().deleteStartupAd(ad.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.deleteAd),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(StartupAdEntity ad) {
    context.go('/admin/ads/startup/edit/${ad.id}', extra: ad);
  }
}

