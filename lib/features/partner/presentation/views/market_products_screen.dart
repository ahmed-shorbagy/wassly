import 'package:flutter/material.dart';
import 'product_management_screen.dart';

class MarketProductsScreen extends StatelessWidget {
  const MarketProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrapper for ProductManagementScreen
    return const ProductManagementScreen(isMarket: true);
  }
}
