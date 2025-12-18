import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/entities/delivery_address_entity.dart';
import '../../data/models/delivery_address_model.dart';
import '../cubits/delivery_address_cubit.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';

class AddEditAddressDialog extends StatefulWidget {
  final DeliveryAddressEntity? address;

  const AddEditAddressDialog({super.key, this.address});

  @override
  State<AddEditAddressDialog> createState() => _AddEditAddressDialogState();
}

class _AddEditAddressDialogState extends State<AddEditAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _addressLabelController = TextEditingController();
  final _buildingNumberController = TextEditingController();
  final _apartmentNumberController = TextEditingController();
  final _floorNumberController = TextEditingController();
  final _additionalNotesController = TextEditingController();
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _addressController.text = widget.address!.address;
      _addressLabelController.text = widget.address!.addressLabel ?? '';
      _buildingNumberController.text = widget.address!.buildingNumber ?? '';
      _apartmentNumberController.text = widget.address!.apartmentNumber ?? '';
      _floorNumberController.text = widget.address!.floorNumber ?? '';
      _additionalNotesController.text = widget.address!.additionalNotes ?? '';
      _isDefault = widget.address!.isDefault;
    } else {
      // New address - check if this will be first address
      final state = context.read<DeliveryAddressCubit>().state;
      if (state is DeliveryAddressesLoaded) {
        _isDefault = state.addresses.isEmpty;
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _addressLabelController.dispose();
    _buildingNumberController.dispose();
    _apartmentNumberController.dispose();
    _floorNumberController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      context.showErrorSnackBar('User not authenticated');
      return;
    }

    // For now, use default location (should ideally use geocoding)
    const defaultLocation = GeoPoint(30.0444, 31.2357); // Cairo, Egypt

    final now = DateTime.now();
    final address = DeliveryAddressModel(
      id: widget.address?.id ?? '',
      userId: authState.user.id,
      address: _addressController.text.trim(),
      addressLabel: _addressLabelController.text.trim().isEmpty
          ? null
          : _addressLabelController.text.trim(),
      location: defaultLocation,
      buildingNumber: _buildingNumberController.text.trim().isEmpty
          ? null
          : _buildingNumberController.text.trim(),
      apartmentNumber: _apartmentNumberController.text.trim().isEmpty
          ? null
          : _apartmentNumberController.text.trim(),
      floorNumber: _floorNumberController.text.trim().isEmpty
          ? null
          : _floorNumberController.text.trim(),
      additionalNotes: _additionalNotesController.text.trim().isEmpty
          ? null
          : _additionalNotesController.text.trim(),
      isDefault: _isDefault,
      createdAt: widget.address?.createdAt ?? now,
      updatedAt: now,
    );

    if (widget.address != null) {
      // Update existing address
      context.read<DeliveryAddressCubit>().updateAddress(address);
    } else {
      // Add new address
      context.read<DeliveryAddressCubit>().addAddress(address);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                widget.address != null
                    ? 'تعديل العنوان' // Edit Address
                    : 'إضافة عنوان جديد', // Add New Address
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 24),
              // Address Label (optional)
              TextFormField(
                controller: _addressLabelController,
                decoration: InputDecoration(
                  labelText: 'عنوان العنوان (اختياري)', // Address Label (optional)
                  hintText: 'مثال: منزل، مكتب، عمل',
                  prefixIcon: const Icon(Icons.label_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Address (required)
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'العنوان', // Address
                  hintText: 'أدخل عنوان التوصيل الكامل',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال العنوان'; // Please enter address
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Building, Floor, Apartment (optional)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _buildingNumberController,
                      decoration: InputDecoration(
                        labelText: 'المبنى',
                        hintText: 'رقم المبنى',
                        prefixIcon: const Icon(Icons.business),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _floorNumberController,
                      decoration: InputDecoration(
                        labelText: 'الطابق',
                        hintText: 'رقم الطابق',
                        prefixIcon: const Icon(Icons.stairs),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _apartmentNumberController,
                      decoration: InputDecoration(
                        labelText: 'الشقة',
                        hintText: 'رقم الشقة',
                        prefixIcon: const Icon(Icons.door_sliding),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Additional Notes
              TextFormField(
                controller: _additionalNotesController,
                decoration: InputDecoration(
                  labelText: 'ملاحظات إضافية (اختياري)',
                  hintText: 'أي معلومات إضافية قد تساعد',
                  prefixIcon: const Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              // Set as Default Switch
              SwitchListTile(
                title: const Text('تعيين كعنوان افتراضي'), // Set as Default
                value: _isDefault,
                onChanged: (value) {
                  setState(() {
                    _isDefault = value;
                  });
                },
                activeColor: AppColors.primary,
              ),
              const SizedBox(height: 24),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.address != null ? 'حفظ' : 'إضافة', // Save / Add
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

