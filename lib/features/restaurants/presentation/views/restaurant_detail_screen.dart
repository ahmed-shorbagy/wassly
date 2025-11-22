import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/product_card.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => context.read<RestaurantCubit>()
            ..getRestaurantById(widget.restaurantId)
            ..getRestaurantProducts(widget.restaurantId),
        ),
        BlocProvider(
          create: (context) =>
              context.read<FoodCategoryCubit>()
                ..loadRestaurantCategories(widget.restaurantId),
        ),
      ],
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && context.mounted) {
            // Try to pop first - let BackButtonHandler handle root navigation
            if (context.canPop()) {
              context.pop();
            }
            // If we can't pop, let the root BackButtonHandler handle navigation to home
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: BlocListener<FoodCategoryCubit, FoodCategoryState>(
            listener: (context, state) {
              if (state is FoodCategoryLoaded) {
                setState(() {
                  _categories = state.categories;
                  final newLength = _categories.length + 1; // +1 for 'all'

                  if (_tabController.length != newLength) {
                    _tabController.dispose();
                    _tabController = TabController(
                      length: newLength,
                      vsync: this,
                    );
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
                } else if (state is ProductsLoaded) {
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
                  return _buildRestaurantDetail(
                    context,
                    _restaurant!,
                    _products,
                  );
                }

                return const LoadingWidget();
              },
            ),
          ),
          bottomNavigationBar: _buildBottomBar(context),
        ),
      ),
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
        // Hero Image Section
        SliverAppBar(
          expandedHeight: 300,
          pinned: false,
          floating: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Main Image
                restaurant.imageUrl != null && restaurant.imageUrl!.isNotEmpty
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
                          color: AppColors.border,
                          child: const Icon(Icons.restaurant, size: 80),
                        ),
                      )
                    : Container(
                        color: AppColors.border,
                        child: const Icon(Icons.restaurant, size: 80),
                      ),

                // Gradient Overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                ),

                // Action Buttons Overlay
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back Button
                            _buildActionButton(
                              icon: Icons.arrow_back_ios,
                              onTap: () {
                                // Try to pop first - let BackButtonHandler handle root navigation
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  // If we can't pop, navigate to home
                                  // This allows proper back navigation stack
                                  context.go('/home');
                                }
                              },
                            ),
                            // Right side buttons
                            Row(
                              children: [
                                _buildActionButton(
                                  icon: Icons.search,
                                  onTap: () {},
                                ),
                                const SizedBox(width: 12),
                                _buildActionButton(
                                  icon: Icons.share,
                                  onTap: () {},
                                ),
                                const SizedBox(width: 12),
                                BlocBuilder<FavoritesCubit, FavoritesState>(
                                  builder: (context, favState) {
                                    final isFav = favState.favoriteRestaurantIds
                                        .contains(restaurant.id);
                                    return _buildActionButton(
                                      icon: isFav
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      iconColor: isFav
                                          ? Colors.red
                                          : Colors.white,
                                      onTap: () => context
                                          .read<FavoritesCubit>()
                                          .toggleRestaurant(restaurant.id),
                                    );
                                  },
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

        // Restaurant Info Card
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Restaurant Name
                            Text(
                              restaurant.name,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                            ),
                            const SizedBox(height: 4),
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
                            const SizedBox(height: 8),
                            // Rating
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 18,
                                ),
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
                          ],
                        ),
                      ),
                      // Restaurant Logo Placeholder
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.restaurant,
                          color: AppColors.primary,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Delivery Info
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          restaurant.deliveryFee == 0
                              ? l10n.free
                              : '\$${restaurant.deliveryFee.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
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

        // Search Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                    hintStyle: TextStyle(color: AppColors.textHint),
                    prefixIcon: Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: AppColors.textSecondary,
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

        // Products Grid
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
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = _filteredProducts[index];
                return _buildProductCard(context, product);
              }, childCount: _filteredProducts.length),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? Colors.white, size: 20),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductEntity product) {
    final l10n = AppLocalizations.of(context)!;
    final restaurant = _restaurant;

    return ProductCard(
      productId: product.id,
      productName: product.name,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      isAvailable: product.isAvailable,
      restaurantId: restaurant?.id,
      onTap: () async {
        if (product.isAvailable) {
          await context.read<CartCubit>().addItem(product);
          if (context.mounted) {
            context.showSuccessSnackBar(
              l10n.itemAddedToCart(product.name),
            );
          }
        }
      },
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
            child: Text(
              l10n.addProductsWorth(minOrder.toStringAsFixed(2)),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          );
        }

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
                      '\$${currentTotal.toStringAsFixed(2)}',
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
        );
      },
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
