import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'restaurant_orders_screen.dart';

class MarketOrdersScreen extends StatelessWidget {
  const MarketOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Reusing the logic but effectively wrapping it to potentially override strings/theme
    // For now, it's a direct wrapper, but having this file allows us to distinctively route
    // and potentially customize the "RestaurantOrdersScreen" to say "Market Orders" via l10n overrides in future
    return const RestaurantOrdersScreen();
  }
}
