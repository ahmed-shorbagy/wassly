import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Enhanced AppBar with Gradient
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.shade700,
                      Colors.purple.shade500,
                      Colors.purple.shade400,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -80,
                      left: -80,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    // Content
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.adminDashboard,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.welcomeBack,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.admin_panel_settings,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Text(l10n.adminAccess),
                      content: Text(l10n.adminAccessDescription),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.ok),
                        ),
                      ],
                    ),
                  );
                },
                tooltip: l10n.info,
              ),
            ],
          ),

          // Statistics Cards Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: l10n.totalRestaurants,
                      value: '0',
                      icon: Icons.restaurant,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: l10n.totalOrders,
                      value: '0',
                      icon: Icons.shopping_bag,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: l10n.totalUsers,
                      value: '0',
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Quick Actions Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                l10n.quickActions,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ),
          ),

          // Dashboard Cards Grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final items = _getDashboardItems(context);
                  if (index >= items.length) return const SizedBox.shrink();
                  return _buildEnhancedDashboardCard(context, items[index]);
                },
                childCount: _getDashboardItems(context).length,
              ),
            ),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  List<_DashboardItem> _getDashboardItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      _DashboardItem(
        title: l10n.restaurants,
        icon: Icons.restaurant,
        color: Colors.orange,
        route: '/admin/restaurants',
        gradient: [Colors.orange.shade400, Colors.orange.shade600],
      ),
      _DashboardItem(
        title: l10n.drivers,
        icon: Icons.delivery_dining,
        color: Colors.blue,
        route: '/admin/drivers',
        gradient: [Colors.blue.shade400, Colors.blue.shade600],
      ),
      _DashboardItem(
        title: l10n.users,
        icon: Icons.people,
        color: Colors.green,
        route: '/admin/users',
        gradient: [Colors.green.shade400, Colors.green.shade600],
      ),
      _DashboardItem(
        title: l10n.analytics,
        icon: Icons.analytics,
        color: Colors.purple,
        route: '/admin/analytics',
        gradient: [Colors.purple.shade400, Colors.purple.shade600],
      ),
      _DashboardItem(
        title: l10n.orders,
        icon: Icons.shopping_bag,
        color: Colors.red,
        route: '/admin/orders',
        gradient: [Colors.red.shade400, Colors.red.shade600],
      ),
      _DashboardItem(
        title: l10n.settings,
        icon: Icons.settings,
        color: Colors.grey,
        route: '/admin/settings',
        gradient: [Colors.grey.shade400, Colors.grey.shade600],
      ),
      _DashboardItem(
        title: l10n.marketProducts,
        icon: Icons.shopping_bag_outlined,
        color: Colors.teal,
        route: '/admin/market-products',
        gradient: [Colors.teal.shade400, Colors.teal.shade600],
      ),
      _DashboardItem(
        title: l10n.startupAds,
        icon: Icons.slideshow,
        color: Colors.indigo,
        route: '/admin/ads/startup',
        gradient: [Colors.indigo.shade400, Colors.indigo.shade600],
      ),
      _DashboardItem(
        title: l10n.bannerAds,
        icon: Icons.image,
        color: Colors.cyan,
        route: '/admin/ads/banners',
        gradient: [Colors.cyan.shade400, Colors.cyan.shade600],
      ),
    ];
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedDashboardCard(
    BuildContext context,
    _DashboardItem item,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (value * 0.1),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () => context.go(item.route),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: item.gradient,
              ),
            ),
            child: Stack(
              children: [
                // Decorative circle
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.icon,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      // Title
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Arrow indicator
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardItem {
  final String title;
  final IconData icon;
  final Color color;
  final String route;
  final List<Color> gradient;

  _DashboardItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
    required this.gradient,
  });
}

