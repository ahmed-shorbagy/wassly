import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../cubits/favorites_cubit.dart';
import '../cubits/restaurant_cubit.dart';
import 'package:go_router/go_router.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final restaurantCubit = context.read<RestaurantCubit>();
    if (restaurantCubit.state is! RestaurantsLoaded) {
      restaurantCubit.getAllRestaurants();
    }

    return Scaffold(
      appBar: AppBar(
        title: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            return Text(l10n?.favorites ?? 'المفضلة');
          },
        ),
      ),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, favState) {
          final allRestaurantsState = context.watch<RestaurantCubit>().state;
          List<RestaurantEntity> restaurants = [];
          if (allRestaurantsState is RestaurantsLoaded) {
            restaurants = allRestaurantsState.restaurants
                .where((r) => favState.favoriteRestaurantIds.contains(r.id))
                .toList();
          }

          if (restaurants.isEmpty) {
            return Center(
              child: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  return Text(
                    l10n?.noFavoritesYet ?? 'لا توجد عناصر مفضلة بعد',
                  );
                },
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: restaurants.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              final isFav = favState.favoriteRestaurantIds.contains(restaurant.id);
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                leading: CircleAvatar(
                  backgroundColor: AppColors.border,
                  child: const Icon(Icons.restaurant, color: AppColors.primary),
                ),
                title: Text(restaurant.name),
                subtitle: Text(restaurant.address),
                trailing: IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : AppColors.textSecondary,
                  ),
                  onPressed: () {
                    context.read<FavoritesCubit>().toggleRestaurant(restaurant.id);
                  },
                ),
                onTap: () => context.push('/restaurant/${restaurant.id}'),
              );
            },
          );
        },
      ),
    );
  }
}


