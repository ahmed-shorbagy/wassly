import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Section
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'App Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language, color: AppColors.primary),
                  title: const Text('Language'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to language settings
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications, color: AppColors.primary),
                  title: const Text('Notifications'),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      // Toggle notifications
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // About Section
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.info, color: AppColors.primary),
                  title: Text('App Version'),
                  subtitle: Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings, color: AppColors.primary),
                  title: const Text('Admin Panel'),
                  subtitle: const Text('Full access without authentication'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help, color: AppColors.primary),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to help
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
