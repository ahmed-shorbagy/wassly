import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../restaurants/presentation/cubits/restaurant_cubit.dart';
import '../../../restaurants/domain/entities/restaurant_entity.dart';
import '../../../restaurants/data/models/restaurant_model.dart';

class RestaurantSettingsScreen extends StatefulWidget {
  const RestaurantSettingsScreen({super.key});

  @override
  State<RestaurantSettingsScreen> createState() =>
      _RestaurantSettingsScreenState();
}

class _RestaurantSettingsScreenState extends State<RestaurantSettingsScreen> {
  RestaurantEntity? _restaurant;
  String? _restaurantId;

  @override
  void initState() {
    super.initState();
    _loadRestaurant();
  }

  void _loadRestaurant() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<RestaurantCubit>().getRestaurantByOwnerId(authState.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<RestaurantCubit, RestaurantState>(
        listener: (context, state) {
          if (state is RestaurantLoaded) {
            setState(() {
              _restaurant = state.restaurant;
              _restaurantId = state.restaurant.id;
            });
          }
        },
        builder: (context, state) {
          if (state is RestaurantLoading && _restaurant == null) {
            return const LoadingWidget();
          }

          if (state is RestaurantError && _restaurant == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadRestaurant,
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          if (_restaurant == null) {
            return Center(child: Text(l10n.restaurantNotFound));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.restaurantInformation,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          Icons.restaurant,
                          l10n.restaurantName,
                          _restaurant!.name,
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          Icons.email,
                          l10n.email,
                          _restaurant!.email ?? 'N/A',
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          Icons.phone,
                          l10n.phoneNumber,
                          _restaurant!.phone,
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          Icons.location_on,
                          l10n.address,
                          _restaurant!.address,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Actions
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.edit,
                          color: AppColors.primary,
                        ),
                        title: Text(l10n.editRestaurant),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navigate to edit restaurant screen (partner version)
                          _showEditRestaurantDialog();
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.restaurant_menu,
                          color: AppColors.primary,
                        ),
                        title: Text(l10n.manageProducts),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.push('/restaurant/products');
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.receipt_long,
                          color: AppColors.primary,
                        ),
                        title: Text(l10n.restaurantOrders),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.push('/restaurant/orders');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Status Toggle
                Card(
                  child: SwitchListTile(
                    title: Text(l10n.restaurantStatus),
                    subtitle: Text(
                      _restaurant!.isOpen
                          ? l10n.restaurantIsOpen
                          : l10n.restaurantIsClosed,
                    ),
                    value: _restaurant!.isOpen,
                    onChanged: (value) {
                      if (_restaurantId != null) {
                        context.read<RestaurantCubit>().toggleRestaurantStatus(
                          _restaurantId!,
                          value,
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Discount Management
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.local_offer,
                          color: AppColors.warning,
                        ),
                        title: Text(l10n.discount),
                        subtitle: Text(
                          _restaurant!.isDiscountActive
                              ? _restaurant!.discountPercentage != null
                                    ? '${_restaurant!.discountPercentage!.toStringAsFixed(0)}% ${l10n.off}'
                                    : l10n.activeDiscount
                              : l10n.disableDiscount,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navigate to discount management
                          _showDiscountDialog();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Support Helper
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.support_agent,
                      color: AppColors.primary,
                    ),
                    title: Text(l10n.supportChat),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.pushNamed('restaurant-support');
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Category Management
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.category,
                      color: AppColors.primary,
                    ),
                    title: Text(l10n.foodCategories),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      if (_restaurantId != null) {
                        context.push(
                          '/restaurant/categories',
                          extra: {'restaurantId': _restaurantId},
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDiscountDialog() {
    final restaurant = _restaurant!;
    final l10n = AppLocalizations.of(context)!;
    final discountPercentageController = TextEditingController(
      text: restaurant.discountPercentage?.toStringAsFixed(0) ?? '',
    );
    final discountDescriptionController = TextEditingController(
      text: restaurant.discountDescription ?? '',
    );
    bool hasDiscount = restaurant.hasDiscount;
    DateTime? startDate = restaurant.discountStartDate;
    DateTime? endDate = restaurant.discountEndDate;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.discount),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enable Discount Switch
                SwitchListTile(
                  title: Text(l10n.enableDiscount),
                  value: hasDiscount,
                  onChanged: (value) {
                    setDialogState(() {
                      hasDiscount = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                if (hasDiscount) ...[
                  // Discount Percentage
                  TextFormField(
                    controller: discountPercentageController,
                    decoration: InputDecoration(
                      labelText: l10n.discountPercentage,
                      hintText: l10n.discountPercentageHint,
                      prefixIcon: const Icon(Icons.percent),
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Discount Description
                  TextFormField(
                    controller: discountDescriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.discountDescription,
                      hintText: l10n.discountDescription,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Start Date
                  ListTile(
                    title: Text('${l10n.discountStartDate} (${l10n.optional})'),
                    subtitle: Text(
                      startDate != null
                          ? DateFormat('yyyy-MM-dd').format(startDate!)
                          : l10n.noStartDate,
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setDialogState(() {
                          startDate = date;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8),

                  // End Date
                  ListTile(
                    title: Text('${l10n.discountEndDate} (${l10n.optional})'),
                    subtitle: Text(
                      endDate != null
                          ? DateFormat('yyyy-MM-dd').format(endDate!)
                          : l10n.noEndDate,
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate:
                            endDate ??
                            DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setDialogState(() {
                          endDate = date;
                        });
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (hasDiscount && discountPercentageController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.discountPercentage)),
                  );
                  return;
                }

                final model = RestaurantModel.fromEntity(restaurant);
                final updatedModel = model.copyWith(
                  hasDiscount: hasDiscount,
                  discountPercentage:
                      hasDiscount &&
                          discountPercentageController.text.isNotEmpty
                      ? double.tryParse(discountPercentageController.text)
                      : null,
                  discountDescription:
                      hasDiscount &&
                          discountDescriptionController.text.isNotEmpty
                      ? discountDescriptionController.text.trim()
                      : null,
                  discountStartDate: hasDiscount ? startDate : null,
                  discountEndDate: hasDiscount ? endDate : null,
                );
                final updatedRestaurant = updatedModel;

                context.read<RestaurantCubit>().updateRestaurant(
                  updatedRestaurant,
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${l10n.discount} ${l10n.updatedSuccessfully}',
                    ),
                  ),
                );
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditRestaurantDialog() {
    final restaurant = _restaurant!;
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: restaurant.name);
    final descriptionController = TextEditingController(
      text: restaurant.description,
    );
    final phoneController = TextEditingController(text: restaurant.phone);
    final emailController = TextEditingController(text: restaurant.email ?? '');
    final addressController = TextEditingController(text: restaurant.address);
    final deliveryFeeController = TextEditingController(
      text: restaurant.deliveryFee.toStringAsFixed(2),
    );
    final minOrderController = TextEditingController(
      text: restaurant.minOrderAmount.toStringAsFixed(2),
    );
    final deliveryTimeController = TextEditingController(
      text: restaurant.estimatedDeliveryTime.toString(),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.editRestaurant),
        content: SingleChildScrollView(
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.restaurantName,
                    prefixIcon: const Icon(Icons.restaurant),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.pleaseEnterRestaurantName;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: l10n.description,
                    prefixIcon: const Icon(Icons.description),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.pleaseEnterDescription;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: l10n.phoneNumber,
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.pleaseEnterPhoneNumber;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: l10n.address,
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.pleaseEnterAddress;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: deliveryFeeController,
                  decoration: InputDecoration(
                    labelText: l10n.deliveryFee,
                    prefixIcon: const Icon(Icons.delivery_dining),
                    suffixText: l10n.currencySymbol,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterDeliveryFee;
                    }
                    if (double.tryParse(value) == null) {
                      return l10n.invalidNumber;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: minOrderController,
                  decoration: InputDecoration(
                    labelText: l10n.minOrder,
                    prefixIcon: const Icon(Icons.shopping_cart),
                    suffixText: l10n.currencySymbol,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterMinimumOrderAmount;
                    }
                    if (double.tryParse(value) == null) {
                      return l10n.invalidNumber;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: deliveryTimeController,
                  decoration: InputDecoration(
                    labelText: l10n.estimatedDeliveryTime,
                    prefixIcon: const Icon(Icons.access_time),
                    suffixText: l10n.minutes,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterDeliveryTime;
                    }
                    if (int.tryParse(value) == null) {
                      return l10n.invalidNumber;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              // Validate and update
              final model = RestaurantModel.fromEntity(restaurant);
              final updatedModel = model.copyWith(
                name: nameController.text.trim(),
                description: descriptionController.text.trim(),
                phone: phoneController.text.trim(),
                email: emailController.text.trim().isEmpty
                    ? null
                    : emailController.text.trim(),
                address: addressController.text.trim(),
                deliveryFee: double.parse(deliveryFeeController.text),
                minOrderAmount: double.parse(minOrderController.text),
                estimatedDeliveryTime: int.parse(deliveryTimeController.text),
              );
              final updatedRestaurant = updatedModel;

              context.read<RestaurantCubit>().updateRestaurant(
                updatedRestaurant,
              );
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.restaurantUpdatedSuccessfully)),
              );
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
