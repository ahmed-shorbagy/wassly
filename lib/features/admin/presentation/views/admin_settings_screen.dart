import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';

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
          // Account Section
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.person, color: AppColors.primary),
                  title: const Text('Profile'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to profile
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock, color: AppColors.primary),
                  title: Text(l10n.changePassword),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to change password
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

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
          const SizedBox(height: 24),

          // Logout Button
          BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthUnauthenticated) {
                context.go('/login');
              }
            },
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.logout),
                      content: Text(l10n.areYouSureLogout),
                      actions: [
                        TextButton(
                          onPressed: () => context.pop(),
                          child: Text(l10n.cancel),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context.read<AuthCubit>().logout();
                            context.pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                          ),
                          child: Text(l10n.logout),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
                label: Text(l10n.logout),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

