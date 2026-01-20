import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../home/domain/entities/promotional_image_entity.dart';
import '../cubits/ad_management_cubit.dart';

class AdminPromotionalImagesScreen extends StatefulWidget {
  const AdminPromotionalImagesScreen({super.key});

  @override
  State<AdminPromotionalImagesScreen> createState() =>
      _AdminPromotionalImagesScreenState();
}

class _AdminPromotionalImagesScreenState
    extends State<AdminPromotionalImagesScreen> {
  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  void _loadImages() {
    context.read<AdManagementCubit>().loadAllPromotionalImages();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.promotionalImages),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadImages,
            tooltip: l10n.edit,
          ),
        ],
      ),
      body: BlocConsumer<AdManagementCubit, AdManagementState>(
        listener: (context, state) {
          if (state is PromotionalImageAdded) {
            context.showSuccessSnackBar(l10n.adAddedSuccessfully);
            _loadImages();
          } else if (state is PromotionalImageUpdated) {
            context.showSuccessSnackBar(l10n.adUpdatedSuccessfully);
            _loadImages();
          } else if (state is PromotionalImageDeleted) {
            context.showSuccessSnackBar(l10n.adDeletedSuccessfully);
            _loadImages();
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
              onRetry: _loadImages,
            );
          }

          if (state is PromotionalImagesLoaded) {
            return _buildImagesList(state.images, l10n);
          }

          return _buildEmptyState(l10n);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/ads/promotional/add'),
        icon: const Icon(Icons.add),
        label: Text(l10n.addPromotionalImage),
        backgroundColor: Colors.purple,
      ),
    );
  }

  Widget _buildImagesList(
    List<PromotionalImageEntity> images,
    AppLocalizations l10n,
  ) {
    if (images.isEmpty) {
      return _buildEmptyState(l10n);
    }
    return RefreshIndicator(
      onRefresh: () async => _loadImages(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return _buildImageCard(images[index], l10n);
        },
      ),
    );
  }

  Widget _buildImageCard(PromotionalImageEntity image, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Image Preview
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: CachedNetworkImage(
              imageUrl: image.imageUrl,
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
          // Image Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (image.title != null && image.title!.isNotEmpty) ...[
                  Text(
                    image.title!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                if (image.subtitle != null && image.subtitle!.isNotEmpty) ...[
                  Text(
                    image.subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    // Status indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: image.isActive
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        image.isActive ? l10n.active : l10n.inactive,
                        style: TextStyle(
                          fontSize: 12,
                          color: image.isActive ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${l10n.priority}: ${image.priority}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (image.deepLink != null && image.deepLink!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.link,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          image.deepLink!,
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
                // Toggle status button
                IconButton(
                  icon: Icon(
                    image.isActive ? Icons.visibility_off : Icons.visibility,
                    color: image.isActive ? Colors.orange : Colors.green,
                  ),
                  onPressed: () {
                    context
                        .read<AdManagementCubit>()
                        .togglePromotionalImageStatus(
                          image.id,
                          !image.isActive,
                        );
                  },
                  tooltip: image.isActive ? l10n.deactivate : l10n.activate,
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _navigateToEdit(image),
                  tooltip: l10n.edit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(image, l10n),
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
              l10n.noPromotionalImages,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.startByAddingYourFirstPromotionalImage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push('/admin/ads/promotional/add'),
              icon: const Icon(Icons.add),
              label: Text(l10n.addPromotionalImage),
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

  void _showDeleteDialog(PromotionalImageEntity image, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deletePromotionalImage),
        content: Text(
          '${l10n.areYouSureDeletePromotionalImage} "${image.title ?? l10n.promotionalImage}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AdManagementCubit>().deletePromotionalImage(
                image.id,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.deletePromotionalImage),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(PromotionalImageEntity image) {
    context.push('/admin/ads/promotional/edit/${image.id}', extra: image);
  }
}
