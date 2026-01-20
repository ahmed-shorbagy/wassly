import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../restaurants/domain/entities/restaurant_entity.dart';
import '../../../delivery_address/presentation/cubits/delivery_address_cubit.dart';
import '../../../delivery_address/presentation/widgets/delivery_address_dialog.dart';
import '../../domain/entities/order_entity.dart';
import '../cubits/cart_cubit.dart';
import '../cubits/order_cubit.dart';

class CheckoutScreen extends StatefulWidget {
  final RestaurantEntity restaurant;

  const CheckoutScreen({super.key, required this.restaurant});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isPickup = false;

  @override
  void initState() {
    super.initState();
    // Load delivery address from cubit when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final addressState = context.read<DeliveryAddressCubit>().state;
        if (addressState is DeliveryAddressSelected) {
          _addressController.text = addressState.address;
        }
        // Load user phone from auth if available
        final authState = context.read<AuthCubit>().state;
        if (authState is AuthAuthenticated) {
          final phone = authState.user.phone;
          if (phone.isNotEmpty) {
            _phoneController.text = phone;
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            return Text(l10n?.checkout ?? 'الدفع');
          },
        ),
        elevation: 0,
      ),
      body: BlocConsumer<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state is OrderCreated) {
            // Clear cart
            context.read<CartCubit>().clearCart();

            // Show success and navigate to order summary
            final l10n = AppLocalizations.of(context);
            context.showSuccessSnackBar(
              l10n?.orderPlacedSuccessfully ?? 'تم تقديم الطلب بنجاح',
            );
            // Navigate to the new order summary screen
            context.pushReplacement('/order-summary/${state.order.id}');
          } else if (state is OrderError) {
            context.showErrorSnackBar(state.message);
          }
        },
        builder: (context, orderState) {
          if (orderState is OrderCreating) {
            final l10n = AppLocalizations.of(context);
            return LoadingWidget(
              message: l10n?.placingOrder ?? 'جاري تقديم الطلب...',
            );
          }

          return BlocBuilder<CartCubit, CartState>(
            builder: (context, cartState) {
              if (cartState is! CartLoaded || cartState.items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)?.cartIsEmpty ??
                            'السلة فارغة',
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.go('/home'),
                        child: Text(
                          AppLocalizations.of(context)?.browseRestaurants ??
                              'تصفح المطاعم',
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Delivery Mode Toggle
                            Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context);
                                return Column(
                                  children: [
                                    _buildSectionHeader(
                                      l10n?.deliveryMode ?? 'Delivery Mode',
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () => setState(
                                                () => _isPickup = false,
                                              ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: !_isPickup
                                                      ? Colors.white
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  boxShadow: !_isPickup
                                                      ? [
                                                          BoxShadow(
                                                            color:
                                                                Colors.black12,
                                                            blurRadius: 4,
                                                          ),
                                                        ]
                                                      : null,
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  l10n?.delivery ?? 'Delivery',
                                                  style: TextStyle(
                                                    fontWeight: !_isPickup
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                    color: !_isPickup
                                                        ? AppColors.primary
                                                        : Colors.grey.shade700,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () => setState(
                                                () => _isPickup = true,
                                              ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: _isPickup
                                                      ? Colors.white
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  boxShadow: _isPickup
                                                      ? [
                                                          BoxShadow(
                                                            color:
                                                                Colors.black12,
                                                            blurRadius: 4,
                                                          ),
                                                        ]
                                                      : null,
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  l10n?.pickupFromRestaurant ??
                                                      'Pickup',
                                                  style: TextStyle(
                                                    fontWeight: _isPickup
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                    color: _isPickup
                                                        ? AppColors.primary
                                                        : Colors.grey.shade700,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                            const SizedBox(height: 24),

                            // Delivery Address
                            if (!_isPickup)
                              BlocBuilder<
                                DeliveryAddressCubit,
                                DeliveryAddressState
                              >(
                                builder: (context, addressState) {
                                  final l10n = AppLocalizations.of(context);
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildSectionHeader(
                                            l10n?.deliveryAddress ??
                                                'عنوان التوصيل',
                                          ),
                                          if (addressState
                                              is DeliveryAddressSelected)
                                            TextButton.icon(
                                              onPressed: () {
                                                // Show dialog to manage addresses
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      const DeliveryAddressDialog(),
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.edit,
                                                size: 16,
                                              ),
                                              label: Text(
                                                l10n?.edit ?? 'تعديل',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _addressController,
                                        decoration: InputDecoration(
                                          labelText:
                                              l10n?.deliveryAddress ??
                                              'عنوان التوصيل',
                                          hintText:
                                              l10n?.enterDeliveryAddress ??
                                              'أدخل عنوان التوصيل',
                                          prefixIcon: const Icon(
                                            Icons.location_on,
                                          ),
                                          suffixIcon:
                                              addressState
                                                  is DeliveryAddressSelected
                                              ? Icon(
                                                  Icons.check_circle,
                                                  color: AppColors.success,
                                                  size: 20,
                                                )
                                              : null,
                                        ),
                                        validator: (value) {
                                          if (_isPickup) return null;
                                          final l10n = AppLocalizations.of(
                                            context,
                                          );
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return l10n?.addressRequired ??
                                                'العنوان مطلوب';
                                          }
                                          return null;
                                        },
                                        maxLines: 2,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            const SizedBox(height: 16),

                            // Contact Phone
                            Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context);
                                return _buildSectionHeader(
                                  l10n?.contactInformation ?? 'معلومات الاتصال',
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context);
                                return TextFormField(
                                  controller: _phoneController,
                                  decoration: InputDecoration(
                                    labelText:
                                        l10n?.phoneNumber ?? 'رقم الهاتف',
                                    hintText:
                                        l10n?.enterPhoneNumber ??
                                        'أدخل رقم الهاتف',
                                    prefixIcon: const Icon(Icons.phone),
                                  ),
                                  validator: (value) {
                                    final l10n = AppLocalizations.of(context);
                                    if (value == null || value.trim().isEmpty) {
                                      return l10n?.phoneNumberRequired ??
                                          'رقم الهاتف مطلوب';
                                    }
                                    if (value.length < 10) {
                                      return l10n
                                              ?.pleaseEnterValidPhoneNumber ??
                                          'يرجى إدخال رقم هاتف صحيح';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.phone,
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Order Notes
                            Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context);
                                return _buildSectionHeader(
                                  l10n?.orderNotes ?? 'ملاحظات الطلب (اختياري)',
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context);
                                return TextFormField(
                                  controller: _notesController,
                                  decoration: InputDecoration(
                                    labelText: l10n?.notes ?? 'ملاحظات',
                                    hintText:
                                        l10n?.anySpecialInstructions ??
                                        'أي تعليمات خاصة؟',
                                    prefixIcon: const Icon(Icons.note),
                                  ),
                                  maxLines: 3,
                                );
                              },
                            ),
                            const SizedBox(height: 24),

                            // Order Summary
                            Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context);
                                return _buildSectionHeader(
                                  l10n?.orderSummary ?? 'ملخص الطلب',
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildOrderSummary(cartState),
                          ],
                        ),
                      ),
                    ),

                    // Bottom bar with total and place order button
                    _buildBottomBar(context, cartState),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildOrderSummary(CartLoaded cartState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Restaurant info
            Row(
              children: [
                const Icon(Icons.restaurant, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.restaurant.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Items
            ...cartState.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.quantity}x ${item.product.name}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context);
                        return Text(
                          '${item.totalPrice.toStringAsFixed(2)} ${l10n?.currencySymbol ?? 'ج.م'}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 24),

            // Subtotal
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n?.subtotal ?? 'المجموع الفرعي',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      '${cartState.totalPrice.toStringAsFixed(2)} ${l10n?.currencySymbol ?? 'ج.م'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),

            // Delivery Fee
            if (!_isPickup)
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n?.deliveryFee ?? 'رسوم التوصيل',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        '${_getDeliveryFee().toStringAsFixed(2)} ${l10n?.currencySymbol ?? 'ج.م'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  );
                },
              ),
            const SizedBox(height: 12),

            // Total
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n?.total ?? 'المجموع',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_getTotalAmount(cartState.totalPrice).toStringAsFixed(2)} ${l10n?.currencySymbol ?? 'ج.م'}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                );
              },
            ),
            if (_isPickup)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context);
                    return Text(
                      l10n?.pickupFromRestaurant ?? 'Pickup',
                      style: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, CartLoaded cartState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _placeOrder(context, cartState),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                return Text(
                  '${l10n?.placeOrder ?? 'تقديم الطلب'} - ${_getTotalAmount(cartState.totalPrice).toStringAsFixed(2)} ${l10n?.currencySymbol ?? 'ج.م'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  double _getDeliveryFee() {
    if (_isPickup) return 0.0;
    // Use restaurant's delivery fee, fallback to 5.0 if not available
    return widget.restaurant.deliveryFee > 0
        ? widget.restaurant.deliveryFee
        : 5.0;
  }

  double _getTotalAmount(double subtotal) {
    return subtotal + _getDeliveryFee();
  }

  Future<void> _placeOrder(BuildContext context, CartLoaded cartState) async {
    final l10n = AppLocalizations.of(context);

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate cart
    final cartValid = await context.read<CartCubit>().validateCartForCheckout();
    if (!cartValid || cartState.items.isEmpty) {
      context.showErrorSnackBar(
        'Cart is invalid. Please refresh and try again.',
      );
      // Reload cart to sync state
      context.read<CartCubit>().loadCart();
      return;
    }

    // Validate cart items belong to the correct restaurant
    final allItemsFromRestaurant = cartState.items.every(
      (item) => item.product.restaurantId == widget.restaurant.id,
    );

    if (!allItemsFromRestaurant) {
      context.showErrorSnackBar(
        'Cart contains items from different restaurants. Please clear cart and try again.',
      );
      return;
    }

    // Validate minimum order amount
    if (widget.restaurant.minOrderAmount > 0 &&
        cartState.totalPrice < widget.restaurant.minOrderAmount) {
      final minAmount = widget.restaurant.minOrderAmount.toStringAsFixed(2);
      final currency = l10n?.currencySymbol ?? 'ج.م';
      context.showErrorSnackBar('Minimum order amount is $minAmount $currency');
      return;
    }

    // Validate all products are still available
    final unavailableProducts = cartState.items
        .where((item) => !item.product.isAvailable)
        .toList();

    if (unavailableProducts.isNotEmpty) {
      final productNames = unavailableProducts
          .map((item) => item.product.name)
          .join(', ');
      context.showErrorSnackBar(
        'Some products are no longer available: $productNames. Please remove them and try again.',
      );
      return;
    }

    // Validate all items have valid prices
    final invalidPriceItems = cartState.items
        .where((item) => item.product.price <= 0 || item.quantity <= 0)
        .toList();

    if (invalidPriceItems.isNotEmpty) {
      context.showErrorSnackBar(
        'Some items have invalid prices or quantities. Please refresh and try again.',
      );
      // Reload cart to sync state
      context.read<CartCubit>().loadCart();
      return;
    }

    // Validate restaurant is open (if needed)
    // Note: This is a business decision - you might want to allow orders even if restaurant is closed
    // for scheduled orders. For now, we'll allow it but the restaurant can reject it.

    // Get current user
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      context.showErrorSnackBar(
        l10n?.pleaseLoginToPlaceOrder ?? 'يرجى تسجيل الدخول لتقديم الطلب',
      );
      return;
    }

    final user = authState.user;

    // Get delivery location - use restaurant location as default
    // Note: DeliveryAddressSelected state only contains address string, not GeoPoint
    // For now, we use restaurant location. In future, we could fetch full address entity
    // from repository if location is needed for distance calculations
    final deliveryLocation = _convertToGeoPoint(widget.restaurant.location);

    // Create order items
    final items = cartState.items.map((cartItem) {
      return OrderItemEntity(
        productId: cartItem.product.id,
        productName: cartItem.product.name,
        price: cartItem.product.price,
        quantity: cartItem.quantity,
        imageUrl: cartItem.product.imageUrl,
      );
    }).toList();

    // Create order
    final order = OrderEntity(
      id: '', // Will be generated by Firestore
      customerId: user.id,
      customerName: user.name,
      customerPhone: _phoneController.text.trim(),
      restaurantId: widget.restaurant.id,
      restaurantName: widget.restaurant.name,
      restaurantImage: widget.restaurant.imageUrl,
      items: items,
      totalAmount: _getTotalAmount(cartState.totalPrice),
      status: OrderStatus.pending,
      deliveryAddress: _isPickup ? 'PICKUP' : _addressController.text.trim(),
      deliveryLocation: deliveryLocation,
      restaurantLocation: _convertToGeoPoint(widget.restaurant.location),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      isPickup: _isPickup,
    );

    // Save delivery address to cubit for future use (syncs across all apps)
    // This ensures the address is synced in Firebase and available across all apps
    if (!_isPickup) {
      final l10nForAddress = AppLocalizations.of(context);
      context.read<DeliveryAddressCubit>().setDeliveryAddress(
        address: _addressController.text.trim(),
        addressLabel: l10nForAddress?.defaultAddress ?? 'Default',
      );
    }

    // Place order
    context.read<OrderCubit>().createOrder(order);
  }

  GeoPoint? _convertToGeoPoint(Map<String, dynamic> location) {
    try {
      if (location.containsKey('latitude') &&
          location.containsKey('longitude')) {
        return GeoPoint(
          location['latitude'] as double,
          location['longitude'] as double,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
