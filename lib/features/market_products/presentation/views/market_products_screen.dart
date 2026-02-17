import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/market_product_categories.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/market_product_card.dart';
import '../../../../core/utils/search_helper.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:carousel_slider/carousel_slider.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../home/presentation/cubits/home_cubit.dart';
import '../../../home/domain/entities/banner_entity.dart';
import '../cubits/market_product_customer_cubit.dart';
import '../../domain/entities/market_product_entity.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../orders/presentation/cubits/cart_cubit.dart';
import '../../../restaurants/domain/entities/product_entity.dart';

class MarketProductsScreen extends StatefulWidget {
  final String? restaurantId;
  final String? restaurantName;
  final String? initialCategory;

  const MarketProductsScreen({
    super.key,
    this.restaurantId,
    this.restaurantName,
    this.initialCategory,
  });

  @override
  State<MarketProductsScreen> createState() => _MarketProductsScreenState();
}

class _MarketProductsScreenState extends State<MarketProductsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String? _selectedCategory;

  List<MarketProductEntity> _allProducts = [];
  List<MarketProductEntity> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProducts);

    // Initialize category from widget param if provided
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      _selectedCategory = widget.initialCategory;
    }

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
    List<MarketProductEntity> filtered = List.from(_allProducts);

    // Filter by category
    if (_selectedCategory != null) {
      filtered = filtered
          .where((product) => product.category == _selectedCategory)
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

    _filteredProducts = filtered;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Use static hardcoded categories as per new requirement
    final categories = MarketProductCategories.getCategories(l10n);

    // If typing in search, treat as "filtering products" regardless of category view?
    // Let's stick to the requested design: Category Grid First.
    final bool showProductList =
        _selectedCategory != null || _searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      // Wrap with BlocListener to always update _allProducts when products are loaded
      body: BlocListener<MarketProductCustomerCubit, MarketProductCustomerState>(
        listener: (context, state) {
          if (state is MarketProductCustomerLoaded) {
            setState(() {
              _allProducts = state.products;
              _applyFilters();
            });
          }
        },
        child: CustomScrollView(
          slivers: [
            // 1. Premium Market App Bar
            SliverAppBar(
              expandedHeight: 0,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              toolbarHeight: 130.h,
              automaticallyImplyLeading: false,
              flexibleSpace: _MarketAppBar(
                searchController: _searchController,
                onSearchChanged: _filterProducts,
                onBack: () {
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
                title:
                    widget.restaurantName ??
                    (_selectedCategory != null
                        ? MarketProductCategories.getCategoryName(
                            _selectedCategory!,
                            l10n,
                          )
                        : l10n.market),
                l10n: l10n,
              ),
            ),

            // Removed inline Search Bar as it's now in _MarketAppBar

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
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 12.h,
                                  ),
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

            // 2. Square Campaign Banners (Horizontal List)
            if (!showProductList)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 140.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildCampaignCard(
                            l10n.ramadanEssentials,
                            const Color(0xFFFFF9C4),
                            onTap: () {
                              _searchController.text = 'رمضان';
                              _applyFilters();
                            },
                          ),
                          _buildCampaignCard(
                            l10n.ramadanDrinks,
                            const Color(0xFFFFE082),
                            onTap: () {
                              _searchController.text = 'مشروب';
                              _applyFilters();
                            },
                          ),
                          _buildCampaignCard(
                            l10n.burningPrices,
                            const Color(0xFFFFCCBC),
                            onTap: () {
                              _searchController.text = 'عرض';
                              _applyFilters();
                            },
                          ),
                        ],
                      ),
                    ),
                    // Promotional Offer Wide Banner
                    _buildWidePromoBanner(
                      l10n,
                      onTap: () {
                        setState(() {
                          _searchController.text = '';
                          // In a real app, we might have an 'offers' flag or filter
                          // For now, let's treat it as a trigger to show all products if no offers flag exists
                          _applyFilters();
                        });
                      },
                    ),
                  ],
                ),
              ),

            // 3. Category Horizontal Scroller
            if (!showProductList)
              SliverPadding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 12.h,
                          top: 8.h,
                          left: 16.w,
                          right: 16.w,
                        ),
                        child: Text(
                          l10n.shopByCategory,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.fontSize(18),
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 235.h,
                        child: GridView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12.w,
                                crossAxisSpacing: 12.h,
                                childAspectRatio: 1.25,
                              ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            return _buildCategoryCard(
                              context,
                              categories[index],
                              l10n,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 1. If NO Category Selected and NO Search -> Show Most Sold
            if (!showProductList) ...[
              // Most Sold / Top Products Section
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
                          return MarketProductCard(
                            productId: product.id,
                            productName: product.name,
                            description: product.description,
                            price: product.price,
                            imageUrl: product.imageUrl,
                            isAvailable: product.isAvailable,
                            promotionalLabel: index < 3
                                ? 'إعلان'
                                : null, // Show ad label on first few
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
      ),
      bottomNavigationBar: _buildBottomInfoBar(context, l10n),
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
                _SectionHeader(title: l10n.mostSoldProducts),
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
                        child: MarketProductCard(
                          productId: product.id,
                          productName: product.name,
                          description: product.description,
                          price: product.price,
                          imageUrl: product.imageUrl,
                          isAvailable: product.isAvailable,
                          promotionalLabel:
                              l10n.mostSoldProducts, // Most sold label
                          onAddToCart: () async {
                            final productEntity = ProductEntity(
                              id: product.id,
                              name: product.name,
                              description: product.description,
                              price: product.price,
                              imageUrl: product.imageUrl,
                              isAvailable: product.isAvailable,
                              restaurantId: product.restaurantId ?? 'market',
                              createdAt: product.createdAt,
                            );
                            return await context.read<CartCubit>().addItem(
                              productEntity,
                              context: context,
                            );
                          },
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

  Widget _buildCampaignCard(
    String title,
    Color bgColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110.w,
        margin: EdgeInsetsDirectional.only(end: 12.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              // Decorative shapes for high-fidelity look
              Positioned(
                right: -10.w,
                top: -10.h,
                child: Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.fontSize(12),
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 6.h,
                right: 6.w,
                child: Icon(
                  Icons.redeem_rounded,
                  color: AppColors.textPrimary.withValues(alpha: 0.1),
                  size: 36.r,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWidePromoBanner(AppLocalizations l10n, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 80.h,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF5252), Color(0xFFFF8A65)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF5252).withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              // Large % icon on the right
              Positioned(
                right: -10.w,
                top: -5.h,
                bottom: -5.h,
                child: Text(
                  '%',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.2),
                    fontSize: 80.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.savingsOffers,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ResponsiveHelper.fontSize(20),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              l10n.saveUpTo('50'),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: ResponsiveHelper.fontSize(12),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.percent_rounded,
                        color: Colors.white,
                        size: 40.r,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String category,
    AppLocalizations l10n,
  ) {
    final categoryName = MarketProductCategories.getCategoryName(
      category,
      l10n,
    );
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
      child: SizedBox(
        width: 85.w,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 80.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7), // Polished light gray
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Stack(
                children: [
                  Center(
                    child: imagePath != null
                        ? Image.asset(
                            imagePath,
                            width: 50.w,
                            height: 50.w,
                            fit: BoxFit.contain,
                          )
                        : Icon(
                            Icons.category_outlined,
                            size: 35.w,
                            color: AppColors.primary,
                          ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              categoryName,
              style: TextStyle(
                fontSize: ResponsiveHelper.fontSize(10),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInfoBar(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.minOrderValue('20'),
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(13),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    l10n.freeDeliveryAbove('100'),
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(10),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF15BE77),
                    ),
                  ),
                ],
              ),
            ),
            BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                final cartCubit = context.read<CartCubit>();
                final itemCount = cartCubit.getItemCount();

                return GestureDetector(
                  onTap: () => context.push('/cart'),
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          color: AppColors.textPrimary,
                          size: 24.r,
                        ),
                        if (itemCount > 0)
                          Positioned(
                            top: -4.h,
                            right: -4.w,
                            child: Container(
                              padding: EdgeInsets.all(4.r),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFC107),
                                shape: BoxShape.circle,
                              ),
                              constraints: BoxConstraints(
                                minWidth: 16.w,
                                minHeight: 16.w,
                              ),
                              child: Center(
                                child: Text(
                                  itemCount.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ResponsiveHelper.padding(horizontal: 16, top: 20, bottom: 12),
      child: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            fontSize: ResponsiveHelper.fontSize(20),
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _MarketAppBar extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onSearchChanged;
  final VoidCallback onBack;
  final String title;
  final AppLocalizations l10n;

  const _MarketAppBar({
    required this.searchController,
    required this.onSearchChanged,
    required this.onBack,
    required this.title,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1FFF8), // Light mint tint from image
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Row: Back, Delivery, Logo
            Padding(
              padding: ResponsiveHelper.padding(
                horizontal: 16,
                top: 4,
                bottom: 8,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: const BoxDecoration(
                        color: Colors.white, // Better contrast on mint
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textPrimary,
                        size: ResponsiveHelper.iconSize(18),
                      ),
                    ),
                    onPressed: onBack,
                  ),
                  const Spacer(),
                  // Delivery Badge (Refined)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.deliveryWithin,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.fontSize(10),
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '15 ${l10n.minutes}',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.fontSize(12),
                            color: const Color(0xFF15BE77),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Icon(
                          Icons.flash_on_rounded,
                          color: const Color(0xFFFFC107),
                          size: ResponsiveHelper.iconSize(14),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                  // MARKET Logo Tag
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF15BE77),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'MARKET',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveHelper.fontSize(12),
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar Area (White Background)
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 4.h,
                bottom: 16.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32.r),
                  bottomRight: Radius.circular(32.r),
                ),
              ),
              child: Container(
                height: 48.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) => onSearchChanged(),
                  decoration: InputDecoration(
                    hintText: l10n.searchInMarket,
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
                        : null,
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
