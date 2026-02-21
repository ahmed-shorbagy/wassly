import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../cubits/restaurant_cubit.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../widgets/search_restaurant_card.dart';
import '../../../home/presentation/cubits/home_cubit.dart';
import '../../domain/entities/restaurant_category_entity.dart';
import '../../../../core/utils/search_helper.dart';

class SearchResultsScreen extends StatefulWidget {
  final String initialQuery;
  final List<RestaurantEntity>? initialRestaurants;
  final String? filterType;

  const SearchResultsScreen({
    super.key,
    this.initialQuery = '',
    this.initialRestaurants,
    this.filterType,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<RestaurantEntity> _allRestaurants = [];
  List<RestaurantEntity> _filteredRestaurants = [];
  List<RestaurantCategoryEntity> _availableCategories = [];
  String? _selectedCategoryName; // null means 'all'
  final String _sortBy = 'relevance';
  final bool _freeDeliveryOnly = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    // Initialize available categories if already loaded
    final homeState = context.read<HomeCubit>().state;
    if (homeState is HomeLoaded) {
      _availableCategories = homeState.categories;
    }

    // Determine the selected category from the initial query
    // If q matches a category name, we consider it a category filter
    if (widget.initialQuery.isNotEmpty) {
      final queryLower = widget.initialQuery.toLowerCase().trim();
      final matchingCategory = _availableCategories.where((c) {
        return c.name.toLowerCase().trim() == queryLower;
      }).firstOrNull;

      if (matchingCategory != null) {
        _selectedCategoryName = matchingCategory.name;
      }
    }

    // Initialize with provided restaurants or load all
    if (widget.initialRestaurants != null) {
      _allRestaurants = List.from(widget.initialRestaurants!);
      _filteredRestaurants = List.from(widget.initialRestaurants!);
      _applyFilters();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<RestaurantCubit>().getAllRestaurants();
        }
      });
    }

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      String query = _searchController.text.toLowerCase().trim();

      // Filter by search query using Smart Fuzzy Search
      var filtered = query.isEmpty
          ? List<RestaurantEntity>.from(_allRestaurants)
          : SearchHelper.filterList(
              items: _allRestaurants,
              query: query,
              getSearchStrings: (restaurant) {
                // Resolve category IDs to names for searching
                final categories = restaurant.categoryIds.map((cid) {
                  final category = _availableCategories
                      .where((c) => c.id == cid)
                      .firstOrNull;
                  return category?.name ?? cid;
                }).toList();

                return [
                  restaurant.name,
                  restaurant.description,
                  restaurant.address,
                  ...categories,
                ];
              },
            );

      // Further filter by UI criteria
      filtered = filtered.where((restaurant) {
        // Filter by category
        if (_selectedCategoryName != null) {
          final matchesCategory = restaurant.categoryIds.any((cid) {
            final category = _availableCategories
                .where((c) => c.id == cid)
                .firstOrNull;
            return category?.name.toLowerCase().trim() ==
                _selectedCategoryName?.toLowerCase().trim();
          });
          if (!matchesCategory) return false;
        }

        // Filter by free delivery
        if (_freeDeliveryOnly && restaurant.deliveryFee > 0) {
          return false;
        }

        return true;
      }).toList();

      // Sort results
      switch (_sortBy) {
        case 'rating':
          filtered.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'delivery_time':
          filtered.sort(
            (a, b) =>
                a.estimatedDeliveryTime.compareTo(b.estimatedDeliveryTime),
          );
          break;
        case 'price':
          filtered.sort((a, b) => a.deliveryFee.compareTo(b.deliveryFee));
          break;
        case 'relevance':
        default:
          // Keep original order or sort by relevance
          break;
      }

      _filteredRestaurants = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<RestaurantCubit, RestaurantState>(
        listener: (context, state) {
          if (state is RestaurantsLoaded) {
            setState(() {
              _allRestaurants = state.restaurants;
              _applyFilters();
            });
          }
        },
        child: Column(
          children: [
            // Search Bar Header
            _buildSearchBar(context, l10n),
            // Top Categories
            BlocConsumer<HomeCubit, HomeState>(
              listener: (context, state) {
                if (state is HomeLoaded) {
                  setState(() {
                    _availableCategories = state.categories;
                  });
                  _applyFilters();
                }
              },
              builder: (context, state) {
                final categories = state is HomeLoaded
                    ? state.categories
                    : <RestaurantCategoryEntity>[];
                return _buildTopCategories(context, l10n, categories);
              },
            ),
            // Functional Filter Chips
            _buildFilterSection(context, l10n),
            // Results List
            Expanded(
              child: BlocBuilder<RestaurantCubit, RestaurantState>(
                builder: (context, state) {
                  if (state is RestaurantLoading && _allRestaurants.isEmpty) {
                    return const LoadingWidget();
                  }

                  if (state is RestaurantError && _allRestaurants.isEmpty) {
                    return ErrorDisplayWidget(
                      message: state.message,
                      onRetry: () {
                        context.read<RestaurantCubit>().getAllRestaurants();
                      },
                    );
                  }

                  if (_filteredRestaurants.isEmpty) {
                    return _buildEmptyState(context, l10n);
                  }

                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: _filteredRestaurants.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Colors.grey.withValues(alpha: 0.1),
                    ),
                    itemBuilder: (context, index) {
                      final restaurant = _filteredRestaurants[index];
                      return SearchRestaurantCard(
                        restaurant: restaurant,
                        onTap: () {
                          bool isMarketStore = false;
                          try {
                            final homeState = context.read<HomeCubit>().state;
                            if (homeState is HomeLoaded) {
                              isMarketStore = homeState.categories.any((
                                category,
                              ) {
                                return restaurant.categoryIds.contains(
                                      category.id,
                                    ) &&
                                    category.isMarket;
                              });
                            }
                          } catch (_) {
                            isMarketStore = restaurant.categoryIds.any(
                              (cid) =>
                                  cid.toLowerCase().contains('groceries') ||
                                  cid.toLowerCase().contains('supermarket'),
                            );
                          }

                          if (isMarketStore) {
                            context.push(
                              '/market-products?restaurantId=${restaurant.id}&restaurantName=${Uri.encodeComponent(restaurant.name)}',
                            );
                          } else {
                            context.push('/restaurant/${restaurant.id}');
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AppLocalizations l10n) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Back arrow in a clean style
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
                size: 24,
              ),
              onPressed: () => context.pop(),
            ),
            // Capsule Search field
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          _onSearchChanged();
                        },
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      )
                    else
                      const SizedBox(width: 4),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: false,
                        textAlign: TextAlign.right, // Match RTL reference
                        decoration: InputDecoration(
                          hintText: l10n.searchRestaurants,
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.6,
                            ),
                            fontSize: 14.sp,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.search,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                      size: 20,
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

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noRestaurantsFound,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tryDifferentSearchTerm,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCategories(
    BuildContext context,
    AppLocalizations l10n,
    List<RestaurantCategoryEntity> dynamicCategories,
  ) {
    final displayItems = [
      {
        'isAll': true,
        'title': l10n.all,
        'action': () {
          setState(() {
            _selectedCategoryName = null;
            _applyFilters();
          });
        },
      },
      ...dynamicCategories
          .where((cat) {
            if (widget.filterType == 'market') {
              return cat.isMarket;
            } else {
              return !cat.isMarket;
            }
          })
          .map(
            (cat) => {
              'isAll': false,
              'title': cat.name,
              'action': () {
                setState(() {
                  _selectedCategoryName = cat.name;
                  _applyFilters();
                });
              },
            },
          ),
    ];

    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: displayItems.length,
        separatorBuilder: (_, __) => SizedBox(width: 24.w),
        itemBuilder: (context, index) {
          final item = displayItems[index];
          final isSelected = item['isAll'] == true
              ? _selectedCategoryName == null
              : _selectedCategoryName == item['title'];

          return GestureDetector(
            onTap: item['action'] as VoidCallback,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: isSelected
                    ? const Border(
                        bottom: BorderSide(
                          color: AppColors.textPrimary,
                          width: 2,
                        ),
                      )
                    : null,
              ),
              child: Text(
                item['title'] as String,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, AppLocalizations l10n) {
    return Container(
      height: 60.h,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          _buildFilterChip(label: l10n.freeDelivery, onTap: () {}),
          SizedBox(width: 8.w),
          _buildFilterChip(
            label: l10n.pickup,
            icon: Icons.directions_walk,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    final isSortIcon = icon == Icons.keyboard_arrow_down;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSortIcon && icon != null) ...[
              Icon(icon, size: 18.w, color: Colors.black),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            if (icon != null && !isSortIcon) ...[
              SizedBox(width: 4.w),
              Icon(icon, size: 16.w, color: Colors.black),
            ],
          ],
        ),
      ),
    );
  }
}
