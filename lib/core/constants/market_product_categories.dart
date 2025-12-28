import '../../l10n/app_localizations.dart';

/// Helper class for market product categories
/// Provides consistent category definitions across the app
class MarketProductCategories {
  /// Get all available market product categories
  static List<String> getCategories(AppLocalizations l10n) {
    return [
      l10n.offers,
      l10n.fruitsVegetables,
      l10n.bakery,
      l10n.poultryMeatSeafood,
      l10n.freshFood,
      l10n.readyToEat,
      l10n.frozenFood,
      l10n.dairyAndEggs,
      l10n.iceCream,
      l10n.snacks,
      l10n.beverages,
      l10n.milk,
      l10n.personalCare,
      l10n.beauty,
      l10n.cookingAndBaking,
      l10n.coffeeAndTea,
      l10n.pharmacy,
      l10n.tissuesAndBags,
      l10n.cannedFood,
      l10n.breakfastFood,
      l10n.babyCorner,
      l10n.cleaningAndLaundry,
      l10n.specialDiet,
      l10n.spicesAndSauces,
    ];
  }

  /// Get category image path (Assets)
  static String? getCategoryImageUrl(String category, AppLocalizations l10n) {
    if (category == l10n.offers)
      return 'assets/images/logo.jpeg'; // File missing
    if (category == l10n.fruitsVegetables)
      return 'assets/images/fruits&veg.jpeg';
    if (category == l10n.bakery)
      return 'assets/images/cake&cofee.jpeg'; // Placeholder
    if (category == l10n.poultryMeatSeafood)
      return 'assets/images/poultry_meat_seafood.jpeg';
    if (category == l10n.freshFood) return 'assets/images/fresh_food.jpeg';
    if (category == l10n.readyToEat) return 'assets/images/ready_to_eat.jpeg';
    if (category == l10n.frozenFood) return 'assets/images/frozen_food.jpeg';
    if (category == l10n.dairyAndEggs) return 'assets/images/dairy_eggs.jpeg';
    if (category == l10n.iceCream) return 'assets/images/ice_cream.jpeg';
    if (category == l10n.snacks) return 'assets/images/snacks.jpeg';
    if (category == l10n.beverages) return 'assets/images/beverages.jpeg';
    if (category == l10n.milk)
      return 'assets/images/dairy_eggs.jpeg'; // Placeholder
    if (category == l10n.personalCare)
      return 'assets/images/logo.jpeg'; // File missing
    if (category == l10n.beauty)
      return 'assets/images/logo.jpeg'; // File missing
    if (category == l10n.cookingAndBaking)
      return 'assets/images/cooking_baking.jpeg';
    if (category == l10n.coffeeAndTea) return 'assets/images/coffee_tea.jpeg';
    if (category == l10n.pharmacy) return 'assets/images/pharamcies.jpeg';
    if (category == l10n.tissuesAndBags)
      return 'assets/images/tissues_bags.jpeg';
    if (category == l10n.cannedFood) return 'assets/images/canned_food.jpeg';
    if (category == l10n.breakfastFood)
      return 'assets/images/breakfast_food.jpeg';
    if (category == l10n.babyCorner) return 'assets/images/baby_corner.jpeg';
    if (category == l10n.cleaningAndLaundry)
      return 'assets/images/cleaning_laundry.jpeg';
    if (category == l10n.specialDiet)
      return 'assets/images/fresh_food.jpeg'; // Placeholder
    if (category == l10n.spicesAndSauces)
      return 'assets/images/spices_sauces.jpeg';

    return 'assets/images/logo.jpeg';
  }

  /// Get category background color (pastel)
  static int getCategoryColor(String category, AppLocalizations l10n) {
    // Default to white/gray as we are using images mostly now
    return 0xFFF5F5F5;
  }
}
