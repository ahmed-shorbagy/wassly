import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../cubits/restaurant_cubit.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../cubits/favorites_cubit.dart';

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
  late TabController _categoryTabController;
  List<RestaurantEntity> _allRestaurants = [];
  List<RestaurantEntity> _filteredRestaurants = [];
  String _selectedCategory = 'all';
  final String _sortBy = 'relevance';
  final bool _freeDeliveryOnly = false;

  final List<String> _categories = [
    'all',
    'restaurants',
    'groceries',
    'health_beauty',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    _categoryTabController = TabController(
      length: _categories.length,
      vsync: this,
    );
    _categoryTabController.addListener(_onCategoryChanged);

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
    _categoryTabController.removeListener(_onCategoryChanged);
    _categoryTabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onCategoryChanged() {
    if (!_categoryTabController.indexIsChanging) {
      setState(() {
        _selectedCategory = _categories[_categoryTabController.index];
        _applyFilters();
      });
    }
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
          final nameMatch = restaurant.name.toLowerCase().contains(query);
          final descMatch = restaurant.description.toLowerCase().contains(
            query,
          );
          final categoryMatch = restaurant.categories.any(
            (cat) => cat.toLowerCase().contains(query),
          );
          final addressMatch = restaurant.address.toLowerCase().contains(query);
          if (!(nameMatch || descMatch || categoryMatch || addressMatch)) {
            return false;
          }
        }

        // Filter by category
        if (_selectedCategory != 'all') {
          // For now, we'll treat all as restaurants since we only have restaurant entity
          // In future, you can filter by actual category type
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
                      return _SearchResultCard(
                        restaurant: _filteredRestaurants[index],
                        onTap: () {
                          context.push(
                            '/restaurant/${_filteredRestaurants[index].id}',
                          );
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
}

class _SearchResultCard extends StatelessWidget {
  final RestaurantEntity restaurant;
  final VoidCallback onTap;

  const _SearchResultCard({required this.restaurant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Restaurant Logo
            _buildRestaurantLogo(context),
            const SizedBox(width: 16),
            // Restaurant Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    restaurant.name,
                    style: TextStyle(
                      fontSize: screenWidth < 360 ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppColors.warning,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${restaurant.totalReviews})',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurant.estimatedDeliveryTime} ${l10n.minutesAbbreviation}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.delivery_dining_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurant.deliveryFee.toStringAsFixed(0)} ${l10n.currencySymbol}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
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
  }

  Widget _buildRestaurantLogo(BuildContext context) {
    const double size = 75;

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.border.withOpacity(0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child:
                restaurant.imageUrl != null && restaurant.imageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: restaurant.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.border,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        _buildFallbackLogo(size),
                  )
                : _buildFallbackLogo(size),
          ),
        ),
        // Heart Icon
        Positioned(
          top: 0,
          right: 0,
          child: BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, state) {
              final isFavorite = state.favoriteRestaurantIds.contains(
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 14,
                    color: isFavorite ? Colors.red : AppColors.textSecondary,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackLogo(double size) {
    return Container(
      color: AppColors.border,
      child: Icon(
        Icons.restaurant,
        size: size * 0.4,
        color: AppColors.textSecondary,
      ),
    );
  }
}
