import '../../l10n/app_localizations.dart';

/// Helper class for market product categories
/// Provides consistent category definitions across the app
class MarketProductCategories {
  /// Get all available market product categories
  // Category Keys
  static const String offers = 'offers';
  static const String fruitsVegetables = 'fruits_vegetables';
  static const String bakery = 'bakery';
  static const String cakeAndCoffee = 'cake_and_coffee';
  static const String poultryMeatSeafood = 'poultry_meat_seafood';
  static const String freshFood = 'fresh_food';
  static const String readyToEat = 'ready_to_eat';
  static const String frozenFood = 'frozen_food';
  static const String dairyAndEggs = 'dairy_and_eggs';
  static const String iceCream = 'ice_cream';
  static const String snacks = 'snacks';
  static const String beverages = 'beverages';
  static const String milk = 'milk';
  static const String personalCare = 'personal_care';
  static const String beauty = 'beauty';
  static const String cookingAndBaking = 'cooking_and_baking';
  static const String coffeeAndTea = 'coffee_and_tea';
  static const String pharmacy = 'pharmacy';
  static const String tissuesAndBags = 'tissues_and_bags';
  static const String cannedFood = 'canned_food';
  static const String breakfastFood = 'breakfast_food';
  static const String babyCorner = 'baby_corner';
  static const String cleaningAndLaundry = 'cleaning_and_laundry';
  static const String specialDiet = 'special_diet';
  static const String spicesAndSauces = 'spices_and_sauces';

  /// Get map of category keys to localized names
  static Map<String, String> getCategoryMap(AppLocalizations l10n) {
    return {
      offers: l10n.offers,
      fruitsVegetables: l10n.fruitsVegetables,
      bakery: l10n.bakery,
      cakeAndCoffee:
          'Cake & Coffee', // Loc key missing, using hardcoded for now or add to arb if possible. Using English as fallback.
      poultryMeatSeafood: l10n.poultryMeatSeafood,
      freshFood: l10n.freshFood,
      readyToEat: l10n.readyToEat,
      frozenFood: l10n.frozenFood,
      dairyAndEggs: l10n.dairyAndEggs,
      iceCream: l10n.iceCream,
      snacks: l10n.snacks,
      beverages: l10n.beverages,
      milk: l10n.milk,
      personalCare: l10n.personalCare,
      beauty: l10n.beauty,
      cookingAndBaking: l10n.cookingAndBaking,
      coffeeAndTea: l10n.coffeeAndTea,
      pharmacy: l10n.pharmacy,
      tissuesAndBags: l10n.tissuesAndBags,
      cannedFood: l10n.cannedFood,
      breakfastFood: l10n.breakfastFood,
      babyCorner: l10n.babyCorner,
      cleaningAndLaundry: l10n.cleaningAndLaundry,
      specialDiet: l10n.specialDiet,
      spicesAndSauces: l10n.spicesAndSauces,
    };
  }

  /// Get all available market product category keys
  static List<String> getCategories(AppLocalizations l10n) {
    return getCategoryMap(l10n).keys.toList();
  }

  /// Get localized name for a category key
  static String getCategoryName(String key, AppLocalizations l10n) {
    return getCategoryMap(l10n)[key] ?? key;
  }

  /// Get category image path (Assets)
  static String? getCategoryImageUrl(
    String categoryKey,
    AppLocalizations l10n,
  ) {
    switch (categoryKey) {
      case offers:
        return 'assets/images/logo.jpeg'; // File missing
      case fruitsVegetables:
        return 'assets/images/fruits&veg.jpeg';
      case bakery:
        return 'assets/images/cake&cofee.jpeg'; // Placeholder
      case cakeAndCoffee:
        return 'assets/images/cake&cofee.jpeg';
      case poultryMeatSeafood:
        return 'assets/images/poultry_meat_seafood.jpeg';
      case freshFood:
        return 'assets/images/fresh_food.jpeg';
      case readyToEat:
        return 'assets/images/ready_to_eat.jpeg';
      case frozenFood:
        return 'assets/images/frozen_food.jpeg';
      case dairyAndEggs:
        return 'assets/images/dairy_eggs.jpeg';
      case iceCream:
        return 'assets/images/ice_cream.jpeg';
      case snacks:
        return 'assets/images/snacks.jpeg';
      case beverages:
        return 'assets/images/beverages.jpeg';
      case milk:
        return 'assets/images/dairy_eggs.jpeg'; // Placeholder
      case personalCare:
        return 'assets/images/logo.jpeg'; // File missing
      case beauty:
        return 'assets/images/logo.jpeg'; // File missing
      case cookingAndBaking:
        return 'assets/images/cooking_baking.jpeg';
      case coffeeAndTea:
        return 'assets/images/coffee_tea.jpeg';
      case pharmacy:
        return 'assets/images/pharamcies.jpeg';
      case tissuesAndBags:
        return 'assets/images/tissues_bags.jpeg';
      case cannedFood:
        return 'assets/images/canned_food.jpeg';
      case breakfastFood:
        return 'assets/images/breakfast_food.jpeg';
      case babyCorner:
        return 'assets/images/baby_corner.jpeg';
      case cleaningAndLaundry:
        return 'assets/images/cleaning_laundry.jpeg';
      case specialDiet:
        return 'assets/images/fresh_food.jpeg'; // Placeholder
      case spicesAndSauces:
        return 'assets/images/spices_sauces.jpeg';
      default:
        return 'assets/images/logo.jpeg';
    }
  }

  /// Get category background color (pastel)
  static int getCategoryColor(String category, AppLocalizations l10n) {
    // Default to white/gray as we are using images mostly now
    return 0xFFF5F5F5;
  }
}
