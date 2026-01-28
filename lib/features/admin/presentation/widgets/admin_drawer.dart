import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

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
                _buildDrawerItem(
                  context,
                  icon: Icons.delivery_dining,
                  title: l10n.drivers,
                  route: '/admin/drivers',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.people,
                  title: l10n.users,
                  route: '/admin/users',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.shopping_bag,
                  title: l10n.orders,
                  route: '/admin/orders',
                ),

                const Divider(),
                _buildSectionHeader(context, l10n.catalog),
                _buildDrawerItem(
                  context,
                  icon: Icons.category,
                  title: l10n.categories,
                  route: '/admin/categories',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.shopping_bag_outlined,
                  title: l10n.marketProducts,
                  route: '/admin/market-products',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.list_alt,
                  title: l10n.restaurantCategories,
                  route: '/admin/restaurant-categories',
                ),

                const Divider(),
                _buildSectionHeader(context, l10n.marketing),
                _buildDrawerItem(
                  context,
                  icon: Icons.slideshow,
                  title: l10n.startupAds,
                  route: '/admin/ads/startup',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.image,
                  title: l10n.bannerAds,
                  route: '/admin/ads/banners',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.local_offer,
                  title: l10n.promotionalImages,
                  route: '/admin/ads/promotional',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.article,
                  title: l10n.articles,
                  route: '/admin/articles',
                ),

                const Divider(),
                _buildSectionHeader(context, l10n.system),
                _buildDrawerItem(
                  context,
                  icon: Icons.analytics,
                  title: l10n.analytics,
                  route: '/admin/analytics',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.support_agent,
                  title: l10n.supportChat,
                  route: '/admin/support',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  title: l10n.settings,
                  route: '/admin/settings',
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
          colors: [Colors.purple.shade700, Colors.purple.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      accountName: Text(
        l10n.adminDashboard,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      accountEmail: Text(
        l10n.welcomeBack,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(
          Icons.admin_panel_settings,
          size: 40,
          color: Colors.purple.shade700,
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
    // Basic navigation, highlighting can be improved if GoRouter state is accessible conveniently
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
