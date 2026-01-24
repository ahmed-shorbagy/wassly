import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wassly/features/restaurants/presentation/widgets/restaurant_card.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../home/presentation/cubits/home_cubit.dart';
import '../../../home/domain/entities/banner_entity.dart';
import '../../../home/domain/entities/promotional_image_entity.dart';
import '../../../home/presentation/widgets/promotional_image_widget.dart';
import '../../domain/entities/restaurant_category_entity.dart';
import '../cubits/restaurant_cubit.dart';
import '../../domain/entities/restaurant_entity.dart';
// import '../cubits/favorites_cubit.dart'; // Favorites not used in new card design
import '../../../market_products/presentation/cubits/market_product_customer_cubit.dart';
import '../../../ads/presentation/cubits/startup_ad_customer_cubit.dart';
import '../../../../shared/widgets/startup_ad_popup.dart';
import '../../../delivery_address/presentation/cubits/delivery_address_cubit.dart';
import 'package:lottie/lottie.dart';
// import '../widgets/restaurant_card.dart'; // Unused
// import '../../../../core/constants/market_product_categories.dart'; // Unused
// import '../../../market_products/domain/entities/market_product_entity.dart'; // Unused

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
        // Load home data (banners, categories)
        context.read<HomeCubit>().loadHome();
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
          final queryLower = query.toLowerCase();
          final nameMatch = restaurant.name.toLowerCase().contains(queryLower);
          final descMatch = restaurant.description.toLowerCase().contains(
            queryLower,
          );

          // Resolve category names from IDs to allow searching by category name
          final homeState = context.read<HomeCubit>().state;
          final categories = homeState is HomeLoaded
              ? homeState.categories
              : [];
          final categoryMatch = restaurant.categoryIds.any((cid) {
            final category = categories.where((c) => c.id == cid).firstOrNull;
            return category?.name.toLowerCase().contains(queryLower) ??
                cid.toLowerCase().contains(queryLower);
          });

          final addressMatch = restaurant.address.toLowerCase().contains(
            queryLower,
          );
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
                          context.read<StartupAdCustomerCubit>().saveShownAdId(
                            adToShow.id,
                          );
                        }
                      });
                    }
                  });
                }
              },
            ),
            BlocListener<HomeCubit, HomeState>(
              listener: (context, state) {
                if (state is HomeLoaded) {
                  _filterRestaurants();
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

  // _getResponsiveAspectRatio is no longer used (grid is now horizontal with fixed card height)

  Widget _buildHome(
    BuildContext context,
    List<RestaurantEntity> restaurants,
    AppLocalizations l10n,
  ) {
    // Separate restaurants with active discounts from regular restaurants
    final discountedRestaurants = restaurants
        .where((r) => r.isDiscountActive)
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
            toolbarHeight: ResponsiveHelper.getAppBarHeight(context),
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
                  ? state.banners.where((b) => b.type == 'home').toList()
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

          // Promotional Image Section
          BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              final promoImages = state is HomeLoaded
                  ? state.promotionalImages
                  : <PromotionalImageEntity>[];
              if (promoImages.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        l10n.exploreOurRichWorld,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    PromotionalImageWidget(image: promoImages.first),
                  ],
                ),
              );
            },
          ),

          // Restaurant Categories Section
          BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              final categories = state is HomeLoaded
                  ? state.categories
                  : <RestaurantCategoryEntity>[];
              return SliverToBoxAdapter(
                child: Padding(
                  padding: ResponsiveHelper.padding(horizontal: 16, top: 16),
                  child: _MarketProductCategoriesSection(
                    restaurantCategories: categories,
                    onCategoryTap: (category, isMarket) {
                      if (isMarket) {
                        // Navigate to Market Products Screen
                        if (category == l10n.market) {
                          // Main Market Page
                          context.push('/market-products');
                        } else {
                          // Filtered Market Page
                          context.push('/market-products?category=$category');
                        }
                      } else {
                        // Navigate to Restaurants Search
                        if (category == l10n.restaurants) {
                          context.push('/search', extra: _allRestaurants);
                        } else {
                          context.push(
                            '/search?q=${Uri.encodeComponent(category)}',
                            extra: _allRestaurants,
                          );
                        }
                      }
                    },
                  ),
                ),
              );
            },
          ),

          // Discounted Restaurants Banner (in Market Section)
          if (discountedRestaurants.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: ResponsiveHelper.padding(
                  horizontal: 16,
                  top: 24,
                  bottom: 8,
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
              padding: ResponsiveHelper.padding(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.nearbyRestaurants,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontSize: ResponsiveHelper.fontSize(16),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.push('/search?q=', extra: _allRestaurants);
                    },
                    child: Text(
                      l10n.viewAll,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: ResponsiveHelper.fontSize(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Enhanced Restaurants Grid (shows all restaurants, including discounted ones)
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
            // Three independent horizontal rows, each scrolls separately
            SliverToBoxAdapter(
              child: Padding(
                padding: ResponsiveHelper.padding(all: 16),
                child: _ThreeRowRestaurantScroller(restaurants: restaurants),
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
          toolbarHeight: ResponsiveHelper.getAppBarHeight(context),
          backgroundColor: AppColors.surface,
          flexibleSpace: Container(
            padding: ResponsiveHelper.padding(
              horizontal: 16,
              top: 16,
              bottom: 12,
            ),
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(24.r),
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

    // Responsive banner height
    final double bannerHeight = 130.h;

    return Padding(
      padding: ResponsiveHelper.padding(left: 16, top: 16, right: 8, bottom: 0),
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
                      // Responsive banner dimensions
                      return SizedBox(
                        width: double.infinity,
                        height: bannerHeight,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: b.imageUrl,
                              width: double.infinity,
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
                                bottom: 16.h,
                                left: 16.w,
                                right: 16.w,
                                child: AutoSizeText(
                                  b.title!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ResponsiveHelper.fontSize(18),
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        offset: Offset(0, 2.h),
                                        blurRadius: 4.r,
                                      ),
                                    ],
                                  ),
                                  maxLines: 2,
                                  minFontSize: 12,
                                  overflow: TextOverflow.ellipsis,
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

// Three separate horizontal rows for restaurants; each row scrolls independently.
class _ThreeRowRestaurantScroller extends StatelessWidget {
  final List<RestaurantEntity> restaurants;

  const _ThreeRowRestaurantScroller({required this.restaurants});

  @override
  Widget build(BuildContext context) {
    // Distribute restaurants into three rows
    final List<List<RestaurantEntity>> rows = [[], [], []];
    for (var i = 0; i < restaurants.length; i++) {
      rows[i % 3].add(restaurants[i]);
    }

    final double cardWidth = MediaQuery.of(context).size.width * 0.7;
    final double cardHeight = 220.h;

    Widget buildRow(List<RestaurantEntity> rowItems) {
      if (rowItems.isEmpty) return const SizedBox.shrink();
      return SizedBox(
        height: cardHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding:
              EdgeInsets.zero, // Remove internal padding as parent has padding
          physics: const ClampingScrollPhysics(),
          itemCount: rowItems.length,
          separatorBuilder: (_, __) => SizedBox(width: 12.w),
          itemBuilder: (context, index) {
            final restaurant = rowItems[index];
            return SizedBox(
              width: cardWidth,
              child: RestaurantCard(restaurant: restaurant),
            );
          },
        ),
      );
    }

    return Column(
      children: [
        buildRow(rows[0]),
        SizedBox(height: 12.h),
        buildRow(rows[1]),
        SizedBox(height: 12.h),
        buildRow(rows[2]),
      ],
    );
  }
}

class _MarketProductCategoriesSection extends StatefulWidget {
  final List<RestaurantCategoryEntity> restaurantCategories;
  final Function(String, bool) onCategoryTap; // categoryName, isMarket

  const _MarketProductCategoriesSection({
    required this.restaurantCategories,
    required this.onCategoryTap,
  });

  @override
  State<_MarketProductCategoriesSection> createState() =>
      _MarketProductCategoriesSectionState();
}

class _MarketProductCategoriesSectionState
    extends State<_MarketProductCategoriesSection> {
  late List<RestaurantCategoryEntity> _randomCategories;

  @override
  void initState() {
    super.initState();
    _pickRandomCategories();
  }

  @override
  void didUpdateWidget(_MarketProductCategoriesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.restaurantCategories != oldWidget.restaurantCategories) {
      _pickRandomCategories();
    }
  }

  void _pickRandomCategories() {
    if (widget.restaurantCategories.isEmpty) {
      _randomCategories = [];
      return;
    }
    final available = List<RestaurantCategoryEntity>.from(
      widget.restaurantCategories,
    );
    available.shuffle();
    _randomCategories = available.take(4).toList();
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String? imageUrl,
    String? assetPath,
    String title,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Colors.black.withOpacity(0.04)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: assetPath != null
                  ? Image.asset(
                      assetPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.category_rounded,
                        size: 20.w,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : (imageUrl != null && imageUrl.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.category_rounded,
                        size: 20.w,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : Icon(
                      Icons.category_rounded,
                      size: 20.w,
                      color: AppColors.textSecondary,
                    ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveHelper.fontSize(12),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final List<Map<String, dynamic>> displayItems = [
      {
        'asset': 'assets/images/market.jpeg',
        'title': l10n.market,
        'isMarket': true,
        'categoryName': null,
      },
      {
        'asset': 'assets/images/resturants.jpeg',
        'title': l10n.restaurants,
        'isMarket': false,
        'categoryName': null,
      },
    ];

    for (var cat in _randomCategories) {
      displayItems.add({
        'asset': null,
        'imageUrl': cat.imageUrl,
        'title': cat.name,
        'isMarket': false,
        'categoryName': cat.name,
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          isArabic ? "اكتشف " : "Discover Wassly",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontSize: ResponsiveHelper.fontSize(18),
          ),
        ),
        ResponsiveHelper.spacing(height: 12),
        // Horizontal Scrollable Categories in 2 Rows
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First Row
              Row(
                children: List.generate((displayItems.length / 2).ceil(), (
                  index,
                ) {
                  final item = displayItems[index];
                  return Padding(
                    padding: EdgeInsetsDirectional.only(end: 12.w),
                    child: SizedBox(
                      width: 130.w,
                      height: 55.h,
                      child: _buildCategoryCard(
                        context,
                        item['imageUrl'] as String?,
                        item['asset'] as String?,
                        item['title'] as String,
                        () {
                          widget.onCategoryTap(
                            item['categoryName'] as String? ??
                                item['title'] as String,
                            item['isMarket'] as bool,
                          );
                        },
                      ),
                    ),
                  );
                }),
              ),
              ResponsiveHelper.spacing(height: 12),
              // Second Row
              Row(
                children: List.generate(displayItems.length ~/ 2, (index) {
                  final item =
                      displayItems[index + (displayItems.length / 2).ceil()];
                  return Padding(
                    padding: EdgeInsetsDirectional.only(end: 12.w),
                    child: SizedBox(
                      width: 130.w,
                      height: 55.h,
                      child: _buildCategoryCard(
                        context,
                        item['imageUrl'] as String?,
                        item['asset'] as String?,
                        item['title'] as String,
                        () {
                          widget.onCategoryTap(
                            item['categoryName'] as String? ??
                                item['title'] as String,
                            item['isMarket'] as bool,
                          );
                        },
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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
    // Responsive banner height
    final double bannerHeight = 130.h;

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
                fontSize: ResponsiveHelper.fontSize(16),
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
                    fontSize: ResponsiveHelper.fontSize(14),
                  ),
                ),
              ),
          ],
        ),
        ResponsiveHelper.spacing(height: 12),
        // Banner Carousel
        CarouselSlider(
          options: CarouselOptions(
            height: bannerHeight + 65.h, // Add space for text below
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
                      if (restaurant.discountTargetProductId != null &&
                          restaurant.discountTargetProductId!.isNotEmpty) {
                        // Navigate to specific product within restaurant
                        // Assuming route is /restaurant/:id/product/:productId
                        // Or just /restaurant/:id and maybe pass extra to highlight/scroll to product
                        // For now, let's assume we can navigate to product details directly or open restaurant with product highlighted
                        // If route doesn't exist, we fallback to restaurant detail
                        // Since I don't know if product detail route exists nested,
                        // I will assume passing query parameter 'productId' to restaurant page is enough for now,
                        // or find if there is a product detail route.
                        // I'll push to restaurant details with extra product ID.
                        context.push(
                          '/restaurant/${restaurant.id}?productId=${restaurant.discountTargetProductId}',
                          extra: restaurant.discountTargetProductId,
                        );
                      } else {
                        context.push('/restaurant/${restaurant.id}');
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20.r),
                          child: SizedBox(
                            width: double.infinity,
                            height: bannerHeight,
                            // Clean banner: Use discount image if available, else restaurant image
                            child:
                                (restaurant.discountImageUrl != null &&
                                    restaurant.discountImageUrl!.isNotEmpty)
                                ? CachedNetworkImage(
                                    imageUrl: restaurant.discountImageUrl!,
                                    width: double.infinity,
                                    height: bannerHeight,
                                    fit: BoxFit.cover,
                                    placeholder: (c, u) => Container(
                                      color: AppColors.surface,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (c, u, e) =>
                                        const Icon(Icons.error),
                                  )
                                : (restaurant.imageUrl != null &&
                                      restaurant.imageUrl!.isNotEmpty)
                                ? CachedNetworkImage(
                                    imageUrl: restaurant.imageUrl!,
                                    width: double.infinity,
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
                          ),
                        ),
                        // Restaurant Info Below Banner
                        Padding(
                          padding: ResponsiveHelper.padding(
                            horizontal: 4,
                            top: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      restaurant.name,
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper.fontSize(14),
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 14.sp,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    restaurant.rating.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: ResponsiveHelper.fontSize(12),
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_shipping_outlined,
                                    size: 14.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${restaurant.deliveryFee.toStringAsFixed(0)} ${l10n.currencySymbol}',
                                    style: TextStyle(
                                      fontSize: ResponsiveHelper.fontSize(12),
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Icon(
                                    Icons.timer_outlined,
                                    size: 14.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${restaurant.estimatedDeliveryTime} ${l10n.minutesAbbreviation}',
                                    style: TextStyle(
                                      fontSize: ResponsiveHelper.fontSize(12),
                                      color: AppColors.textSecondary,
                                    ),
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
              },
            );
          }).toList(),
        ),
        // Indicators
        if (restaurants.length > 1) ...[
          ResponsiveHelper.spacing(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              restaurants.length,
              (index) => Container(
                width: currentIndex == index ? 24.w : 8.w,
                height: 8.h,
                margin: ResponsiveHelper.margin(horizontal: 4),
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? AppColors.primary
                      : AppColors.textHint,
                  borderRadius: BorderRadius.circular(4.r),
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
        padding: ResponsiveHelper.padding(all: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: ResponsiveHelper.padding(all: 24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: ResponsiveHelper.iconSize(64),
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
            ResponsiveHelper.spacing(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontSize: ResponsiveHelper.fontSize(16),
              ),
            ),
            ResponsiveHelper.spacing(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontSize: ResponsiveHelper.fontSize(14),
              ),
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
          padding: ResponsiveHelper.padding(horizontal: 16, top: 8, bottom: 12),
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
                      padding: ResponsiveHelper.padding(bottom: 12),
                      child: Row(
                        children: [
                          // Headphone Icon
                          Icon(
                            Icons.headset_mic,
                            color: Colors.white,
                            size: ResponsiveHelper.iconSize(20),
                          ),
                          ResponsiveHelper.spacing(width: 12),
                          // Delivery Text
                          Expanded(
                            child: AutoSizeText(
                              displayText,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: ResponsiveHelper.fontSize(12),
                              ),
                              maxLines: 1,
                              minFontSize: 12,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Chevron Icon
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: ResponsiveHelper.iconSize(20),
                          ),
                          const Spacer(),
                          // Ramadan Animated Decoration
                          SizedBox(
                            width: 30.w,
                            height: 30.h,
                            child: Lottie.network(
                              'https://lottie.host/802ecbad-b977-4f10-994c-53538a167735/H3uC39C9C9.json',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Text(
                                    '🌙',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                );
                              },
                            ),
                          ),
                          const Text('✨', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Search Field - Full Width
              Container(
                height: 36.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8.r,
                      offset: Offset(0, 2.h),
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
                        fontSize: ResponsiveHelper.fontSize(12),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                        size: ResponsiveHelper.iconSize(20),
                      ),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: AppColors.textSecondary,
                                size: ResponsiveHelper.iconSize(20),
                              ),
                              onPressed: () {
                                searchController.clear();
                                setState(() {});
                                onSearchChanged();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: ResponsiveHelper.padding(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      isDense: true,
                    ),
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: ResponsiveHelper.fontSize(12),
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
