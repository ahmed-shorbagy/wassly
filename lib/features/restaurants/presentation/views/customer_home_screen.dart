import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../home/presentation/cubits/home_cubit.dart';
import '../../../home/domain/entities/banner_entity.dart';
import '../cubits/restaurant_cubit.dart';
import '../../../orders/presentation/cubits/cart_cubit.dart';
import '../../domain/entities/restaurant_entity.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocProvider(
        providers: [
          BlocProvider<RestaurantCubit>(
            create: (context) =>
                context.read<RestaurantCubit>()..getAllRestaurants(),
          ),
          BlocProvider<HomeCubit>(
            create: (_) => HomeCubit()..loadHome(),
          ),
        ],
        child: BlocBuilder<RestaurantCubit, RestaurantState>(
          builder: (context, state) {
            if (state is RestaurantLoading) {
              return const LoadingWidget();
            } else if (state is RestaurantError) {
              return ErrorDisplayWidget(
                message: state.message,
                onRetry: () =>
                    context.read<RestaurantCubit>().getAllRestaurants(),
              );
            } else if (state is RestaurantsLoaded) {
              return _buildHome(context, state.restaurants);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildHome(
    BuildContext context,
    List<RestaurantEntity> restaurants,
  ) {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          actions: [
            // Cart Button with Badge
            BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                final itemCount = state is CartLoaded ? state.itemCount : 0;
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart),
                      onPressed: () => context.push('/cart'),
                    ),
                    if (itemCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$itemCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: const Text(
              AppStrings.restaurants,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
              ),
            ),
          ),
        ),

        // Search
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'What are you craving?',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Banners
        BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            final banners = state is HomeLoaded ? state.banners : <BannerEntity>[];
            return SliverToBoxAdapter(
              child: _BannerCarousel(banners: banners),
            );
          },
        ),

        // Categories
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _CategoriesSection(onTapSeeAll: () {}),
          ),
        ),

        // Restaurants Grid title
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Nearby Restaurants',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                Text('See All', style: TextStyle(color: Colors.green)),
              ],
            ),
          ),
        ),

        // Restaurants Grid
        if (restaurants.isEmpty)
          SliverFillRemaining(
            child: EmptyStateWidget(
              title: 'No Restaurants',
              message: 'No restaurants available at the moment',
              icon: Icons.restaurant,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final restaurant = restaurants[index];
                return _buildRestaurantCard(context, restaurant);
              }, childCount: restaurants.length),
            ),
          ),
      ],
    );
  }

  Widget _buildRestaurantCard(
    BuildContext context,
    RestaurantEntity restaurant,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          context.push('/restaurant/${restaurant.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: restaurant.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: restaurant.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => Container(
                          color: AppColors.border,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.border,
                          child: const Icon(Icons.restaurant, size: 50),
                        ),
                      )
                    : Container(
                        color: AppColors.border,
                        child: const Icon(Icons.restaurant, size: 50),
                      ),
              ),
            ),

            // Restaurant Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant Name
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Status
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: restaurant.isOpen
                              ? AppColors.success
                              : AppColors.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          restaurant.isOpen ? 'Open' : 'Closed',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
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
}

class _BannerCarousel extends StatelessWidget {
  final List<BannerEntity> banners;
  const _BannerCarousel({required this.banners});

  @override
  Widget build(BuildContext context) {
    final effective = banners.isEmpty
        ? [
            const BannerEntity(
              id: 'placeholder',
              imageUrl:
                  'https://images.unsplash.com/photo-1550547660-d9450f859349?q=80&w=1200',
              title: 'Special Offer',
            )
          ]
        : banners;
    return SizedBox(
      height: 160,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: effective.length,
        itemBuilder: (context, index) {
          final b = effective[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: b.imageUrl,
                fit: BoxFit.cover,
                placeholder: (c, u) => Container(
                  color: AppColors.surface,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (c, u, e) => Container(
                  color: AppColors.surface,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  final VoidCallback onTapSeeAll;
  const _CategoriesSection({required this.onTapSeeAll});

  @override
  Widget build(BuildContext context) {
    final items = [
      _Category('Burgers', Icons.lunch_dining),
      _Category('Pizza', Icons.local_pizza),
      _Category('Noodles', Icons.ramen_dining),
      _Category('Meat', Icons.set_meal),
      _Category('Vegan', Icons.eco),
      _Category('Dessert', Icons.cake),
      _Category('Drink', Icons.local_drink),
      _Category('More', Icons.more_horiz),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Special Offers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            InkWell(
              onTap: onTapSeeAll,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('See All', style: TextStyle(color: Colors.green)),
              ),
            )
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisExtent: 90,
          ),
          itemBuilder: (context, index) {
            final c = items[index];
            return Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F7F6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(c.icon, color: Colors.green),
                ),
                const SizedBox(height: 8),
                Text(
                  c.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Category {
  final String label;
  final IconData icon;
  _Category(this.label, this.icon);
}
