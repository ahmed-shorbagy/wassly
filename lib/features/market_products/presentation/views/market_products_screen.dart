import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/market_product_categories.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/product_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../home/presentation/cubits/home_cubit.dart';
import '../../../home/domain/entities/banner_entity.dart';
import '../cubits/market_product_customer_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MarketProductsScreen extends StatefulWidget {
  final String? restaurantId;
  final String? restaurantName;

  const MarketProductsScreen({
    super.key,
    this.restaurantId,
    this.restaurantName,
  });

  @override
  State<MarketProductsScreen> createState() => _MarketProductsScreenState();
}

class _MarketProductsScreenState extends State<MarketProductsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String? _selectedCategory;

  List<dynamic> _allProducts = [];
  List<dynamic> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProducts);
    // Load products when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MarketProductCustomerCubit>().loadMarketProducts(
          restaurantId: widget.restaurantId,
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if category was passed from home page navigation (if applicable)
    final router = GoRouter.of(context);
    final location = router.routeInformationProvider.value.uri;
    final categoryParam = location.queryParameters['category'];
    if (categoryParam != null &&
        categoryParam.isNotEmpty &&
        _selectedCategory != categoryParam) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedCategory = categoryParam;
            if (_allProducts.isNotEmpty) {
              _applyFilters();
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts() {
    setState(() {
      _applyFilters();
    });
  }

  void _applyFilters() {
    var filtered = List.from(_allProducts);

    // Filter by category
    if (_selectedCategory != null) {
      filtered = filtered
          .where((product) => product.category == _selectedCategory)
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

    _filteredProducts = filtered;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = MarketProductCategories.getCategories(l10n);

    // If typing in search, treat as "filtering products" regardless of category view?
    // Let's stick to the requested design: Category Grid First.
    final bool showProductList =
        _selectedCategory != null || _searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 80,
            pinned: true,
            floating: false,
            backgroundColor: AppColors.primary,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                if (_selectedCategory != null) {
                  setState(() {
                    _selectedCategory = null;

                    _searchController.clear();
                    _applyFilters();
                  });
                } else {
                  context.pop();
                }
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.restaurantName ??
                    (_selectedCategory != null
                        ? MarketProductCategories.getCategoryName(
                            _selectedCategory!,
                            l10n,
                          )
                        : l10n.market),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              centerTitle: true,
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
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

          // Market Banners Carousel
          if (_selectedCategory == null && _searchController.text.isEmpty)
            SliverToBoxAdapter(
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoaded && state.banners.isNotEmpty) {
                    final marketBanners = state.banners
                        .where((b) => b.type == 'market')
                        .toList();

                    // If no market banners, show a high-quality placeholder for testing
                    final effectiveBanners = marketBanners.isEmpty
                        ? [
                            BannerEntity(
                              id: 'placeholder_market',
                              type: 'market',
                              imageUrl:
                                  'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=1200', // Fresh Grocery Market image
                              title: l10n.market,
                            ),
                          ]
                        : marketBanners;

                    return Padding(
                      padding: ResponsiveHelper.padding(top: 16, bottom: 8),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: 200.h,
                          viewportFraction: 0.95,
                          enlargeCenterPage: true,
                          enableInfiniteScroll: effectiveBanners.length > 1,
                          autoPlay: effectiveBanners.length > 1,
                          autoPlayInterval: const Duration(seconds: 4),
                          autoPlayAnimationDuration: const Duration(
                            milliseconds: 800,
                          ),
                          autoPlayCurve: Curves.fastOutSlowIn,
                        ),
                        items: effectiveBanners.map((banner) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: CachedNetworkImage(
                                    imageUrl: banner.imageUrl,
                                    width: double.infinity,
                                    height: 200.h,
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
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    );
                  }
                  return const SizedBox.shrink(); // Hide if loading or error for now
                },
              ),
            ),

          // 1. If NO Category Selected and NO Search -> Show Categories Grid
          if (!showProductList) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  l10n.shopByCategory,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1
                    Row(
                      children: List.generate((categories.length / 3).ceil(), (
                        index,
                      ) {
                        final category = categories[index];
                        return _buildMarketCategoryCard(
                          context,
                          category,
                          l10n,
                        );
                      }),
                    ),
                    SizedBox(height: 10.h),
                    // Row 2
                    Row(
                      children: List.generate((categories.length / 3).ceil(), (
                        index,
                      ) {
                        final actualIndex =
                            index + (categories.length / 3).ceil();
                        if (actualIndex >= categories.length)
                          return const SizedBox.shrink();
                        final category = categories[actualIndex];
                        return _buildMarketCategoryCard(
                          context,
                          category,
                          l10n,
                        );
                      }),
                    ),
                    SizedBox(height: 10.h),
                    // Row 3
                    Row(
                      children: List.generate(
                        categories.length - 2 * (categories.length / 3).ceil(),
                        (index) {
                          final actualIndex =
                              index + 2 * (categories.length / 3).ceil();
                          if (actualIndex >= categories.length)
                            return const SizedBox.shrink();
                          final category = categories[actualIndex];
                          return _buildMarketCategoryCard(
                            context,
                            category,
                            l10n,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Optional: Banner or other sections below
            _buildMostSoldSection(context, l10n),
          ],

          // 2. If Category Selected or Search -> Show Products Grid (Existing Design)
          if (showProductList) ...[
            BlocConsumer<
              MarketProductCustomerCubit,
              MarketProductCustomerState
            >(
              listener: (context, state) {
                if (state is MarketProductCustomerLoaded) {
                  setState(() {
                    _allProducts = state.products;
                    _applyFilters();
                    // Extract categories logic if needed, but we use static categories now
                  });
                }
              },
              builder: (context, state) {
                if (state is MarketProductCustomerLoading) {
                  return const SliverFillRemaining(child: LoadingWidget());
                }

                if (state is MarketProductCustomerError) {
                  return SliverFillRemaining(
                    child: ErrorDisplayWidget(
                      message: state.message,
                      onRetry: () {
                        context
                            .read<MarketProductCustomerCubit>()
                            .loadMarketProducts();
                      },
                    ),
                  );
                }

                if (state is MarketProductCustomerLoaded) {
                  if (_filteredProducts.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 80,
                              color: AppColors.textSecondary.withOpacity(0.5),
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
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final product = _filteredProducts[index];
                        return ProductCard(
                          productId: product.id,
                          productName: product.name,
                          description: product.description,
                          price: product.price,
                          imageUrl: product.imageUrl,
                          isAvailable: product.isAvailable,
                          isMarketProduct: true,
                        );
                      }, childCount: _filteredProducts.length),
                    ),
                  );
                }

                return const SliverFillRemaining(child: LoadingWidget());
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMarketCategoryCard(
    BuildContext context,
    String category,
    AppLocalizations l10n,
  ) {
    final imagePath = MarketProductCategories.getCategoryImageUrl(
      category,
      l10n,
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
          _applyFilters();
        });
      },
      child: Container(
        width: 90.w,
        margin: EdgeInsetsDirectional.only(end: 12.w),
        child: Column(
          children: [
            Container(
              height: 72.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.04),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(8.r),
                child: imagePath != null
                    ? Image.asset(imagePath, fit: BoxFit.contain)
                    : Icon(
                        Icons.category,
                        color: AppColors.primary.withOpacity(0.5),
                        size: 30.w,
                      ),
              ),
            ),
            SizedBox(height: 6.h),
            SizedBox(
              height: 30.h,
              child: Center(
                child: Text(
                  MarketProductCategories.getCategoryName(category, l10n),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(9.5),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMostSoldSection(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<MarketProductCustomerCubit, MarketProductCustomerState>(
      builder: (context, state) {
        if (state is MarketProductCustomerLoaded && state.products.isNotEmpty) {
          // Select products to show in "Most Sold" section
          // For now, we take the first few products or randomize them
          // Since there's no sales count, this is a placeholder for the logic
          final mostSoldProducts = state.products.take(10).toList();

          return SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    l10n.mostSoldProducts,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 260.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: mostSoldProducts.length,
                    itemBuilder: (context, index) {
                      final product = mostSoldProducts[index];
                      return Container(
                        width: 160.w,
                        margin: EdgeInsetsDirectional.only(end: 16.w),
                        child: ProductCard(
                          productId: product.id,
                          productName: product.name,
                          description: product.description,
                          price: product.price,
                          imageUrl: product.imageUrl,
                          isAvailable: product.isAvailable,
                          isMarketProduct: true,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}
