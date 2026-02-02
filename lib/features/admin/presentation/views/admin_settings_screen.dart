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
                    l10n.appSettings,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language, color: AppColors.primary),
                  title: Text(l10n.language),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to language settings
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.notifications,
                    color: AppColors.primary,
                  ),
                  title: Text(l10n.notifications),
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
                    l10n.about,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info, color: AppColors.primary),
                  title: Text(l10n.appVersion),
                  subtitle: const Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.admin_panel_settings,
                    color: AppColors.primary,
                  ),
                  title: Text(l10n.adminPanel),
                  subtitle: Text(l10n.adminPanelSubtitle),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help, color: AppColors.primary),
                  title: Text(l10n.helpSupport),
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
