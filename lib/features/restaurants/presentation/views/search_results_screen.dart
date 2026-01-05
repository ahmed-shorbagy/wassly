import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../cubits/restaurant_cubit.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../widgets/restaurant_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../home/presentation/cubits/home_cubit.dart';
import '../../domain/entities/restaurant_category_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchResultsScreen extends StatefulWidget {
  final String initialQuery;
  final List<RestaurantEntity>? initialRestaurants;

  const SearchResultsScreen({
    super.key,
    this.initialQuery = '',
    this.initialRestaurants,
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

      // Filter by search query
      var filtered = _allRestaurants.where((restaurant) {
        if (query.isNotEmpty) {
          final queryLower = query.toLowerCase();
          final nameMatch = restaurant.name.toLowerCase().contains(queryLower);
          final descMatch = restaurant.description.toLowerCase().contains(
            queryLower,
          );

          // Use _availableCategories (already populated from HomeCubit) to resolve IDs to names
          final categoryMatch = restaurant.categoryIds.any((cid) {
            final category = _availableCategories
                .where((c) => c.id == cid)
                .firstOrNull;
            return category?.name.toLowerCase().contains(queryLower) ??
                cid.toLowerCase().contains(queryLower);
          });

          final addressMatch = restaurant.address.toLowerCase().contains(
            queryLower,
          );
          if (!(nameMatch || descMatch || categoryMatch || addressMatch)) {
            return false;
          }
        }

        // Filter by category
        if (_selectedCategoryName != null) {
          final matchesCategory = restaurant.categoryIds.any((cid) {
            final category = _availableCategories
                .where((c) => c.id == cid)
                .firstOrNull;
            return category?.name == _selectedCategoryName;
          });
          if (!matchesCategory) return false;
        }

        // Filter by free delivery
        if (_freeDeliveryOnly && restaurant.deliveryFee > 0) {
          return false;
        }

        // Filter by pickup (if restaurant supports pickup, you'd check that here)
        // For now, we'll show all restaurants for pickup

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
                }
              },
              builder: (context, state) {
                final categories = state is HomeLoaded
                    ? state.categories
                    : <RestaurantCategoryEntity>[];
                return _buildTopCategories(context, l10n, categories);
              },
            ),
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

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredRestaurants.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SizedBox(
                          height: 240.h,
                          child: RestaurantCard(
                            restaurant: _filteredRestaurants[index],
                          ),
                        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Back arrow
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.textPrimary,
                size: 20,
              ),
              onPressed: () => context.pop(),
            ),
            const SizedBox(width: 8),
            // Search field container
            Expanded(
              child: Container(
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.border.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: _searchController.text.isNotEmpty
                        ? AppColors.primary
                        : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: _searchController.text.isNotEmpty
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: widget.initialQuery.isEmpty,
                        decoration: InputDecoration(
                          hintText: l10n.searchRestaurants,
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.5),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          _onSearchChanged();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
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
        'asset':
            'assets/images/resturants.jpeg', // Using restaurants asset as 'All'
        'title': l10n.all,
        'action': () {
          setState(() {
            _selectedCategoryName = null;
            _applyFilters();
          });
        },
      },
      ...dynamicCategories.map(
        (cat) => {
          'isAll': false,
          'imageUrl': cat.imageUrl,
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
      height: 110.h,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: displayItems.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final item = displayItems[index];
          final isSelected = item['isAll'] == true
              ? _selectedCategoryName == null
              : _selectedCategoryName == item['title'];

          return GestureDetector(
            onTap: item['action'] as VoidCallback,
            child: Column(
              children: [
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: item['imageUrl'] != null
                        ? CachedNetworkImage(
                            imageUrl: item['imageUrl'] as String,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.category),
                          )
                        : Image.asset(
                            item['asset'] as String,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  item['title'] as String,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
