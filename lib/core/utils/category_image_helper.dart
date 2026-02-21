class CategoryImageHelper {
  static String? getAssetForCategory(String categoryName) {
    if (categoryName.isEmpty) return null;

    final name = categoryName.toLowerCase().trim();

    // Exact or loose matches based on available assets
    // Including Arabic support
    if (name.contains('pharmc') ||
        name.contains('pharmac') ||
        name.contains('صيدلية') ||
        name.contains('صيدليه')) {
      // Covers pharmacy, pharmacies
      return 'assets/images/pharamcies.jpeg'; // Note: retaining original filename typo
    } else if (name.contains('vegetable') ||
        name.contains('fruit') ||
        name.contains('fresh') ||
        name.contains('خضروات') ||
        name.contains('فواكه') ||
        name.contains('خضار')) {
      return 'assets/images/fruits&veg.jpeg';
    } else if (name.contains('cake') ||
        name.contains('coffee') ||
        name.contains('cafe') ||
        name.contains('كيك') ||
        name.contains('قهوة') ||
        name.contains('قهوه') ||
        name.contains('حلويات')) {
      return 'assets/images/cake&cofee.jpeg'; // Note: retaining original filename typo
    } else if (name.contains('market') ||
        name.contains('grocery') ||
        name.contains('supermarket') ||
        name.contains('ماركت') ||
        name.contains('سوبر')) {
      return 'assets/images/market.jpeg';
    } else if (name.contains('bakery') ||
        name.contains('bake') ||
        name.contains('مخبز')) {
      return 'assets/images/cooking_baking.jpeg';
    } else if (name.contains('meat') ||
        name.contains('poultry') ||
        name.contains('لحم') ||
        name.contains('دجاج')) {
      return 'assets/images/meats.jpeg';
    } else if (name.contains('fish') ||
        name.contains('seafood') ||
        name.contains('سمك') ||
        name.contains('بحري')) {
      return 'assets/images/fish.jpeg';
    } else if (name.contains('baby') || name.contains('طفل')) {
      return 'assets/images/baby_corner.jpeg';
    } else if (name.contains('clean') ||
        name.contains('laundry') ||
        name.contains('غسيل') ||
        name.contains('نظافة')) {
      return 'assets/images/cleaning_laundry.jpeg';
    } else if (name.contains('snack') || name.contains('سناك')) {
      return 'assets/images/snacks.jpeg';
    } else if (name.contains('ice cream') ||
        name.contains('dessert') ||
        name.contains('ايس')) {
      return 'assets/images/ice_cream.jpeg';
    } else if (name.contains('breakfast') || name.contains('فطور')) {
      return 'assets/images/breakfast_food.jpeg';
    } else if (name.contains('restaur') ||
        name.contains('food') ||
        name.contains('أكل') ||
        name.contains('طعام') ||
        name.contains('مطعم')) {
      return 'assets/images/resturants.jpeg';
    }

    return null;
  }

  static String getDefaultAsset() {
    return 'assets/images/market.jpeg';
  }
}
