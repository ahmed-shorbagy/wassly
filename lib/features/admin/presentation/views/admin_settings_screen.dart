import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubits/admin_cubit.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _minDeliveriesController = TextEditingController();
  final _bonusAmountController = TextEditingController();
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    context.read<AdminCubit>().getBonusSettings();
  }

  @override
  void dispose() {
    _minDeliveriesController.dispose();
    _bonusAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is BonusSettingsLoaded) {
            setState(() {
              _minDeliveriesController.text =
                  (state.settings['minDeliveries'] ?? 50).toString();
              _bonusAmountController.text =
                  (state.settings['bonusAmount'] ?? 100.0).toString();
              _isEnabled = state.settings['isEnabled'] ?? false;
            });
          } else if (state is BonusDistributionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${l10n.bonusDistributionSuccess}: ${state.count} drivers',
                ),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<AdminCubit, AdminState>(
          builder: (context, state) {
            return ListView(
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
                        leading: const Icon(
                          Icons.language,
                          color: AppColors.primary,
                        ),
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

                // Driver Bonus Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.driverBonusSettings,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.bonusEnabled),
                            Switch(
                              value: _isEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _isEnabled = value;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _minDeliveriesController,
                          decoration: InputDecoration(
                            labelText: l10n.minMonthlyDeliveries,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.local_shipping),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _bonusAmountController,
                          decoration: InputDecoration(
                            labelText: l10n.bonusAmount,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(
                              Icons.account_balance_wallet,
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: state is AdminLoading
                                    ? null
                                    : () {
                                        context
                                            .read<AdminCubit>()
                                            .updateBonusSettings(
                                              minDeliveries:
                                                  int.tryParse(
                                                    _minDeliveriesController
                                                        .text,
                                                  ) ??
                                                  50,
                                              bonusAmount:
                                                  double.tryParse(
                                                    _bonusAmountController.text,
                                                  ) ??
                                                  100.0,
                                              isEnabled: _isEnabled,
                                            );
                                      },
                                child: state is AdminLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(l10n.save),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.send_rounded),
                            label: Text(l10n.distributeMonthlyBonuses),
                            onPressed: state is AdminLoading
                                ? null
                                : () {
                                    _showConfirmDistributionDialog(
                                      context,
                                      l10n,
                                    );
                                  },
                          ),
                        ),
                      ],
                    ),
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
                        leading: const Icon(
                          Icons.info,
                          color: AppColors.primary,
                        ),
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
                        leading: const Icon(
                          Icons.help,
                          color: AppColors.primary,
                        ),
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
            );
          },
        ),
      ),
    );
  }

  void _showConfirmDistributionDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.distributeMonthlyBonuses),
        content: Text(
          "This will calculate and award bonuses for all drivers who reached the threshold last month. This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              this.context.read<AdminCubit>().distributeMonthlyBonuses();
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}
