import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/extensions.dart';
import '../cubits/delivery_address_cubit.dart';
import '../widgets/add_edit_address_dialog.dart';

class AddressBookScreen extends StatelessWidget {
  const AddressBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('سجل العناوين'), // Address Book
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<DeliveryAddressCubit, DeliveryAddressState>(
        listener: (context, state) {
          if (state is DeliveryAddressError) {
            context.showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          if (state is DeliveryAddressLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DeliveryAddressesLoaded) {
            if (state.addresses.isEmpty) {
              return _buildEmptyState(context, l10n);
            }

            final addresses = state.addresses;
            final selectedAddress = state.selectedAddress;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DeliveryAddressCubit>().loadAllAddresses();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  final isSelected = selectedAddress != null && 
                      selectedAddress.id == address.id;
                  
                  return _AddressCard(
                    address: address,
                    isSelected: isSelected,
                    onTap: () {
                      context.read<DeliveryAddressCubit>().selectAddress(address.id);
                    },
                    onEdit: () {
                      _showEditAddressDialog(context, address);
                    },
                    onDelete: () {
                      _showDeleteConfirmDialog(context, address, l10n);
                    },
                  );
                },
              ),
            );
          }

          if (state is DeliveryAddressSelected) {
            // Fallback to showing selected address only
            return Center(
              child: const Text('لا توجد عناوين'), // No addresses found
            );
          }

          return _buildEmptyState(context, l10n);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddAddressDialog(context);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'إضافة عنوان', // Add Address
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد عناوين', // No addresses found
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أضف عنوانك الأول للبدء', // Add your first address
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _showAddAddressDialog(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('إضافة عنوان'), // Add Address
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAddressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddEditAddressDialog(),
    );
  }

  void _showEditAddressDialog(
    BuildContext context,
    address,
  ) {
    showDialog(
      context: context,
      builder: (context) => AddEditAddressDialog(address: address),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    address,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف العنوان'), // Delete Address
        content: const Text('هل أنت متأكد من حذف هذا العنوان؟'), // Delete confirmation
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<DeliveryAddressCubit>().deleteAddress(address.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('حذف'), // Delete
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final dynamic address;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (address.addressLabel != null &&
                            address.addressLabel!.isNotEmpty)
                          Text(
                            address.addressLabel!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        if (address.addressLabel != null &&
                            address.addressLabel!.isNotEmpty)
                          const SizedBox(height: 4),
                        Text(
                          address.fullAddress,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n.defaultAddress,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text(l10n.edit),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('حذف'), // Delete
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

