import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../../home/presentation/cubits/home_cubit.dart';
import '../../../home/domain/entities/banner_entity.dart';
import '../cubits/restaurant_cubit.dart';
import '../../../orders/presentation/cubits/cart_cubit.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../cubits/favorites_cubit.dart';
import '../../../market_products/presentation/cubits/market_product_customer_cubit.dart';
import '../../../ads/presentation/cubits/startup_ad_customer_cubit.dart';
import '../../../../shared/widgets/startup_ad_popup.dart';
import '../../../delivery_address/presentation/cubits/delivery_address_cubit.dart';
import '../../../delivery_address/presentation/widgets/delivery_address_dialog.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final PageController _bannerController = PageController(
    viewportFraction: 0.92,
  );
  int _currentBannerIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<RestaurantEntity> _filteredRestaurants = [];
  List<RestaurantEntity> _allRestaurants = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterRestaurants);
    // Load restaurants and startup ads when home screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Load restaurants when screen first loads
        context.read<RestaurantCubit>().getAllRestaurants();
        context.read<StartupAdCustomerCubit>().loadActiveStartupAds();
      }
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _searchController.removeListener(_filterRestaurants);
    _searchController.dispose();
    super.dispose();
  }

  void _filterRestaurants() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredRestaurants = List.from(_allRestaurants);
      } else {
        _filteredRestaurants = _allRestaurants.where((restaurant) {
          final nameMatch = restaurant.name.toLowerCase().contains(query);
          final descMatch = restaurant.description.toLowerCase().contains(
            query,
          );
          final categoryMatch = restaurant.categories.any(
            (cat) => cat.toLowerCase().contains(query),
          );
          final addressMatch = restaurant.address.toLowerCase().contains(query);
          return nameMatch || descMatch || categoryMatch || addressMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: MultiBlocProvider(
        providers: [
          BlocProvider<RestaurantCubit>.value(
            value: context.read<RestaurantCubit>(),
          ),
          BlocProvider<HomeCubit>(create: (_) => HomeCubit()..loadHome()),
          BlocProvider<MarketProductCustomerCubit>(
            create: (context) =>
                context.read<MarketProductCustomerCubit>()
                  ..loadMarketProducts(),
          ),
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<RestaurantCubit, RestaurantState>(
              listener: (context, state) {
                if (state is RestaurantsLoaded) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _allRestaurants = state.restaurants;
                        _filteredRestaurants = state.restaurants;
                      });
                      _filterRestaurants();
                    }
                  });
                }
              },
            ),
            BlocListener<StartupAdCustomerCubit, StartupAdCustomerState>(
              listener: (context, state) {
                if (state is StartupAdCustomerLoaded && state.ads.isNotEmpty) {
                  // Show popup after a short delay to allow UI to settle
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (mounted && context.mounted) {
                          // Show the first ad as popup
                          StartupAdPopup.show(context, state.ads.first);
                        }
                      });
                    }
                  });
                }
              },
            ),
          ],
          child: BlocBuilder<RestaurantCubit, RestaurantState>(
            buildWhen: (previous, current) {
              // Always rebuild when we get RestaurantsLoaded to update local state
              if (current is RestaurantsLoaded) {
                return true; // Always rebuild to update local state
              }
              // If we have local data and state changes to RestaurantLoaded (from detail screen), don't rebuild
              // This prevents flicker when navigating back from detail screen
              if (_allRestaurants.isNotEmpty &&
                  current is! RestaurantsLoaded &&
                  current is! RestaurantLoading &&
                  current is! RestaurantError) {
                return false; // Don't rebuild when state is RestaurantLoaded (from detail) if we have local data
              }
              // Rebuild for loading and error states if we don't have local data
              if (_allRestaurants.isEmpty) {
                return current is RestaurantLoading ||
                    current is RestaurantError ||
                    current is RestaurantsLoaded;
              }
              // Rebuild for error states even if we have local data
              return current is RestaurantError;
            },
            builder: (context, state) {
              // If we have local restaurants, show them immediately to prevent flicker
              if (_allRestaurants.isNotEmpty) {
                // Reload restaurants in background when we detect wrong state (e.g., RestaurantLoaded from detail)
                if (state is! RestaurantsLoaded &&
                    state is! RestaurantLoading &&
                    state is! RestaurantError) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      context.read<RestaurantCubit>().getAllRestaurants();
                    }
                  });
                }
                // Show local state immediately to prevent flicker
                return _buildHome(
                  context,
                  _filteredRestaurants.isEmpty &&
                          _searchController.text.isNotEmpty
                      ? []
                      : _filteredRestaurants,
                  l10n,
                );
              }

              // Show loading/error only if we don't have local data
              if (state is RestaurantLoading) {
                return _buildShimmerLoading();
              } else if (state is RestaurantError) {
                return ErrorDisplayWidget(
                  message: state.message,
                  onRetry: () =>
                      context.read<RestaurantCubit>().getAllRestaurants(),
                );
              } else if (state is RestaurantsLoaded) {
                return _buildHome(
                  context,
                  _filteredRestaurants.isEmpty &&
                          _searchController.text.isNotEmpty
                      ? []
                      : _filteredRestaurants,
                  l10n,
                );
              }
              // Default to loading if state is unknown and we have no local data
              return _buildShimmerLoading();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHome(
    BuildContext context,
    List<RestaurantEntity> restaurants,
    AppLocalizations l10n,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<RestaurantCubit>().getAllRestaurants();
        await context.read<HomeCubit>().loadHome();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Combined App Bar with Delivery Address and Search Field
          SliverAppBar(
            expandedHeight: 0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primaryDark,
            toolbarHeight: 120,
            automaticallyImplyLeading: false,
            flexibleSpace: _CombinedAppBar(
              searchController: _searchController,
              onSearchChanged: _filterRestaurants,
            ),
          ),

          // Enhanced Banner Carousel with Indicators
          BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              final banners = state is HomeLoaded
                  ? state.banners
                  : <BannerEntity>[];
              return SliverToBoxAdapter(
                child: _BannerCarousel(
                  banners: banners,
                  controller: _bannerController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentBannerIndex = index;
                    });
                  },
                  currentIndex: _currentBannerIndex,
                ),
              );
            },
          ),

          // Enhanced Categories Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: _CategoriesSection(onTapSeeAll: () {}),
            ),
          ),

          // Market Products Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.marketProducts,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          BlocBuilder<MarketProductCustomerCubit, MarketProductCustomerState>(
            builder: (context, state) {
              if (state is MarketProductCustomerLoading) {
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 3,
                      itemBuilder: (context, index) => Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                );
              }
              if (state is MarketProductCustomerLoaded) {
                if (state.products.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = state.products[index];
                      return ProductCard(
                        productId: product.id,
                        productName: product.name,
                        description: product.description,
                        price: product.price,
                        imageUrl: product.imageUrl,
                        isAvailable: product.isAvailable,
                        isMarketProduct: true,
                      );
                    }, childCount: state.products.length),
                  ),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),

          // Restaurants Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'مطاعم قريبة منك',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'عرض الكل',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Enhanced Restaurants Grid
          if (restaurants.isEmpty)
            SliverFillRemaining(
              child: _EmptyStateWidget(
                title: _searchController.text.isNotEmpty
                    ? l10n.noRestaurantsFound
                    : l10n.noRestaurantsAvailable,
                message: _searchController.text.isNotEmpty
                    ? l10n.tryDifferentSearchTerm
                    : l10n.noRestaurantsAvailableMessage,
                icon: _searchController.text.isNotEmpty
                    ? Icons.search_off
                    : Icons.restaurant_outlined,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final restaurant = restaurants[index];
                  return _RestaurantCard(restaurant: restaurant);
                }, childCount: restaurants.length),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 0,
          floating: true,
          pinned: true,
          toolbarHeight: 100,
          backgroundColor: AppColors.surface,
          flexibleSpace: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 8,
                    itemBuilder: (context, index) => Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerCarousel extends StatelessWidget {
  final List<BannerEntity> banners;
  final PageController controller;
  final Function(int) onPageChanged;
  final int currentIndex;

  const _BannerCarousel({
    required this.banners,
    required this.controller,
    required this.onPageChanged,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final effective = banners.isEmpty
        ? [
            const BannerEntity(
              id: 'placeholder',
              imageUrl:
                  'https://images.unsplash.com/photo-1550547660-d9450f859349?q=80&w=1200',
              title: 'عروض خاصة',
            ),
          ]
        : banners;

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: controller,
            onPageChanged: onPageChanged,
            itemCount: effective.length,
            itemBuilder: (context, index) {
              final b = effective[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: b.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (c, u) => Container(
                          color: AppColors.surface,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (c, u, e) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryDark,
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                      // Gradient overlay
                      Container(
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
                      // Title overlay
                      if (b.title != null && b.title!.isNotEmpty)
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Text(
                            b.title!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (effective.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              effective.length,
              (index) => Container(
                width: currentIndex == index ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? AppColors.primary
                      : AppColors.textHint,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  final VoidCallback onTapSeeAll;
  const _CategoriesSection({required this.onTapSeeAll});

  @override
  Widget build(BuildContext context) {
    final items = [
      _Category(
        'لحوم',
        Icons.set_meal,
        const Color(0xFFFFE0E0),
      ), // Light red/pink
      _Category(
        'نودلز',
        Icons.ramen_dining,
        const Color(0xFFFFF8E1),
      ), // Light yellow/cream
      _Category(
        'بيتزا',
        Icons.local_pizza,
        const Color(0xFFFFE0B2),
      ), // Light orange/peach
      _Category(
        'برجر',
        Icons.lunch_dining,
        const Color(0xFFE0F2E0),
      ), // Light green/mint
      _Category('نباتي', Icons.eco, const Color(0xFFE8F5E9)), // Light green
      _Category('حلويات', Icons.cake, const Color(0xFFFFE0F0)), // Light pink
      _Category(
        'مشروبات',
        Icons.local_drink,
        const Color(0xFFE3F2FD),
      ), // Light blue
      _Category(
        'المزيد',
        Icons.more_horiz,
        const Color(0xFFF5F5F5),
      ), // Light gray
    ];

    // Icon colors matching their background themes
    final iconColors = [
      const Color(0xFFFF5252), // Red for لحوم
      const Color(0xFFFFC107), // Yellow for نودلز
      const Color(0xFFFF9800), // Orange for بيتزا
      const Color(0xFF4CAF50), // Green for برجر
      const Color(0xFF66BB6A), // Green for نباتي
      const Color(0xFFFF4081), // Pink for حلويات
      const Color(0xFF2196F3), // Blue for مشروبات
      AppColors.textSecondary, // Gray for المزيد
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'عرض الكل',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4CAF50), // Green text as in design
              ),
            ),
            Text(
              'عروض خاصة',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary, // Dark gray text
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final c = items[index];
              final iconColor = iconColors[index];
              return Container(
                width: 70,
                margin: EdgeInsets.only(
                  right: index == items.length - 1 ? 0 : 12,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: c.color, // Solid pastel background color
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        c.icon,
                        color: iconColor, // Solid colored icon matching theme
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary, // Dark gray text
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Category {
  final String label;
  final IconData icon;
  final Color color; // Background color (pastel)
  _Category(this.label, this.icon, this.color);
}

class _RestaurantCard extends StatelessWidget {
  final RestaurantEntity restaurant;

  const _RestaurantCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.border, width: 1),
      ),
      child: InkWell(
        onTap: () {
          context.push('/restaurant/${restaurant.id}');
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Image with Favorite Button
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child:
                        restaurant.imageUrl != null &&
                            restaurant.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: restaurant.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (context, url) => Container(
                              color: AppColors.border,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryLight,
                                    AppColors.primary,
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.restaurant,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryLight,
                                  AppColors.primary,
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.restaurant,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  // Favorite Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: BlocBuilder<FavoritesCubit, FavoritesState>(
                      builder: (context, favState) {
                        final isFav = favState.favoriteRestaurantIds.contains(
                          restaurant.id,
                        );
                        return Container(
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
                          child: IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav
                                  ? Colors.red
                                  : AppColors.textSecondary,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            onPressed: () {
                              context.read<FavoritesCubit>().toggleRestaurant(
                                restaurant.id,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  // Status Badge
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: restaurant.isOpen
                            ? AppColors.success
                            : AppColors.error,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            restaurant.isOpen ? 'مفتوح' : 'مغلق',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Restaurant Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Restaurant Name
                    Text(
                      restaurant.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Category or Description
                    if (restaurant.categories.isNotEmpty)
                      Text(
                        restaurant.categories.first,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else if (restaurant.description.isNotEmpty)
                      Text(
                        restaurant.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const Spacer(),
                    // Delivery Info
                    Row(
                      children: [
                        Icon(
                          Icons.delivery_dining,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${restaurant.deliveryFee.toStringAsFixed(0)} ر.س',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${restaurant.estimatedDeliveryTime} د',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
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
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const _EmptyStateWidget({
    required this.title,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CombinedAppBar extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onSearchChanged;

  const _CombinedAppBar({
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Use darker primary color for the app bar
    const appBarColor = AppColors.primaryDark;

    return Container(
      decoration: const BoxDecoration(
        color: appBarColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            children: [
              // Delivery Address Bar
              BlocBuilder<DeliveryAddressCubit, DeliveryAddressState>(
                builder: (context, state) {
                  String displayText;
                  if (state is DeliveryAddressSelected) {
                    displayText = state.displayAddress;
                  } else {
                    displayText =
                        'حدد عنوان التوصيل'; // Select delivery address
                  }

                  return InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => const DeliveryAddressDialog(),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          // Headphone Icon
                          const Icon(
                            Icons.headset_mic,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          // Delivery Text
                          Expanded(
                            child: Text(
                              displayText,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Chevron Icon
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Search Field and Action Buttons Row
              Row(
                children: [
                  // Search Field - White rounded container
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: StatefulBuilder(
                        builder: (context, setState) => TextField(
                          controller: searchController,
                          onChanged: (_) {
                            setState(() {});
                            onSearchChanged();
                          },
                          decoration: InputDecoration(
                            hintText: l10n.searchRestaurants,
                            hintStyle: TextStyle(
                              color: AppColors.textHint,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      searchController.clear();
                                      setState(() {});
                                      onSearchChanged();
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            isDense: true,
                          ),
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Profile Button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.person_outline,
                        color: appBarColor,
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () => context.push('/profile'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Favorites Button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.favorite_border,
                        color: appBarColor,
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () => context.push('/favorites'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Cart Button with Badge
                  BlocBuilder<CartCubit, CartState>(
                    builder: (context, state) {
                      final itemCount = state is CartLoaded
                          ? state.itemCount
                          : 0;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.shopping_cart_outlined,
                                color: appBarColor,
                                size: 22,
                              ),
                              padding: EdgeInsets.zero,
                              onPressed: () => context.push('/cart'),
                            ),
                          ),
                          if (itemCount > 0)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  itemCount > 99 ? '99+' : '$itemCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
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
