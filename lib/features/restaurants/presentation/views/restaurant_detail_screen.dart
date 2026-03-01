import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../cubits/restaurant_cubit.dart';
import '../../../home/presentation/cubits/home_cubit.dart';
import '../../../orders/presentation/cubits/cart_cubit.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../../domain/entities/food_category_entity.dart';
import '../cubits/favorites_cubit.dart';
import '../cubits/food_category_cubit.dart';
import '../../../../core/utils/search_helper.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;
  final String? highlightProductId;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurantId,
    this.highlightProductId,
  });

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

    // Filter by search query using Smart Fuzzy Search
    final searchQuery = _searchController.text.toLowerCase().trim();
    if (searchQuery.isNotEmpty) {
      filtered = SearchHelper.filterList(
        items: filtered,
        query: searchQuery,
        getSearchStrings: (product) => [product.name, product.description],
      );
    }

    return filtered;
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
                // If a specific product was linked, auto-search it once loaded
                if (widget.highlightProductId != null &&
                    widget.highlightProductId!.isNotEmpty &&
                    _searchController.text.isEmpty) {
                  final targetProduct = _products
                      .where((p) => p.id == widget.highlightProductId)
                      .firstOrNull;
                  if (targetProduct != null) {
                    _searchController.text = targetProduct.name;
                  }
                }
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

  Widget _buildInfoItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
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
        // Top Section with Full-Width Cover Image
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leadingWidth: 70,
          leading: Center(
            child: _buildOverlayIconButton(
              icon: Icons.arrow_back_ios_new,
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
            ),
          ),
          actions: [
            BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, favState) {
                final isFav = favState.favoriteRestaurantIds.contains(
                  restaurant.id,
                );
                return _buildOverlayIconButton(
                  icon: isFav ? Icons.favorite : Icons.favorite_border,
                  iconColor: isFav ? Colors.red : Colors.white,
                  onTap: () => context.read<FavoritesCubit>().toggleRestaurant(
                    restaurant.id,
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            _buildOverlayIconButton(icon: Icons.share_outlined, onTap: () {}),
            const SizedBox(width: 16),
          ],
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 70, bottom: 16),
            title: Text(
              restaurant.name,
              style: const TextStyle(
                color: Colors
                    .transparent, // Only show title when collapsed (actual logic below)
                fontWeight: FontWeight.bold,
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Full Width Background Image
                Hero(
                  tag: 'restaurant_image_${restaurant.id}',
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
                            color: AppColors.primary.withValues(alpha: 0.1),
                            child: const Icon(
                              Icons.restaurant,
                              size: 60,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.restaurant,
                            size: 60,
                            color: AppColors.primary,
                          ),
                        ),
                ),
                // Gradient Overlay
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black45,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black87,
                      ],
                      stops: [0.0, 0.2, 0.6, 1.0],
                    ),
                  ),
                ),
                // Logo overlay (Bottom Left) - Integrated into the image area
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child:
                          restaurant.imageUrl != null &&
                              restaurant.imageUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: restaurant.imageUrl!,
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.restaurant,
                              color: AppColors.primary,
                            ),
                    ),
                  ),
                ),
              ],
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
                  // Restaurant Name and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: AppColors.textPrimary,
                              ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l10n.open,
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Cuisine Type
                  BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, state) {
                      String categoriesText = l10n.restaurants;
                      if (state is HomeLoaded &&
                          restaurant.categoryIds.isNotEmpty) {
                        final names = restaurant.categoryIds
                            .map((id) {
                              final cat = state.categories
                                  .where((c) => c.id == id)
                                  .firstOrNull;
                              return cat?.name;
                            })
                            .whereType<String>()
                            .toList();
                        if (names.isNotEmpty) {
                          categoriesText = names.join(' • ');
                        }
                      }
                      return Text(
                        categoriesText,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Info Row (Rating, Time, Delivery)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem(
                        icon: Icons.star,
                        iconColor: Colors.amber,
                        title: restaurant.rating.toStringAsFixed(1),
                        subtitle: '(${restaurant.totalReviews})',
                      ),
                      _buildInfoItem(
                        icon: Icons.access_time_filled,
                        iconColor: AppColors.primary,
                        title: '${restaurant.estimatedDeliveryTime}',
                        subtitle: l10n.minutes,
                      ),
                      _buildInfoItem(
                        icon: Icons.delivery_dining,
                        iconColor: AppColors.success,
                        title: restaurant.deliveryFee == 0
                            ? l10n.free
                            : restaurant.deliveryFee.toStringAsFixed(0),
                        subtitle: l10n.currencySymbol,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Discount Banner (if active)
                  if (restaurant.isDiscountActive)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_offer,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              restaurant.discountDescription ??
                                  (restaurant.discountPercentage != null
                                      ? '${restaurant.discountPercentage!.toStringAsFixed(0)}% ${l10n.off}'
                                      : l10n.specialOffer),
                              style: const TextStyle(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
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
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = _filteredProducts[index];
              final isLast = index == _filteredProducts.length - 1;
              return _ProductListTile(
                product: product,
                restaurant: restaurant,
                isLast: isLast,
              );
            }, childCount: _filteredProducts.length),
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: iconColor ?? Colors.white),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final restaurant = _restaurant;

    if (restaurant == null) return const SizedBox.shrink();

    final minOrder = restaurant.minOrderAmount;
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final double currentTotal = state is CartLoaded
            ? state.totalPrice
            : 0.0;
        final remaining = minOrder > currentTotal
            ? minOrder - currentTotal
            : 0.0;
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
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.error,
                          ),
                        ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: remaining == 0 ? () => context.go('/cart') : null,
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

class _ProductListTile extends StatefulWidget {
  final ProductEntity product;
  final RestaurantEntity restaurant;
  final bool isLast;

  const _ProductListTile({
    required this.product,
    required this.restaurant,
    required this.isLast,
  });

  @override
  State<_ProductListTile> createState() => _ProductListTileState();
}

class _ProductListTileState extends State<_ProductListTile> {
  bool isLoading = false;
  bool isSuccess = false;

  Future<void> handleAddToCart() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      isSuccess = false;
    });

    final cartCubit = context.read<CartCubit>();
    final state = cartCubit.state;
    bool success = false;

    try {
      if (state is CartLoaded &&
          state.restaurantId != null &&
          state.restaurantId != widget.product.restaurantId &&
          state.items.isNotEmpty) {
        final l10n = AppLocalizations.of(context);

        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n?.startNewOrder ?? 'Start New Order'),
            content: Text(
              l10n?.clearCartConfirmation ??
                  'You have items from another restaurant. Start a new order to clear the cart?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n?.cancelAction ?? 'Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n?.newOrder ?? 'New Order'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          await cartCubit.clearCart();
          if (mounted) {
            success = await cartCubit.addItem(widget.product, context: context);
          }
        } else {
          // User cancelled
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
          return;
        }
      } else {
        success = await cartCubit.addItem(widget.product, context: context);
      }

      if (mounted) {
        if (success) {
          setState(() {
            isLoading = false;
            isSuccess = true;
          });
          // Show success state for 1.5 seconds then reset
          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) {
            setState(() {
              isSuccess = false;
            });
          }
        } else {
          // Failed (toast already shown by Cubit)
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: widget.product.isAvailable ? handleAddToCart : null,
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
                        child:
                            widget.product.imageUrl != null &&
                                widget.product.imageUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: widget.product.imageUrl!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppColors.border,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
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
                        onTap: widget.product.isAvailable
                            ? handleAddToCart
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isSuccess
                                ? AppColors.success
                                : (widget.product.isAvailable
                                      ? AppColors.warning
                                      : AppColors.textSecondary),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (isSuccess
                                            ? AppColors.success
                                            : Colors.black)
                                        .withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : isSuccess
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : const Icon(
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
                        widget.product.name,
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
                        widget.product.description,
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
                        '${widget.product.price.toStringAsFixed(2)} ${l10n.currencySymbol}',
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
          if (!widget.isLast)
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
