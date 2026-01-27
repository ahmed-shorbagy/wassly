class CategoryImageHelper {
  static String? getAssetForCategory(String categoryName) {
    if (categoryName.isEmpty) return null;

    final name = categoryName.toLowerCase().trim();

    // Exact or loose matches based on available assets
    if (name.contains('pharmc') || name.contains('pharmac')) {
      // Covers pharmacy, pharmacies
      return 'assets/images/pharamcies.jpeg'; // Note: retaining original filename typo
    } else if (name.contains('vegetable') ||
        name.contains('fruit') ||
        name.contains('fresh')) {
      return 'assets/images/fruits&veg.jpeg';
    } else if (name.contains('cake') ||
        name.contains('coffee') ||
        name.contains('cafe')) {
      return 'assets/images/cake&cofee.jpeg'; // Note: retaining original filename typo
    } else if (name.contains('market') ||
        name.contains('grocery') ||
        name.contains('supermarket')) {
      return 'assets/images/market.jpeg';
    } else if (name.contains('bakery') || name.contains('bake')) {
      return 'assets/images/cooking_baking.jpeg';
    } else if (name.contains('meat') || name.contains('poultry')) {
      return 'assets/images/meats.jpeg';
    } else if (name.contains('fish') || name.contains('seafood')) {
      return 'assets/images/fish.jpeg';
    } else if (name.contains('baby')) {
      return 'assets/images/baby_corner.jpeg';
    } else if (name.contains('clean') || name.contains('laundry')) {
      return 'assets/images/cleaning_laundry.jpeg';
    } else if (name.contains('snack')) {
      return 'assets/images/snacks.jpeg';
    } else if (name.contains('ice cream') || name.contains('dessert')) {
      return 'assets/images/ice_cream.jpeg';
    } else if (name.contains('breakfast')) {
      return 'assets/images/breakfast_food.jpeg';
    }

    return null;
  }
}
