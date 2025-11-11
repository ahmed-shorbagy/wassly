import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
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
        title: const Text('Checkout'),
        elevation: 0,
      ),
      body: BlocConsumer<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state is OrderCreated) {
            // Clear cart
            context.read<CartCubit>().clearCart();
            
            // Show success and navigate to order detail
            context.showSuccessSnackBar('Order placed successfully!');
            context.go('/customer/order/${state.order.id}');
          } else if (state is OrderError) {
            context.showErrorSnackBar(state.message);
          }
        },
        builder: (context, orderState) {
          if (orderState is OrderCreating) {
            return const LoadingWidget(message: 'Placing your order...');
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
                      const Text('Cart is empty'),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.go('/customer'),
                        child: const Text('Browse Restaurants'),
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
                            _buildSectionHeader('Delivery Address'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _addressController,
                              decoration: const InputDecoration(
                                labelText: 'Address',
                                hintText: 'Enter your delivery address',
                                prefixIcon: Icon(Icons.location_on),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Address is required';
                                }
                                return null;
                              },
                              maxLines: 2,
                            ),
                            const SizedBox(height: 16),

                            // Contact Phone
                            _buildSectionHeader('Contact Information'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                hintText: 'Enter your phone number',
                                prefixIcon: Icon(Icons.phone),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Phone number is required';
                                }
                                if (value.length < 10) {
                                  return 'Please enter a valid phone number';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),

                            // Order Notes
                            _buildSectionHeader('Order Notes (Optional)'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _notesController,
                              decoration: const InputDecoration(
                                labelText: 'Notes',
                                hintText: 'Any special instructions?',
                                prefixIcon: Icon(Icons.note),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 24),

                            // Order Summary
                            _buildSectionHeader('Order Summary'),
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
                        '\$${item.totalPrice.toStringAsFixed(2)}',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal', style: TextStyle(fontSize: 14)),
                Text(
                  '\$${cartState.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Delivery Fee
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Delivery Fee', style: TextStyle(fontSize: 14)),
                Text(
                  '\$${_getDeliveryFee().toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${_getTotalAmount(cartState.totalPrice).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
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
            child: Text(
              'Place Order - \$${_getTotalAmount(cartState.totalPrice).toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      context.showErrorSnackBar('Please log in to place an order');
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
      deliveryLocation: null, // TODO: Get from map/geolocation
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

