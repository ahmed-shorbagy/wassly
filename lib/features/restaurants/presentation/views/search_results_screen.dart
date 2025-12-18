import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_size_text/auto_size_text.dart';
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
  String _sortBy = 'relevance';
  bool _freeDeliveryOnly = false;

  final List<String> _categories = ['all', 'restaurants', 'groceries', 'health_beauty'];

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
          final descMatch = restaurant.description.toLowerCase().contains(query);
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
          filtered.sort((a, b) =>
              a.estimatedDeliveryTime.compareTo(b.estimatedDeliveryTime));
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
                          context.push('/restaurant/${_filteredRestaurants[index].id}');
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Clear button (X)
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () {
                  _searchController.clear();
                },
              ),
            // Search field
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: widget.initialQuery.isEmpty,
                decoration: InputDecoration(
                  hintText: l10n.searchRestaurants,
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            // Search icon
            const Icon(
              Icons.search,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            // Back arrow
            IconButton(
              icon: const Icon(Icons.arrow_forward, color: AppColors.textPrimary),
              onPressed: () => context.pop(),
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
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
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

  const _SearchResultCard({
    required this.restaurant,
    required this.onTap,
  });

  double _getResponsiveFontSize(BuildContext context, {required double baseSize}) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 350) return baseSize - 2;
    if (screenWidth > 450) return baseSize + 1;
    return baseSize;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Logo with Heart
            _buildRestaurantLogo(context),
            SizedBox(width: MediaQuery.of(context).size.width * 0.04), // Responsive spacing
            // Restaurant Info
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: (MediaQuery.of(context).size.width * 0.02).clamp(4.0, 8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name - Constrained to prevent overflow
                    AutoSizeText(
                      restaurant.name,
                      style: TextStyle(
                        fontSize: _getResponsiveFontSize(context, baseSize: 16),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      minFontSize: 10,
                      maxFontSize: _getResponsiveFontSize(context, baseSize: 16),
                      overflow: TextOverflow.ellipsis,
                      wrapWords: false,
                    ),
                    SizedBox(height: (MediaQuery.of(context).size.height * 0.008).clamp(6.0, 10.0)),
                    // Rating - More compact
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          fit: FlexFit.loose,
                          child: AutoSizeText(
                            restaurant.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            minFontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          fit: FlexFit.loose,
                          child: AutoSizeText(
                            '(${restaurant.totalReviews > 999 ? '+1000' : restaurant.totalReviews})',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            minFontSize: 8,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: (MediaQuery.of(context).size.height * 0.008).clamp(6.0, 10.0)),
                    // Delivery Time and Price - More compact
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              fit: FlexFit.loose,
                              child: AutoSizeText(
                                '${restaurant.estimatedDeliveryTime} ${l10n.minutesAbbreviation}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                minFontSize: 8,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: AutoSizeText(
                            '${restaurant.deliveryFee.toStringAsFixed(2)} ${l10n.currencySymbol}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                            maxLines: 1,
                            minFontSize: 10,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    // Special Offer - More compact
                    if (restaurant.isDiscountActive && restaurant.discountDescription != null)
                      Padding(
                        padding: EdgeInsets.only(top: (MediaQuery.of(context).size.height * 0.008).clamp(6.0, 10.0)),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.6,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: AutoSizeText(
                              restaurant.discountDescription!,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.warning,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              minFontSize: 8,
                              overflow: TextOverflow.ellipsis,
                            ),
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

  Widget _buildRestaurantLogo(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = screenWidth * 0.18; // Responsive logo size (18% of screen width)
    final minLogoSize = 70.0;
    final maxLogoSize = 90.0;
    final logoSizeClamped = logoSize.clamp(minLogoSize, maxLogoSize);

    return Container(
      width: logoSizeClamped,
      height: logoSizeClamped,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.border,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: restaurant.imageUrl != null && restaurant.imageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: restaurant.imageUrl!,
                    width: logoSizeClamped,
                    height: logoSizeClamped,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.border,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.border,
                      child: Icon(
                        Icons.restaurant,
                        size: logoSizeClamped * 0.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : Container(
                    color: AppColors.border,
                    child: Icon(
                      Icons.restaurant,
                      size: logoSizeClamped * 0.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
          ),
          // Heart Icon (Favorite) - Smaller
          Positioned(
            top: 2,
            right: 2,
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
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
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
      ),
    );
  }
}

