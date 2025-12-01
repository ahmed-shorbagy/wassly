import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../cubits/restaurant_cubit.dart';
import '../../../orders/presentation/cubits/cart_cubit.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../../domain/entities/food_category_entity.dart';
import '../cubits/favorites_cubit.dart';
import '../cubits/food_category_cubit.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen>
    with TickerProviderStateMixin {
  RestaurantEntity? _restaurant;
  List<ProductEntity> _products = [];
  List<FoodCategoryEntity> _categories = [];
  String? _selectedCategoryId;
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          if (_tabController.index == 0) {
            _selectedCategoryId = null; // 'all'
          } else {
            _selectedCategoryId = _categories[_tabController.index - 1].id;
          }
        });
      }
    });
    _searchController.addListener(_filterProducts);

    // Load data when screen first loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RestaurantCubit>()
          ..getRestaurantById(widget.restaurantId)
          ..getRestaurantProducts(widget.restaurantId);
        context.read<FoodCategoryCubit>().loadRestaurantCategories(
          widget.restaurantId,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts() {
    setState(() {
      // Filtering is handled in _filteredProducts getter
    });
  }

  List<ProductEntity> get _filteredProducts {
    var filtered = _products;

    // Filter by category
    if (_selectedCategoryId != null) {
      filtered = filtered
          .where((p) => p.categoryId == _selectedCategoryId)
          .toList();
    }

    // Filter by search query
    final searchQuery = _searchController.text.toLowerCase().trim();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        final nameMatch = product.name.toLowerCase().contains(searchQuery);
        final descMatch = product.description.toLowerCase().contains(
          searchQuery,
        );
        return nameMatch || descMatch;
      }).toList();
    }

    return filtered;
  }

  double get _cartTotal {
    final cartState = context.read<CartCubit>().state;
    if (cartState is CartLoaded) {
      return cartState.totalPrice;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<FoodCategoryCubit, FoodCategoryState>(
        listener: (context, state) {
          if (state is FoodCategoryLoaded) {
            setState(() {
              _categories = state.categories;
              final newLength = _categories.length + 1; // +1 for 'all'

              if (_tabController.length != newLength) {
                _tabController.dispose();
                _tabController = TabController(length: newLength, vsync: this);
                _tabController.addListener(() {
                  if (_tabController.indexIsChanging) {
                    setState(() {
                      if (_tabController.index == 0) {
                        _selectedCategoryId = null; // 'all'
                      } else {
                        _selectedCategoryId =
                            _categories[_tabController.index - 1].id;
                      }
                    });
                  }
                });
              }
            });
          }
        },
        child: BlocConsumer<RestaurantCubit, RestaurantState>(
          listener: (context, state) {
            if (state is RestaurantLoaded) {
              setState(() {
                _restaurant = state.restaurant;
              });
            }
            if (state is ProductsLoaded) {
              setState(() {
                _products = state.products;
              });
            }
          },
          builder: (context, state) {
            if (state is RestaurantLoading && _restaurant == null) {
              return const LoadingWidget();
            }

            if (state is RestaurantError && _restaurant == null) {
              return ErrorDisplayWidget(
                message: state.message,
                onRetry: () {
                  context.read<RestaurantCubit>().getRestaurantById(
                    widget.restaurantId,
                  );
                  context.read<RestaurantCubit>().getRestaurantProducts(
                    widget.restaurantId,
                  );
                },
              );
            }

            if (_restaurant != null) {
              return _buildRestaurantDetail(context, _restaurant!, _products);
            }

            return const LoadingWidget();
          },
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildRestaurantDetail(
    BuildContext context,
    RestaurantEntity restaurant,
    List<ProductEntity> products,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return CustomScrollView(
      slivers: [
        // Top Section with Logo and Overlay Icons
        SliverAppBar(
          expandedHeight: 280,
          pinned: false,
          floating: false,
          automaticallyImplyLeading: false, // Remove default back button
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: AppColors.promoBackground, // Light pastel green background
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Large Circular Logo
                  Center(
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: AppColors.primary, width: 8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child:
                            restaurant.imageUrl != null &&
                                restaurant.imageUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: restaurant.imageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppColors.border,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  child: Icon(
                                    Icons.restaurant,
                                    size: 60,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : Container(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                child: Icon(
                                  Icons.restaurant,
                                  size: 60,
                                  color: AppColors.primary,
                                ),
                              ),
                      ),
                    ),
                  ),

                  // Overlay Icons
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left side: Back and Favorite
                              Row(
                                children: [
                                  _buildOverlayIconButton(
                                    icon: Icons.arrow_back_ios,
                                    onTap: () {
                                      if (context.canPop()) {
                                        context.pop();
                                      } else {
                                        context.go('/home');
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  BlocBuilder<FavoritesCubit, FavoritesState>(
                                    builder: (context, favState) {
                                      final isFav = favState
                                          .favoriteRestaurantIds
                                          .contains(restaurant.id);
                                      return _buildOverlayIconButton(
                                        icon: isFav
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        iconColor: isFav
                                            ? Colors.red
                                            : AppColors.textPrimary,
                                        onTap: () => context
                                            .read<FavoritesCubit>()
                                            .toggleRestaurant(restaurant.id),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              // Right side: Share, Search, and Navigation
                              Row(
                                children: [
                                  _buildOverlayIconButton(
                                    icon: Icons.share,
                                    onTap: () {},
                                  ),
                                  const SizedBox(width: 12),
                                  _buildOverlayIconButton(
                                    icon: Icons.search,
                                    onTap: () {
                                      // Scroll to search bar or focus it
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  _buildOverlayIconButton(
                                    icon: Icons.arrow_forward_ios,
                                    onTap: () {},
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Restaurant Info Section
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant Name with Icon
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.restaurant_menu,
                          color: AppColors.success,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: AppColors.textPrimary,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Cuisine Type
                  Text(
                    restaurant.categories.isNotEmpty
                        ? restaurant.categories.join(', ')
                        : l10n.restaurants,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(+${restaurant.totalReviews})',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Discount Banner (if active)
                  if (restaurant.isDiscountActive)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.warning,
                            AppColors.warning.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.warning.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.local_offer,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  restaurant.discountPercentage != null
                                      ? '${restaurant.discountPercentage!.toStringAsFixed(0)}% ${l10n.off}'
                                      : l10n.specialOffer,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (restaurant.discountDescription != null &&
                                    restaurant.discountDescription!.isNotEmpty)
                                  const SizedBox(height: 4),
                                if (restaurant.discountDescription != null &&
                                    restaurant.discountDescription!.isNotEmpty)
                                  Text(
                                    restaurant.discountDescription!,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Delivery Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${restaurant.estimatedDeliveryTime} ${l10n.minutes}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.delivery_dining,
                                size: 16,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                restaurant.deliveryFee == 0
                                    ? l10n.free
                                    : '${restaurant.deliveryFee.toStringAsFixed(0)} ${l10n.currencySymbol}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Search Bar and Category Filter
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                // Search Bar
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.border.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: StatefulBuilder(
                      builder: (context, setState) => TextField(
                        controller: _searchController,
                        onChanged: (_) {
                          setState(() {});
                          _filterProducts();
                        },
                        decoration: InputDecoration(
                          hintText: l10n.searchProducts,
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.6,
                            ),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.success,
                            size: 20,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: AppColors.textSecondary,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                    _filterProducts();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Category Filter Label
                Text(
                  l10n.all,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Tab Navigation
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(
            TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: [
                Tab(text: l10n.all),
                ..._categories.map((category) {
                  return Tab(text: category.name);
                }),
              ],
            ),
          ),
        ),

        // Products List
        if (_filteredProducts.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 64,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noProductsFound,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = _filteredProducts[index];
                final isLast = index == _filteredProducts.length - 1;
                return _ProductListTile(
                  product: product,
                  restaurant: restaurant,
                  isLast: isLast,
                );
              },
              childCount: _filteredProducts.length,
            ),
          ),
      ],
    );
  }

  Widget _buildOverlayIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: iconColor ?? AppColors.textPrimary),
      ),
    );
  }


  Widget _buildBottomBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final restaurant = _restaurant;

    if (restaurant == null) return const SizedBox.shrink();

    final minOrder = restaurant.minOrderAmount;
    final currentTotal = _cartTotal;
    final remaining = minOrder > currentTotal ? minOrder - currentTotal : 0.0;

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final itemCount = state is CartLoaded ? state.itemCount : 0;

        if (itemCount == 0) {
          return SafeArea(
            child: Container(
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
              child: Text(
                l10n.addProductsWorth(minOrder.toStringAsFixed(2)),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ),
          );
        }

        return SafeArea(
          child: Container(
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
            child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.total,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${currentTotal.toStringAsFixed(2)} ${l10n.currencySymbol}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    if (remaining > 0)
                      Text(
                        l10n.addProductsWorth(remaining.toStringAsFixed(2)),
                        style: TextStyle(fontSize: 11, color: AppColors.error),
                      ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: remaining == 0 ? () => context.push('/cart') : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(l10n.viewCart),
              ),
            ],
            ),
          ),
        );
      },
    );
  }
}

class _ProductListTile extends StatelessWidget {
  final ProductEntity product;
  final RestaurantEntity restaurant;
  final bool isLast;

  const _ProductListTile({
    required this.product,
    required this.restaurant,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: product.isAvailable
          ? () async {
              await context.read<CartCubit>().addItem(product, context: context);
            }
          : null,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image with Add Button Overlay
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.border,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: product.imageUrl!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppColors.border,
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColors.border,
                                  child: const Icon(
                                    Icons.fastfood,
                                    size: 40,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )
                            : Container(
                                color: AppColors.border,
                                child: const Icon(
                                  Icons.fastfood,
                                  size: 40,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                      ),
                    ),
                // Add Button Overlay (Bottom Left)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: product.isAvailable
                        ? () async {
                            await context.read<CartCubit>().addItem(
                                  product,
                                  context: context,
                                );
                          }
                        : null,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: product.isAvailable
                            ? AppColors.warning
                            : AppColors.textSecondary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                  ],
                ),
                const SizedBox(width: 16),
                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Product Title
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Product Description
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      // Price
                      Text(
                        '${product.price.toStringAsFixed(2)} ${l10n.currencySymbol}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Separator
          if (!isLast)
            Divider(
              height: 1,
              thickness: 1,
              color: AppColors.border,
              indent: 16,
              endIndent: 16,
            ),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return false;
  }
}
