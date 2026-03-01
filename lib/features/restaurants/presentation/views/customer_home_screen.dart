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

import '../../../../core/utils/search_helper.dart';
import '../../../../core/utils/category_image_helper.dart';
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
    final homeState = context.read<HomeCubit>().state;
    final categories = homeState is HomeLoaded ? homeState.categories : [];

    // Identify hidden categories (Markets)
    final marketCategoryIds = categories
        .where((c) => c.isMarket)
        .map((c) => c.id)
        .toSet();

    // Base filter: Exclude markets
    final baseRestaurants = _allRestaurants.where((restaurant) {
      // If restaurant has ANY category that is a market category, exclude it
      final isMarket = restaurant.categoryIds.any(
        (id) => marketCategoryIds.contains(id),
      );
      return !isMarket;
    }).toList();

    if (query.isEmpty) {
      setState(() {
        _filteredRestaurants = baseRestaurants;
      });
      return;
    }

    setState(() {
      _filteredRestaurants = SearchHelper.filterList(
        items: baseRestaurants, // Search only within non-market restaurants
        query: query,
        getSearchStrings: (restaurant) {
          // Resolve category names from IDs to allow searching by category name
          final categoryNames = restaurant.categoryIds.map((cid) {
            final category = categories.where((c) => c.id == cid).firstOrNull;
            return category?.name ?? cid;
          }).toList();

          return [
            restaurant.name,
            restaurant.description,
            restaurant.address,
            ...categoryNames,
          ];
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
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
        .where(
          (r) =>
              r.isDiscountActive &&
              r.discountImageUrl != null &&
              r.discountImageUrl!.isNotEmpty,
        )
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
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            toolbarHeight: 130.h, // Further reduced for a tighter fit
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
                child: Column(
                  children: [
                    _SectionHeader(
                      title: l10n.specialOffers,
                      accentColor: AppColors.accentFood,
                    ),
                    _BannerCarousel(
                      banners: banners,
                      onPageChanged: (index) {
                        setState(() {
                          _currentBannerIndex = index;
                        });
                      },
                      currentIndex: _currentBannerIndex,
                    ),
                  ],
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
                    _SectionHeader(
                      title: l10n.exploreOurRichWorld,
                      accentColor: AppColors.primary,
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
                child: Column(
                  children: [
                    _SectionHeader(
                      title: l10n.discoverWassly,
                      accentColor: AppColors.accentMarket,
                    ),
                    _MarketProductCategoriesSection(
                      restaurantCategories: categories,
                      onCategoryTap: (category, isMarket) {
                        if (isMarket) {
                          // Navigate to Markets (Vendors)
                          if (category == l10n.market) {
                            // Navigate to "Our Market" page (Market Products)
                            context.push('/market-products');
                          } else {
                            // Show vendors for specific market category
                            // Pass filterType=market to hide restaurant top categories
                            context.push(
                              '/search?q=${Uri.encodeComponent(category)}&filterType=market',
                              extra: _allRestaurants,
                            );
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
                  ],
                ),
              );
            },
          ),

          // Discounted Restaurants Banner (in Market Section)
          if (discountedRestaurants.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: ResponsiveHelper.padding(
                  horizontal:
                      0, // Removed horizontal padding for fractional viewport peek
                  top: 12, // Reduced from 24
                  bottom: 4, // Reduced from 8
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

          // --- START SEGMENTED RESTAURANTS ---
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
          else ...[
            // 1. Top Rated Brands
            _HorizontalRestaurantList(
              restaurants: restaurants.where((r) => r.rating >= 4.0).toList()
                ..sort((a, b) => b.totalReviews.compareTo(a.totalReviews)),
              title: l10n.topRatedBrands,
              accentColor: Colors.amber,
              onViewAll: () =>
                  context.push('/search?q=', extra: _allRestaurants),
            ),

            // 2. New & Trending
            _HorizontalRestaurantList(
              restaurants: restaurants.toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
              title: l10n.newOnWassly,
              accentColor: AppColors.primary,
              onViewAll: () =>
                  context.push('/search?q=', extra: _allRestaurants),
            ),

            // 3. Nearby Favorites (Now Horizontal)
            _HorizontalRestaurantList(
              restaurants: restaurants,
              title: l10n.nearbyFavorites,
              onViewAll: () =>
                  context.push('/search?q=', extra: _allRestaurants),
            ),
          ],
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
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
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

// Standalone Section Header widget for reuse
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  final Color accentColor;

  const _SectionHeader({
    required this.title,
    this.onViewAll,
    this.accentColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ResponsiveHelper.padding(
        horizontal: 16,
        vertical: 4,
      ), // Reduced from 8
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  fontSize: 18.sp,
                  letterSpacing: -0.6,
                ),
              ),
            ],
          ),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                AppLocalizations.of(context)!.viewAll,
                style: TextStyle(
                  color: accentColor == AppColors.primary
                      ? AppColors.primaryDark
                      : accentColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HorizontalRestaurantList extends StatelessWidget {
  final List<RestaurantEntity> restaurants;
  final String title;
  final VoidCallback? onViewAll;
  final Color accentColor;

  const _HorizontalRestaurantList({
    required this.restaurants,
    required this.title,
    this.onViewAll,
    this.accentColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    if (restaurants.isEmpty)
      return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: title,
            onViewAll: onViewAll,
            accentColor: accentColor,
          ),
          SizedBox(
            height: 130.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: ResponsiveHelper.padding(horizontal: 16),
              itemCount: restaurants.length > 8 ? 8 : restaurants.length,
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: RestaurantCard(restaurant: restaurants[index]),
                );
              },
            ),
          ),
          ResponsiveHelper.spacing(height: 16),
        ],
      ),
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
      padding: ResponsiveHelper.padding(
        horizontal:
            0, // Removed horizontal padding for fractional viewport peek
        top: 4,
        bottom: 0,
      ), // Reduced from 16
      child: CarouselSlider(
        options: CarouselOptions(
          height: bannerHeight + 24.h, // Space for shadows
          viewportFraction: 0.82, // Reduced for fractional peek
          enlargeCenterPage: true,
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
                margin: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 12.h,
                ), // Reduced margin for cleaner peek
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: GestureDetector(
                    onTap: () {
                      if (b.deepLink != null && b.deepLink!.isNotEmpty) {
                        try {
                          context.push(b.deepLink!);
                        } catch (e) {
                          // Ignore or log bad deep links
                        }
                      }
                    },
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
    final double cardHeight = 130.h;

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
  // Fixed items
  late final List<Map<String, dynamic>> _fixedItems;

  @override
  void initState() {
    super.initState();
    _fixedItems = [
      {
        'asset': 'assets/images/market.jpeg',
        'title': 'Market', // Will be localized in build
        'isMarket': true,
        'categoryName': null,
      },
      {
        'asset': 'assets/images/resturants.jpeg',
        'title': 'Restaurants', // Will be localized in build
        'isMarket': false,
        'categoryName': null,
      },
    ];
  }

  Color _getCategoryColor(String title) {
    final t = title.toLowerCase();
    if (t.contains('food') || t.contains('restaurant') || t.contains('مطعم')) {
      return AppColors.accentFood;
    }
    if (t.contains('market') || t.contains('grocery') || t.contains('سوبر')) {
      return AppColors.accentMarket;
    }
    if (t.contains('health') ||
        t.contains('pharmacy') ||
        t.contains('صيدلية')) {
      return AppColors.accentHealth;
    }
    if (t.contains('bakery') || t.contains('bread') || t.contains('مخبز')) {
      return AppColors.accentBakery;
    }
    if (t.contains('coffee') || t.contains('cafe') || t.contains('قهوة')) {
      return AppColors.accentCoffee;
    }
    if (t.contains('flower') || t.contains('gift') || t.contains('ورد')) {
      return AppColors.accentFlowers;
    }
    return AppColors.primary;
  }

  Widget _buildCategoryBox(
    BuildContext context,
    String? imageUrl,
    String? assetPath,
    String title,
    VoidCallback onTap,
  ) {
    final accentColor = _getCategoryColor(title);
    final isFood = title.contains('مطعم') || title.contains('أكل');
    final isMarket = title.contains('ماركت') || title.contains('سوبر');
    final isVeg = title.contains('خضروات') || title.contains('فواكه');

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 95.w,
            height: 105.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.antiAlias,
              children: [
                // 1. Bottom Wavy/Blob Background
                Positioned(
                  bottom: -20,
                  left: -10,
                  right: -10,
                  child: Container(
                    height: 70.h,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.all(
                        Radius.elliptical(100, 60),
                      ),
                    ),
                  ),
                ),

                // 2. Decorative Icons (Stars/Moons)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Opacity(
                    opacity: 0.6,
                    child: Icon(
                      Icons.auto_awesome,
                      size: 10.w,
                      color: accentColor,
                    ),
                  ),
                ),
                Positioned(
                  top: 15,
                  left: 18,
                  child: Opacity(
                    opacity: 0.4,
                    child: Icon(Icons.star, size: 8.w, color: accentColor),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 12,
                  child: Opacity(
                    opacity: 0.8,
                    child: Icon(
                      Icons.dark_mode,
                      size: 14.w,
                      color: accentColor,
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 4,
                  child: Opacity(
                    opacity: 0.5,
                    child: Icon(Icons.star, size: 6.w, color: accentColor),
                  ),
                ),

                // 3. Hero Image (Centered & Overlapping)
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 5.h),
                    child: assetPath != null
                        ? Image.asset(assetPath, fit: BoxFit.contain)
                        : (imageUrl != null && imageUrl.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.contain,
                            placeholder: (c, u) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (c, u, e) => Image.asset(
                              CategoryImageHelper.getDefaultAsset(),
                              fit: BoxFit.contain,
                            ),
                          )
                        : Image.asset(
                            CategoryImageHelper.getDefaultAsset(),
                            fit: BoxFit.contain,
                          ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          // Label with Emoji matching reference style
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isVeg) Text('🥗 ', style: TextStyle(fontSize: 14.sp)),
              if (isFood) Text('🔥 ', style: TextStyle(fontSize: 14.sp)),
              if (isMarket) Text('🛍️ ', style: TextStyle(fontSize: 14.sp)),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    height: 1.1,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Prepare display items: Fixed + Market Categories
    final List<Map<String, dynamic>> displayItems = [];

    // 1. Fixed Main Chips
    displayItems.add({..._fixedItems[0], 'title': l10n.market});
    displayItems.add({..._fixedItems[1], 'title': l10n.restaurants});

    // 2. Fixed Category Chips (Requested)
    displayItems.add({
      'asset': 'assets/images/pharamcies.jpeg',
      'title': l10n.pharmacy,
      'isMarket': true,
      'categoryName': 'Pharmacies',
      'isSpecificCategory': true,
    });
    displayItems.add({
      'asset': 'assets/images/fruits&veg.jpeg',
      'title': l10n.vegetablesAndFruits,
      'isMarket': true,
      'categoryName': 'Vegetables & Fruits',
      'isSpecificCategory': true,
    });
    displayItems.add({
      'asset': 'assets/images/cake&cofee.jpeg',
      'title': l10n.cakeAndCoffee,
      'isMarket': true,
      'categoryName': 'Cake & Coffee',
      'isSpecificCategory': true,
    });

    // Add Dynamic Market Categories (e.g. Pharmacy, Vegetable Shop)
    // Filter categories where isMarket == true
    final marketCategories = widget.restaurantCategories
        .where((c) => c.isMarket)
        .toList();

    // Sort by display order or name if desired
    marketCategories.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    // Track seen titles to prevent duplicates (e.g. if DB has duplicate categories or matches fixed items)
    final Set<String> seenTitles = {
      l10n.market,
      l10n.restaurants,
      l10n.pharmacy,
      l10n.vegetablesAndFruits,
      l10n.cakeAndCoffee,
    };

    for (var cat in marketCategories) {
      String displayName = cat.name;

      // Normalize and localize known legacy English names if we are in Arabic mode (or generally)
      // This helps deduplicate "Pharmacies" vs "الصيدليه" by converting them to the same localized string
      final lowerName = cat.name.toLowerCase().trim();

      if (lowerName.contains('pharmacy') || lowerName.contains('pharmacies')) {
        displayName = l10n.pharmacy;
      } else if (lowerName.contains('vegetable') ||
          lowerName == 'fruits and vegetables') {
        displayName = l10n.vegetablesAndFruits;
      } else if (lowerName.contains('cake') && lowerName.contains('coffee')) {
        displayName = l10n.cakeAndCoffee;
      }

      // specialized check: filter out if name is same as existing ones
      if (seenTitles.contains(displayName)) continue;
      seenTitles.add(displayName);

      displayItems.add({
        'asset': CategoryImageHelper.getAssetForCategory(cat.name),
        'imageUrl': cat.imageUrl,
        'title': displayName,
        'isMarket': true, // Use market flow
        'categoryName':
            cat.name, // To filter by category - keep ORIGINAL name for querying
        'isSpecificCategory': true, // Flag to indicate specific category search
      });
    }

    return Container(
      color: const Color(0xFFFFF2E6).withValues(alpha: 0.5), // Warm Peach theme
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(displayItems.length, (index) {
                final item = displayItems[index];

                return Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: _buildCategoryBox(
                    context,
                    item['imageUrl'] as String?,
                    item['asset'] as String?,
                    item['title'] as String,
                    () {
                      if (item['isMarket'] == true) {
                        widget.onCategoryTap(
                          item['categoryName'] as String? ??
                              item['title'] as String,
                          true,
                        );
                      } else {
                        widget.onCategoryTap(
                          item['categoryName'] as String? ??
                              item['title'] as String,
                          false,
                        );
                      }
                    },
                  ),
                );
              }),
            ),
          ),
        ],
      ),
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
        _SectionHeader(
          title: l10n.specialOffers,
          accentColor: AppColors.accentFood,
          onViewAll: restaurants.length > 1 ? () {} : null,
        ),
        ResponsiveHelper.spacing(height: 12),
        // Banner Carousel
        CarouselSlider(
          options: CarouselOptions(
            height: bannerHeight + 65.h, // Add space for text below
            viewportFraction: 0.85, // Reduced for fractional peek
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
                  margin: EdgeInsets.symmetric(
                    horizontal: 4.w,
                  ), // Added .w for consistency
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
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: currentIndex == index ? 20.w : 6.w,
                height: 6.h,
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? AppColors.primary
                      : AppColors.textHint.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(3.r),
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: ResponsiveHelper.padding(
            horizontal: 16,
            top: 4,
            bottom: 4,
          ), // Tightened Further
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
                      context.push('/address-book');
                    },
                    child: Padding(
                      padding: ResponsiveHelper.padding(
                        bottom: 8,
                      ), // Reduced from 16
                      child: Row(
                        children: [
                          // Location Icon (Light Grey background)
                          Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_on_rounded,
                              color: AppColors.primary,
                              size: ResponsiveHelper.iconSize(20),
                            ),
                          ),
                          SizedBox(width: 12.w),

                          // Address Text Column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      l10n.deliverTo,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: ResponsiveHelper.fontSize(12),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.primary,
                                      size: ResponsiveHelper.iconSize(16),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  displayText,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: ResponsiveHelper.fontSize(14),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // Actions
                          Row(
                            children: [
                              // Notification Bell
                              Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.notifications_none_rounded,
                                  color: AppColors.textPrimary,
                                  size: ResponsiveHelper.iconSize(20),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              // Cart
                              InkWell(
                                onTap: () => context.pushNamed('cart'),
                                child: Container(
                                  padding: EdgeInsets.all(8.r),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.shopping_cart_outlined,
                                    color: AppColors.textPrimary,
                                    size: ResponsiveHelper.iconSize(20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Search Field - Light Grey Fill
              Container(
                height: 48.h,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    onSearchChanged();
                    if (value.isNotEmpty && onSearchTap != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (context.mounted) {
                          context.push(
                            '/search?q=${Uri.encodeComponent(value)}',
                            extra: restaurants,
                          );
                        }
                      });
                    }
                  },
                  onTap: onSearchTap,
                  readOnly: onSearchTap != null,
                  decoration: InputDecoration(
                    hintText: l10n.searchRestaurants,
                    hintStyle: TextStyle(
                      color: AppColors.textHint,
                      fontSize: ResponsiveHelper.fontSize(14),
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondary,
                      size: ResponsiveHelper.iconSize(24),
                    ),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              size: ResponsiveHelper.iconSize(20),
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              searchController.clear();
                              onSearchChanged();
                            },
                          )
                        : Container(
                            margin: EdgeInsets.all(8.r),
                            padding: EdgeInsets.all(6.r),
                            child: Icon(
                              Icons.tune_rounded, // Filter icon hint
                              color: AppColors.primary,
                              size: ResponsiveHelper.iconSize(20),
                            ),
                          ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    isDense: true,
                  ),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: ResponsiveHelper.fontSize(14),
                    fontWeight: FontWeight.w500,
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
