import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../restaurants/domain/entities/restaurant_entity.dart';
import '../../../restaurants/presentation/cubits/restaurant_cubit.dart';
import '../../../restaurants/domain/entities/restaurant_category_entity.dart';
import '../cubits/admin_restaurant_category_cubit.dart';
import '../cubits/admin_cubit.dart';

class RestaurantManagementScreen extends StatefulWidget {
  const RestaurantManagementScreen({super.key});

  @override
  State<RestaurantManagementScreen> createState() =>
      _RestaurantManagementScreenState();
}

class _RestaurantManagementScreenState
    extends State<RestaurantManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<RestaurantEntity> _filteredRestaurants = [];
  List<RestaurantEntity> _allRestaurants = [];

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
    context.read<AdminRestaurantCategoryCubit>().loadCategories();
    _searchController.addListener(_filterRestaurants);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterRestaurants);
    _searchController.dispose();
    super.dispose();
  }

  void _loadRestaurants() {
    context.read<RestaurantCubit>().getAllRestaurants();
  }

  void _filterRestaurants() {
    final query = _searchController.text.toLowerCase().trim();
    final categoryState = context.read<AdminRestaurantCategoryCubit>().state;
    List<RestaurantCategoryEntity> allCategories = [];
    if (categoryState is AdminRestaurantCategoriesLoaded) {
      allCategories = categoryState.categories;
    }

    setState(() {
      if (query.isEmpty) {
        _filteredRestaurants = List.from(_allRestaurants);
      } else {
        _filteredRestaurants = _allRestaurants.where((restaurant) {
          final nameMatch = restaurant.name.toLowerCase().contains(query);
          final addressMatch = restaurant.address.toLowerCase().contains(query);
          final phoneMatch = restaurant.phone.toLowerCase().contains(query);

          // Category name match
          final restaurantCategories = allCategories.where(
            (cat) => restaurant.categoryIds.contains(cat.id),
          );
          final categoryMatch = restaurantCategories.any(
            (cat) => cat.name.toLowerCase().contains(query),
          );

          return nameMatch || addressMatch || phoneMatch || categoryMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        // Check if we can pop (go back to previous route)
        if (context.canPop()) {
          context.pop();
        } else {
          // If we're at the root, navigate to dashboard instead of closing
          context.go('/admin');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Restaurant Management'),
          backgroundColor: Colors.purple,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadRestaurants,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: StatefulBuilder(
                builder: (context, setState) => TextField(
                  controller: _searchController,
                  onChanged: (_) {
                    setState(() {});
                    _filterRestaurants();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search restaurants...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                              _filterRestaurants();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            // Restaurants List
            Expanded(
              child: BlocConsumer<AdminCubit, AdminState>(
                listener: (context, state) {
                  if (state is RestaurantStatusUpdated) {
                    context.showSuccessSnackBar('Restaurant status updated');
                    _loadRestaurants();
                  } else if (state is RestaurantDeletedSuccess) {
                    context.showSuccessSnackBar(
                      'Restaurant deleted successfully',
                    );
                    _loadRestaurants();
                  } else if (state is AdminError) {
                    context.showErrorSnackBar(state.message);
                  }
                },
                builder: (context, adminState) {
                  return BlocBuilder<RestaurantCubit, RestaurantState>(
                    builder: (context, state) {
                      if (state is RestaurantLoading) {
                        return const LoadingWidget();
                      }

                      if (state is RestaurantError) {
                        return ErrorDisplayWidget(
                          message: state.message,
                          onRetry: _loadRestaurants,
                        );
                      }

                      if (state is RestaurantsLoaded) {
                        // Update all restaurants list
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              _allRestaurants = state.restaurants;
                              _filteredRestaurants = _allRestaurants;
                            });
                            _filterRestaurants(); // Apply current search filter
                          }
                        });

                        // Use filtered list for display
                        final displayList =
                            _filteredRestaurants.isEmpty &&
                                _searchController.text.isEmpty
                            ? state.restaurants
                            : _filteredRestaurants;

                        if (displayList.isEmpty &&
                            _searchController.text.isNotEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: AppColors.textSecondary.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No restaurants found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (displayList.isEmpty) {
                          return _buildEmptyState();
                        }
                        return _buildRestaurantList(displayList);
                      }

                      return _buildEmptyState();
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/admin/restaurants/create'),
          icon: const Icon(Icons.add),
          label: const Text('Create Restaurant'),
          backgroundColor: Colors.purple,
        ),
      ),
    );
  }

  Widget _buildRestaurantList(List<RestaurantEntity> restaurants) {
    return RefreshIndicator(
      onRefresh: () async => _loadRestaurants(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          return _buildRestaurantCard(restaurants[index]);
        },
      ),
    );
  }

  Widget _buildRestaurantCard(RestaurantEntity restaurant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Restaurant Image
              ClipRRect(
                borderRadius: BorderRadiusDirectional.horizontal(
                  start: const Radius.circular(12),
                ).resolve(Directionality.of(context)),
                child: restaurant.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: restaurant.imageUrl!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 120,
                          height: 120,
                          color: Colors.grey[100],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 120,
                          height: 120,
                          color: Colors.grey[100],
                          child: const Icon(Icons.restaurant, size: 40),
                        ),
                      )
                    : Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey[100],
                        child: const Icon(Icons.restaurant, size: 40),
                      ),
              ),

              // Restaurant Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              restaurant.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                restaurant.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Categories
                      BlocBuilder<
                        AdminRestaurantCategoryCubit,
                        AdminRestaurantCategoryState
                      >(
                        builder: (context, state) {
                          String categoriesText = 'No categories';
                          if (state is AdminRestaurantCategoriesLoaded) {
                            final names = restaurant.categoryIds
                                .map((id) {
                                  final cat = state.categories.firstWhere(
                                    (c) => c.id == id,
                                    orElse: () => RestaurantCategoryEntity(
                                      id: id,
                                      name: 'Unknown',
                                      imageUrl: '',
                                      isActive: true,
                                      displayOrder: 0,
                                      createdAt: DateTime.now(),
                                    ),
                                  );
                                  return cat.name;
                                })
                                .where((name) => name != 'Unknown')
                                .toList();

                            if (names.isNotEmpty) {
                              categoriesText =
                                  'Categories: ${names.join(', ')}';
                            }
                          }

                          return Text(
                            categoriesText,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                      const SizedBox(height: 8),

                      // Address
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              restaurant.address,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Phone
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.phone,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.transparent,
              border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Status Toggle
                    Expanded(
                      child: Row(
                        children: [
                          Switch(
                            value: restaurant.isOpen,
                            onChanged: (value) =>
                                _toggleRestaurantStatus(restaurant.id, value),
                            activeThumbColor: Colors.green,
                          ),
                          Flexible(
                            child: Text(
                              restaurant.isOpen ? 'Open' : 'Closed',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: restaurant.isOpen
                                    ? Colors.green
                                    : AppColors.error,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Discount Toggle
                    Expanded(
                      child: Row(
                        children: [
                          Switch(
                            value: restaurant.hasDiscount,
                            onChanged: (value) =>
                                _toggleRestaurantDiscount(restaurant.id, value),
                            activeThumbColor: AppColors.warning,
                          ),
                          Flexible(
                            child: Text(
                              restaurant.hasDiscount
                                  ? 'Discount ON'
                                  : 'Discount OFF',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: restaurant.hasDiscount
                                    ? AppColors.warning
                                    : AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Products Button
                    IconButton(
                      icon: const Icon(Icons.fastfood, color: Colors.orange),
                      onPressed: () => _navigateToProducts(restaurant),
                      tooltip: 'Products',
                    ),

                    // Edit Button
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _navigateToEdit(restaurant),
                      tooltip: 'Edit',
                    ),

                    // Delete Button
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteDialog(restaurant),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 100,
              color: AppColors.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Restaurants Yet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Start by creating your first restaurant',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push('/admin/restaurants/create'),
              icon: const Icon(Icons.add),
              label: const Text('Create Restaurant'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleRestaurantStatus(String restaurantId, bool isOpen) {
    context.read<AdminCubit>().updateRestaurantStatus(restaurantId, isOpen);
  }

  void _toggleRestaurantDiscount(String restaurantId, bool hasDiscount) {
    context.read<AdminCubit>().updateRestaurantDiscount(
      restaurantId,
      hasDiscount,
    );
  }

  void _navigateToProducts(RestaurantEntity restaurant) {
    context.push(
      '/admin/restaurants/${restaurant.id}/products',
      extra: {'id': restaurant.id, 'name': restaurant.name},
    );
  }

  void _navigateToEdit(RestaurantEntity restaurant) {
    context.push('/admin/restaurants/edit/${restaurant.id}', extra: restaurant);
  }

  void _showDeleteDialog(RestaurantEntity restaurant) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Restaurant'),
        content: Text(
          'Are you sure you want to delete "${restaurant.name}"? This action cannot be undone and will also delete all associated products.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AdminCubit>().deleteRestaurant(restaurant.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
