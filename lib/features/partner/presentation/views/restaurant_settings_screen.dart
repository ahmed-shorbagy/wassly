import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../restaurants/presentation/cubits/restaurant_cubit.dart';
import '../../../restaurants/domain/entities/restaurant_entity.dart';

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
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (_restaurant == null) {
            return Center(
              child: Text(l10n.restaurantNotFound),
            );
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
                        leading: const Icon(Icons.edit, color: AppColors.primary),
                        title: Text(l10n.editRestaurant),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          final restaurantId = _restaurantId;
                          if (restaurantId != null) {
                            context.push('/admin/restaurants/edit/$restaurantId',
                                extra: _restaurant);
                          }
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.restaurant_menu,
                            color: AppColors.primary),
                        title: Text(l10n.manageProducts),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.push('/restaurant/products');
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.receipt_long,
                            color: AppColors.primary),
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
                      // Update restaurant status
                      // This would need to be implemented in RestaurantCubit
                      context.showInfoSnackBar(
                        'Status update coming soon',
                      );
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
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
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
}

