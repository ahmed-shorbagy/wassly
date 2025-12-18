import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/market_product_categories.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/product_card.dart';
import '../cubits/market_product_customer_cubit.dart';

class MarketProductsScreen extends StatefulWidget {
  const MarketProductsScreen({super.key});

  @override
  State<MarketProductsScreen> createState() => _MarketProductsScreenState();
}

class _MarketProductsScreenState extends State<MarketProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _categories = [];
  String? _selectedCategory;
  String? _selectedSubCategory;
  List<dynamic> _allProducts = [];
  List<dynamic> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProducts);
    // Load products when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MarketProductCustomerCubit>().loadMarketProducts();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if category was passed from home page navigation via query parameter
    final router = GoRouter.of(context);
    final location = router.routeInformationProvider.value.uri;
    final categoryParam = location.queryParameters['category'];
    if (categoryParam != null && categoryParam.isNotEmpty && _selectedCategory != categoryParam) {
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

    // Filter by subcategory if selected
    if (_selectedSubCategory != null) {
      filtered = filtered.where((product) {
        final nameMatch = product.name.toLowerCase().contains(_selectedSubCategory!.toLowerCase());
        final descMatch = product.description.toLowerCase().contains(_selectedSubCategory!.toLowerCase());
        final categoryMatch = product.category?.toLowerCase().contains(_selectedSubCategory!.toLowerCase()) ?? false;
        return nameMatch || descMatch || categoryMatch;
      }).toList();
    }

    // Filter by search query
    final searchQuery = _searchController.text.toLowerCase().trim();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        final nameMatch = product.name.toLowerCase().contains(searchQuery);
        final descMatch = product.description.toLowerCase().contains(searchQuery);
        return nameMatch || descMatch;
      }).toList();
    }

    _filteredProducts = filtered;
  }

  List<String> _getSubCategories(AppLocalizations l10n) {
    // Return subcategories based on selected main category
    if (_selectedCategory == null) return [];
    
    // Return all subcategories for market products
    return [
      l10n.dairyProducts,
      l10n.cheese,
      l10n.eggs,
      l10n.softDrinks,
      l10n.water,
      l10n.juices,
      l10n.pastaAndRice,
      l10n.chipsAndSnacks,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            floating: false,
            backgroundColor: AppColors.primary,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                l10n.marketProducts,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
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
                      color: Colors.black.withValues(alpha: 0.05),
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

          // Categories Filter - Using predefined categories
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: MarketProductCategories.getCategories(l10n).length + 1, // +1 for "All"
                  itemBuilder: (context, index) {
                    final isAll = index == 0;
                    final categories = MarketProductCategories.getCategories(l10n);
                    final category = isAll ? null : categories[index - 1];
                    final isSelected = isAll
                        ? _selectedCategory == null
                        : _selectedCategory == category;

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: FilterChip(
                        label: Text(isAll ? l10n.all : category!),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = isAll ? null : category;
                            _selectedSubCategory = null; // Reset subcategory when main category changes
                            _applyFilters();
                          });
                        },
                        selectedColor: AppColors.primary,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Subcategories Filter - Show when a main category is selected
          if (_selectedCategory != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.topCategories,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _getSubCategories(l10n).length,
                        itemBuilder: (context, index) {
                          final subCategory = _getSubCategories(l10n)[index];
                          final isSelected = _selectedSubCategory == subCategory;

                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: FilterChip(
                              label: Text(subCategory),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedSubCategory = selected ? subCategory : null;
                                  _applyFilters();
                                });
                              },
                              selectedColor: AppColors.success,
                              checkmarkColor: Colors.white,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Products Grid
          BlocConsumer<MarketProductCustomerCubit, MarketProductCustomerState>(
            listener: (context, state) {
              if (state is MarketProductCustomerLoaded) {
                setState(() {
                  _allProducts = state.products;
                  _applyFilters();
                  // Extract categories for filter
                  _categories = state.products
                      .where((p) =>
                          p.category != null && p.category!.isNotEmpty)
                      .map((p) => p.category!)
                      .toSet()
                      .toList();
                  _categories.sort();
                });
              }
            },
            builder: (context, state) {
              if (state is MarketProductCustomerLoading) {
                return const SliverFillRemaining(
                  child: LoadingWidget(),
                );
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
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isNotEmpty ||
                                    _selectedCategory != null
                                ? l10n.noProductsFound
                                : l10n.noMarketProducts,
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
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68, // Reduced to give more vertical space for content
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
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
                      },
                      childCount: _filteredProducts.length,
                    ),
                  ),
                );
              }

              return const SliverFillRemaining(
                child: LoadingWidget(),
              );
            },
          ),
        ],
      ),
    );
  }
}

