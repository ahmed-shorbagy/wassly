import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../home/presentation/cubits/home_cubit.dart';
import '../../../home/domain/entities/banner_entity.dart';
import '../cubits/restaurant_cubit.dart';
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
  int _currentBannerIndex = 0;
  int _currentDiscountIndex = 0;
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
                          // Show the first ad (list is already randomized and excludes last shown ad)
                          final adToShow = state.ads.first;
                          StartupAdPopup.show(context, adToShow);
                          
                          // Save the shown ad ID to exclude it from next session
                          context.read<StartupAdCustomerCubit>().saveShownAdId(adToShow.id);
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

  // Reduced aspect ratios to prevent overflow - lower values = more vertical space
  double _getResponsiveAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Calculate aspect ratio based on screen size - optimized to prevent overflow
    if (screenWidth < 350) {
      // Very small screens - maximum vertical space
      return 0.60;
    } else if (screenWidth < 400) {
      // Small screens
      return 0.62;
    } else if (screenHeight < 700) {
      // Short screens
      return 0.65;
    } else {
      // Normal and large screens
      return 0.63;
    }
  }

  Widget _buildHome(
    BuildContext context,
    List<RestaurantEntity> restaurants,
    AppLocalizations l10n,
  ) {
    // Separate restaurants with active discounts from regular restaurants
    final discountedRestaurants = restaurants
        .where((r) => r.isDiscountActive)
        .toList();
    final regularRestaurants = restaurants
        .where((r) => !r.isDiscountActive)
        .toList();

    return RefreshIndicator(
      onRefresh: () async {
        if (!context.mounted) return;
        await context.read<RestaurantCubit>().getAllRestaurants();
        if (!context.mounted) return;
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
            toolbarHeight: (MediaQuery.of(context).size.height * 0.12).clamp(90.0, 110.0),
            automaticallyImplyLeading: false,
            flexibleSpace: _CombinedAppBar(
              searchController: _searchController,
              onSearchChanged: _filterRestaurants,
              onSearchTap: () {
                context.push(
                  '/search?q=${Uri.encodeComponent(_searchController.text)}',
                  extra: _allRestaurants,
                );
              },
              restaurants: _allRestaurants,
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

          // Market Products Categories Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: _MarketProductCategoriesSection(
                onCategoryTap: (category, isMarket) {
                  if (isMarket) {
                    // Navigate to market products screen
                    context.push('/market-products');
                  } else {
                    // Navigate to search results with category filter for restaurants
                    context.push('/search?q=${Uri.encodeComponent(category)}');
                  }
                },
              ),
            ),
          ),

          // Discounted Restaurants Banner (in Market Section)
          if (discountedRestaurants.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  MediaQuery.of(context).size.width * 0.04,
                  24,
                  MediaQuery.of(context).size.width * 0.04,
                  8,
                ),
                child: _DiscountRestaurantsBannerCarousel(
                  restaurants: discountedRestaurants,
                  onPageChanged: (index) {
                    setState(() {
                      _currentDiscountIndex = index;
                    });
                  },
                  currentIndex: _currentDiscountIndex,
                ),
              ),
            ),

          // Restaurants Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.nearbyRestaurants,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      l10n.viewAll,
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

          // Enhanced Restaurants Grid (only regular restaurants, excluding discounted ones)
          if (regularRestaurants.isEmpty && discountedRestaurants.isEmpty)
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
          else if (regularRestaurants.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.all((MediaQuery.of(context).size.width * 0.04).clamp(12.0, 16.0)),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: _getResponsiveAspectRatio(context),
                  crossAxisSpacing: (MediaQuery.of(context).size.width * 0.04).clamp(12.0, 16.0),
                  mainAxisSpacing: (MediaQuery.of(context).size.width * 0.04).clamp(12.0, 16.0),
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final restaurant = regularRestaurants[index];
                  return _RestaurantCard(restaurant: restaurant);
                }, childCount: regularRestaurants.length),
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
  final Function(int) onPageChanged;
  final int currentIndex;

  const _BannerCarousel({
    required this.banners,
    required this.onPageChanged,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final effective = banners.isEmpty
        ? [
            BannerEntity(
              id: 'placeholder',
              imageUrl:
                  'https://images.unsplash.com/photo-1550547660-d9450f859349?q=80&w=1200',
              title: l10n.specialOffers,
            ),
          ]
        : banners;
    
    // Fixed banner height - consistent across all screen sizes
    const double bannerHeight = 160.0;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
      child: CarouselSlider(
        options: CarouselOptions(
          height: bannerHeight,
          viewportFraction: 0.95,
          enlargeCenterPage: false,
          enableInfiniteScroll: effective.length > 1,
          autoPlay: effective.length > 1,
          autoPlayInterval: const Duration(seconds: 4),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          onPageChanged: (index, reason) {
            onPageChanged(index);
          },
        ),
        items: effective.map((b) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Fixed banner dimensions: 342px width × 160px height
                      return SizedBox(
                        width: 342.0,
                        height: bannerHeight,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: b.imageUrl,
                              width: 342.0,
                              height: bannerHeight,
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
                      );
                    },
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final RestaurantEntity restaurant;

  const _RestaurantCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: restaurant.isDiscountActive ? 4 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: restaurant.isDiscountActive
              ? AppColors.warning
              : AppColors.border,
          width: restaurant.isDiscountActive ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          context.push('/restaurant/${restaurant.id}');
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Restaurant Image with Favorite Button
            AspectRatio(
              aspectRatio: 1.0,
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
                  // Favorite Button - Smaller
                  Positioned(
                    top: 6,
                    right: 6,
                    child: BlocBuilder<FavoritesCubit, FavoritesState>(
                      builder: (context, favState) {
                        final isFav = favState.favoriteRestaurantIds.contains(
                          restaurant.id,
                        );
                        return GestureDetector(
                          onTap: () {
                            context.read<FavoritesCubit>().toggleRestaurant(
                              restaurant.id,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav
                                  ? Colors.red
                                  : AppColors.textSecondary,
                              size: 16,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Discount Badge (Top Left)
                  if (restaurant.isDiscountActive)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              AppColors.warning, // Orange/Yellow for discount
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_offer,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              restaurant.discountPercentage != null
                                  ? '${restaurant.discountPercentage!.toStringAsFixed(0)}%'
                                  : 'OFF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Status Badge - Smaller (only dot indicator)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: restaurant.isOpen
                            ? AppColors.success
                            : AppColors.error,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Builder(
                            builder: (context) {
                              final l10n = AppLocalizations.of(context)!;
                              return Text(
                                restaurant.isOpen ? l10n.open : l10n.closed,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  height: 1.0,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Restaurant Info - Optimized for Arabic text with overflow protection
            Padding(
              padding: EdgeInsets.all((MediaQuery.of(context).size.width * 0.025).clamp(6.0, 10.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Restaurant Name - 2 lines for Arabic support
                  AutoSizeText(
                    restaurant.name,
                    style: TextStyle(
                      fontSize: (MediaQuery.of(context).size.width * 0.038).clamp(13.0, 15.0),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    minFontSize: 10,
                    maxFontSize: (MediaQuery.of(context).size.width * 0.038).clamp(13.0, 15.0).roundToDouble(),
                    overflow: TextOverflow.ellipsis,
                    wrapWords: false,
                  ),
                  SizedBox(height: (MediaQuery.of(context).size.height * 0.005).clamp(3.0, 6.0)),
                  // Category or Description - 2 lines for Arabic support
                  if (restaurant.categories.isNotEmpty)
                    AutoSizeText(
                      restaurant.categories.first,
                      style: TextStyle(
                        fontSize: (MediaQuery.of(context).size.width * 0.028).clamp(9.0, 11.0),
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      minFontSize: 8,
                      maxFontSize: (MediaQuery.of(context).size.width * 0.028).clamp(9.0, 11.0).roundToDouble(),
                      overflow: TextOverflow.ellipsis,
                      wrapWords: false,
                    )
                  else if (restaurant.description.isNotEmpty)
                    AutoSizeText(
                      restaurant.description,
                      style: TextStyle(
                        fontSize: (MediaQuery.of(context).size.width * 0.028).clamp(9.0, 11.0),
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      minFontSize: 8,
                      maxFontSize: (MediaQuery.of(context).size.width * 0.028).clamp(9.0, 11.0).roundToDouble(),
                      overflow: TextOverflow.ellipsis,
                      wrapWords: false,
                    ),
                  SizedBox(height: (MediaQuery.of(context).size.height * 0.005).clamp(3.0, 6.0)),
                  // Delivery Info
                  Wrap(
                    spacing: 4,
                    runSpacing: 3,
                    children: [
                      Icon(
                        Icons.delivery_dining,
                        size: (MediaQuery.of(context).size.width * 0.032).clamp(11.0, 13.0),
                        color: AppColors.primary,
                      ),
                      Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context)!;
                          return AutoSizeText(
                            '${restaurant.deliveryFee.toStringAsFixed(0)} ${l10n.currencySymbol}',
                            style: TextStyle(
                              fontSize: (MediaQuery.of(context).size.width * 0.026).clamp(8.0, 10.0),
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            minFontSize: 7,
                          );
                        },
                      ),
                      Icon(
                        Icons.access_time,
                        size: (MediaQuery.of(context).size.width * 0.032).clamp(11.0, 13.0),
                        color: AppColors.textSecondary,
                      ),
                      Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context)!;
                          return AutoSizeText(
                            '${restaurant.estimatedDeliveryTime} ${l10n.minutesAbbreviation}',
                            style: TextStyle(
                              fontSize: (MediaQuery.of(context).size.width * 0.026).clamp(8.0, 10.0),
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            minFontSize: 7,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketProductCategoriesSection extends StatelessWidget {
  final Function(String, bool) onCategoryTap; // category, isMarket

  const _MarketProductCategoriesSection({
    required this.onCategoryTap,
  });

  Widget _buildMarketCard(
    BuildContext context,
    String imagePath,
    String title,
    VoidCallback onTap,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardHeight = (screenWidth * 0.25).clamp(90.0, 110.0);
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: cardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.surface,
                    child: Icon(
                      Icons.image_not_supported,
                      size: (screenWidth * 0.12).clamp(36.0, 48.0),
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: (screenWidth * 0.02).clamp(6.0, 8.0)),
          Flexible(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: (screenWidth * 0.03).clamp(10.0, 12.0),
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'الفئات',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: (MediaQuery.of(context).size.height * 0.02).clamp(12.0, 16.0)),
        // Market Images - Grid layout (scrollable horizontal)
        SizedBox(
          height: (MediaQuery.of(context).size.width * 0.3).clamp(110.0, 140.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            itemBuilder: (context, index) {
              final categories = [
                {
                  'image': 'assets/images/resturants.jpeg',
                  'title': l10n.fastFood,
                  'category': null,
                },
                {
                  'image': 'assets/images/fruits&veg.jpeg',
                  'title': l10n.fruits,
                  'category': l10n.fruits,
                },
                {
                  'image': 'assets/images/market.jpeg',
                  'title': l10n.market,
                  'category': null,
                },
                {
                  'image': 'assets/images/fish.jpeg',
                  'title': l10n.fish,
                  'category': l10n.fish,
                },
                {
                  'image': 'assets/images/meats.jpeg',
                  'title': l10n.meat,
                  'category': l10n.meat,
                },
                {
                  'image': 'assets/images/cake&cofee.jpeg',
                  'title': l10n.bakery,
                  'category': l10n.bakery,
                },
              ];
              
              final item = categories[index];
              final screenWidth = MediaQuery.of(context).size.width;
              final cardWidth = (screenWidth * 0.28).clamp(100.0, 120.0);
              
              return Padding(
                padding: EdgeInsets.only(
                  right: index == categories.length - 1 
                      ? 0 
                      : ((screenWidth * 0.03).clamp(10.0, 12.0)),
                ),
                child: SizedBox(
                  width: cardWidth,
                  child: _buildMarketCard(
                    context,
                    item['image'] as String,
                    item['title'] as String,
                    () {
                      final category = item['category'];
                      final title = item['title'] as String;
                      final isMarket = title == l10n.market;
                      
                      if (isMarket) {
                        // Navigate to market products screen
                        onCategoryTap(title, true);
                      } else if (category != null) {
                        // Navigate to search results with category filter for restaurants
                        onCategoryTap(category, false);
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// New banner-style carousel for discounted restaurants in market section
class _DiscountRestaurantsBannerCarousel extends StatelessWidget {
  final List<RestaurantEntity> restaurants;
  final Function(int) onPageChanged;
  final int currentIndex;

  const _DiscountRestaurantsBannerCarousel({
    required this.restaurants,
    required this.onPageChanged,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Fixed banner height - consistent across all screen sizes
    const double bannerHeight = 160.0;

    if (restaurants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.specialOffers,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (restaurants.length > 1)
              GestureDetector(
                onTap: () {
                  // Could navigate to a special offers page
                },
                child: Text(
                  l10n.viewAll,
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: (MediaQuery.of(context).size.height * 0.015).clamp(10.0, 12.0)),
        // Banner Carousel
        CarouselSlider(
          options: CarouselOptions(
            height: bannerHeight,
            viewportFraction: 0.95,
            enlargeCenterPage: false,
            enableInfiniteScroll: restaurants.length > 1,
            autoPlay: restaurants.length > 1,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            onPageChanged: (index, reason) {
              onPageChanged(index);
            },
          ),
          items: restaurants.map((restaurant) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      context.push('/restaurant/${restaurant.id}');
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        width: 342.0,
                        height: bannerHeight,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Restaurant Image
                            restaurant.imageUrl != null &&
                                    restaurant.imageUrl!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: restaurant.imageUrl!,
                                    width: 342.0,
                                    height: bannerHeight,
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
                                        Icons.restaurant,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          AppColors.primaryDark,
                                        ],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.restaurant,
                                      color: Colors.white,
                                      size: 50,
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
                                    Colors.black.withValues(alpha: 0.5),
                                  ],
                                ),
                              ),
                            ),
                            // Discount Badge
                            if (restaurant.isDiscountActive &&
                                restaurant.discountPercentage != null)
                              Positioned(
                                top: 16,
                                left: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.local_offer,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${restaurant.discountPercentage!.toStringAsFixed(0)}% ${l10n.off}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            // Restaurant Info at Bottom
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.8),
                                    ],
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      restaurant.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            offset: Offset(0, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    if (restaurant.description.isNotEmpty)
                                      Text(
                                        restaurant.description,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          fontSize: 14,
                                          shadows: const [
                                            Shadow(
                                              color: Colors.black54,
                                              offset: Offset(0, 1),
                                              blurRadius: 3,
                                            ),
                                          ],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
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
                );
              },
            );
          }).toList(),
        ),
      // Indicators
      if (restaurants.length > 1) ...[
          SizedBox(height: (MediaQuery.of(context).size.height * 0.01).clamp(8.0, 12.0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              restaurants.length,
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
  final VoidCallback? onSearchTap;
  final List<RestaurantEntity> restaurants;

  const _CombinedAppBar({
    required this.searchController,
    required this.onSearchChanged,
    this.onSearchTap,
    this.restaurants = const [],
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
          padding: EdgeInsets.fromLTRB(
            (MediaQuery.of(context).size.width * 0.04).clamp(12.0, 16.0),
            8,
            (MediaQuery.of(context).size.width * 0.04).clamp(12.0, 16.0),
            (MediaQuery.of(context).size.height * 0.015).clamp(10.0, 12.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Delivery Address Bar
              BlocBuilder<DeliveryAddressCubit, DeliveryAddressState>(
                builder: (context, state) {
                  String displayText;
                  if (state is DeliveryAddressSelected) {
                    displayText = state.displayAddress;
                  } else {
                    displayText = l10n.selectDeliveryAddress;
                  }

                  return InkWell(
                    onTap: () {
                      // Navigate to address book screen for better address management
                      context.push('/address-book');
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: (MediaQuery.of(context).size.height * 0.015).clamp(10.0, 12.0),
                      ),
                      child: Row(
                        children: [
                          // Headphone Icon
                          Icon(
                            Icons.headset_mic,
                            color: Colors.white,
                            size: (MediaQuery.of(context).size.width * 0.05).clamp(18.0, 20.0),
                          ),
                          SizedBox(width: (MediaQuery.of(context).size.width * 0.03).clamp(10.0, 12.0)),
                          // Delivery Text
                          Expanded(
                            child: Text(
                              displayText,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: (MediaQuery.of(context).size.width * 0.035).clamp(12.0, 14.0),
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Chevron Icon
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: (MediaQuery.of(context).size.width * 0.05).clamp(18.0, 20.0),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Search Field - Full Width
              Container(
                height: (MediaQuery.of(context).size.height * 0.05).clamp(38.0, 42.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: StatefulBuilder(
                  builder: (context, setState) => TextField(
                    controller: searchController,
                    onTap: () {
                      if (onSearchTap != null) {
                        onSearchTap!();
                      }
                    },
                    onChanged: (_) {
                      setState(() {});
                      onSearchChanged();
                      // Navigate to search results if there's text
                      if (searchController.text.isNotEmpty &&
                          onSearchTap != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (context.mounted) {
                            context.push(
                              '/search?q=${Uri.encodeComponent(searchController.text)}',
                              extra: restaurants,
                            );
                          }
                        });
                      }
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
                        vertical: 10,
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
            ],
          ),
        ),
      ),
    );
  }
}
