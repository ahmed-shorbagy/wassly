import '../../l10n/app_localizations.dart';

/// Helper class for market product categories
/// Provides consistent category definitions across the app
class MarketProductCategories {
  /// Get all available market product categories
  static List<String> getCategories(AppLocalizations l10n) {
    return [
      l10n.vegetables,
      l10n.fruits,
      l10n.snacks,
      l10n.dairy,
      l10n.meat,
      l10n.beverages,
      l10n.bakery,
      l10n.frozen,
      l10n.canned,
      l10n.spices,
      l10n.cleaning,
      l10n.personalCare,
    ];
  }

  /// Get category icon
  static String getCategoryIcon(String category, AppLocalizations l10n) {
    if (category == l10n.vegetables) return '🥬';
    if (category == l10n.fruits) return '🍎';
    if (category == l10n.snacks) return '🍿';
    if (category == l10n.dairy) return '🥛';
    if (category == l10n.meat) return '🥩';
    if (category == l10n.beverages) return '🥤';
    if (category == l10n.bakery) return '🍞';
    if (category == l10n.frozen) return '🧊';
    if (category == l10n.canned) return '🥫';
    if (category == l10n.spices) return '🌶️';
    if (category == l10n.cleaning) return '🧹';
    if (category == l10n.personalCare) return '🧴';
    return '📦';
  }

  /// Get category background color (pastel)
  static int getCategoryColor(String category, AppLocalizations l10n) {
    if (category == l10n.vegetables) return 0xFFE8F5E9; // Light green
    if (category == l10n.fruits) return 0xFFFFEBEE; // Light red/pink
    if (category == l10n.snacks) return 0xFFFFF9C4; // Light yellow
    if (category == l10n.dairy) return 0xFFE3F2FD; // Light blue
    if (category == l10n.meat) return 0xFFFFE0E0; // Light pink
    if (category == l10n.beverages) return 0xFFE0F2F1; // Light teal
    if (category == l10n.bakery) return 0xFFFFF3E0; // Light orange
    if (category == l10n.frozen) return 0xFFE1F5FE; // Light cyan
    if (category == l10n.canned) return 0xFFF3E5F5; // Light purple
    if (category == l10n.spices) return 0xFFFFE0B2; // Light orange
    if (category == l10n.cleaning) return 0xFFE8EAF6; // Light indigo
    if (category == l10n.personalCare) return 0xFFFCE4EC; // Light pink
    return 0xFFF5F5F5; // Default gray
  }

  /// Get category icon color (solid)
  static int getCategoryIconColor(String category, AppLocalizations l10n) {
    if (category == l10n.vegetables) return 0xFF4CAF50; // Green
    if (category == l10n.fruits) return 0xFFE91E63; // Pink
    if (category == l10n.snacks) return 0xFFFFC107; // Yellow
    if (category == l10n.dairy) return 0xFF2196F3; // Blue
    if (category == l10n.meat) return 0xFFFF5252; // Red
    if (category == l10n.beverages) return 0xFF009688; // Teal
    if (category == l10n.bakery) return 0xFFFF9800; // Orange
    if (category == l10n.frozen) return 0xFF00BCD4; // Cyan
    if (category == l10n.canned) return 0xFF9C27B0; // Purple
    if (category == l10n.spices) return 0xFFFF6F00; // Deep orange
    if (category == l10n.cleaning) return 0xFF3F51B5; // Indigo
    if (category == l10n.personalCare) return 0xFFE91E63; // Pink
    return 0xFF757575; // Default gray
  }
}

