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
            
            // Show success and navigate to order detail
            final l10n = AppLocalizations.of(context);
            context.showSuccessSnackBar(
              l10n?.orderPlacedSuccessfully ?? 'تم تقديم الطلب بنجاح',
            );
            context.push('/order/${state.order.id}');
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
                        AppLocalizations.of(context)?.cartIsEmpty ?? 'السلة فارغة',
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.push('/home'),
                        child: Text(
                          AppLocalizations.of(context)?.browseRestaurants ?? 'تصفح المطاعم',
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
                            // Delivery Address
                            Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context);
                                return _buildSectionHeader(
                                  l10n?.deliveryAddress ?? 'عنوان التوصيل',
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context);
                                return TextFormField(
                                  controller: _addressController,
                                  decoration: InputDecoration(
                                    labelText: l10n?.deliveryAddress ?? 'عنوان التوصيل',
                                    hintText: l10n?.enterDeliveryAddress ?? 'أدخل عنوان التوصيل',
                                    prefixIcon: const Icon(Icons.location_on),
                                  ),
                                  validator: (value) {
                                    final l10n = AppLocalizations.of(context);
                                    if (value == null || value.trim().isEmpty) {
                                      return l10n?.addressRequired ?? 'العنوان مطلوب';
                                    }
                                    return null;
                                  },
                                  maxLines: 2,
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
                                    labelText: l10n?.phoneNumber ?? 'رقم الهاتف',
                                    hintText: l10n?.enterPhoneNumber ?? 'أدخل رقم الهاتف',
                                    prefixIcon: const Icon(Icons.phone),
                                  ),
                                  validator: (value) {
                                    final l10n = AppLocalizations.of(context);
                                    if (value == null || value.trim().isEmpty) {
                                      return l10n?.phoneNumberRequired ?? 'رقم الهاتف مطلوب';
                                    }
                                    if (value.length < 10) {
                                      return l10n?.pleaseEnterValidPhoneNumber ?? 'يرجى إدخال رقم هاتف صحيح';
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
                                    hintText: l10n?.anySpecialInstructions ?? 'أي تعليمات خاصة؟',
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
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
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
            ...cartState.items.map((item) => Padding(
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
                      Text(
                        '${item.totalPrice.toStringAsFixed(2)} ر.س',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )),

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
                      '${cartState.totalPrice.toStringAsFixed(2)} ر.س',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),

            // Delivery Fee
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
                      '${_getDeliveryFee().toStringAsFixed(2)} ر.س',
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
                  '${_getTotalAmount(cartState.totalPrice).toStringAsFixed(2)} ر.س',
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
                  '${l10n?.placeOrder ?? 'تقديم الطلب'} - ${_getTotalAmount(cartState.totalPrice).toStringAsFixed(2)} ر.س',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  double _getDeliveryFee() {
    // Fixed delivery fee for now
    return 5.0;
  }

  double _getTotalAmount(double subtotal) {
    return subtotal + _getDeliveryFee();
  }

  Future<void> _placeOrder(BuildContext context, CartLoaded cartState) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Get current user
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      final l10n = AppLocalizations.of(context);
      context.showErrorSnackBar(
        l10n?.pleaseLoginToPlaceOrder ?? 'يرجى تسجيل الدخول لتقديم الطلب',
      );
      return;
    }

    final user = authState.user;

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
      deliveryAddress: _addressController.text.trim(),
      deliveryLocation: _convertToGeoPoint(widget.restaurant.location), // Use restaurant location as fallback
      restaurantLocation: _convertToGeoPoint(widget.restaurant.location),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    // Place order
    context.read<OrderCubit>().createOrder(order);
  }

  GeoPoint? _convertToGeoPoint(Map<String, dynamic> location) {
    try {
      if (location.containsKey('latitude') && location.containsKey('longitude')) {
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

