import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';

class RestaurantAdminDrawer extends StatelessWidget {
  const RestaurantAdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      child: Column(
        children: [
          _buildHeader(context, l10n),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildSectionHeader(context, l10n.management),
                _buildDrawerItem(
                  context,
                  icon: Icons.restaurant,
                  title: l10n.restaurantsAndMarkets,
                  route: '/admin/restaurants',
                ),

                const Divider(),
                _buildSectionHeader(context, l10n.catalog),
                _buildDrawerItem(
                  context,
                  icon: Icons.list_alt,
                  title: l10n.restaurantCategories,
                  route: '/admin/restaurant-categories',
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              l10n.logout,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              // Add logout functionality if required
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        gradient: LinearGradient(
          colors: [Colors.orange.shade700, Colors.orange.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      accountName: Text(
        'Restaurant Admin',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      accountEmail: Text(
        l10n.welcomeBack,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(
          Icons.restaurant_menu,
          size: 40,
          color: Colors.orange.shade700,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Close drawer
        context.push(route);
      },
    );
  }
}
