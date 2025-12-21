import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../cubits/auth_cubit.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.myProfile,
          style: TextStyle(fontSize: ResponsiveHelper.fontSize(18)),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: ResponsiveHelper.getAppBarHeight(context),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const LoadingWidget();
          }

          if (state is AuthAuthenticated) {
            final user = state.user;
            return SingleChildScrollView(
              padding: ResponsiveHelper.padding(all: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  _buildProfileHeader(context, user, l10n),
                  ResponsiveHelper.spacing(height: 24),

                  // Account Information Section
                  _buildSectionTitle(l10n.accountInformation),
                  ResponsiveHelper.spacing(height: 12),
                  _buildInfoCard(
                    context,
                    [
                      _buildInfoRow(
                        Icons.person_outline,
                        l10n.fullName,
                        user.name,
                      ),
                      const Divider(height: 1),
                      _buildInfoRow(
                        Icons.email_outlined,
                        l10n.email,
                        user.email,
                      ),
                      const Divider(height: 1),
                      _buildInfoRow(
                        Icons.phone_outlined,
                        l10n.phone,
                        user.phone,
                      ),
                    ],
                  ),
                  ResponsiveHelper.spacing(height: 24),

                  // Actions Section
                  _buildSectionTitle(l10n.settings),
                  ResponsiveHelper.spacing(height: 12),
                  _buildActionCard(
                    context,
                    [
                      _buildActionTile(
                        context,
                        icon: Icons.shopping_bag_outlined,
                        title: l10n.myOrders,
                        onTap: () => context.push('/orders'),
                      ),
                      const Divider(height: 1),
                      _buildActionTile(
                        context,
                        icon: Icons.lock_outline,
                        title: l10n.changePassword,
                        onTap: () => _showChangePasswordDialog(context, l10n),
                      ),
                    ],
                  ),
                  ResponsiveHelper.spacing(height: 24),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showLogoutDialog(context, l10n),
                      icon: Icon(
                        Icons.logout,
                        size: ResponsiveHelper.iconSize(20),
                      ),
                      label: Text(
                        l10n.logout,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.fontSize(16),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: ResponsiveHelper.padding(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                  ResponsiveHelper.spacing(height: 32),
                ],
              ),
            );
          }

          // Not authenticated - redirect to login
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  size: ResponsiveHelper.iconSize(64),
                  color: AppColors.textSecondary,
                ),
                ResponsiveHelper.spacing(height: 16),
                Text(
                  l10n.pleaseLogIn,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(16),
                    color: AppColors.textSecondary,
                  ),
                ),
                ResponsiveHelper.spacing(height: 24),
                ElevatedButton(
                  onPressed: () => context.push('/login'),
                  child: Text(
                    l10n.login,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    dynamic user,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: ResponsiveHelper.padding(all: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40.r,
            backgroundColor: Colors.white,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: TextStyle(
                fontSize: ResponsiveHelper.fontSize(32),
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          ResponsiveHelper.spacing(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(24),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                ResponsiveHelper.spacing(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(14),
                    color: Colors.white.withOpacity(0.9),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: ResponsiveHelper.fontSize(18),
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: ResponsiveHelper.padding(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: ResponsiveHelper.iconSize(24),
          ),
          ResponsiveHelper.spacing(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(12),
                    color: AppColors.textSecondary,
                  ),
                ),
                ResponsiveHelper.spacing(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(16),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
        size: ResponsiveHelper.iconSize(24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveHelper.fontSize(16),
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
        size: ResponsiveHelper.iconSize(24),
      ),
      onTap: onTap,
    );
  }

  void _showChangePasswordDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthPasswordChanged) {
            context.pop();
            context.showSuccessSnackBar(l10n.passwordUpdatedSuccessfully);
          } else if (state is AuthError) {
            context.showErrorSnackBar(state.message);
          }
        },
        child: AlertDialog(
          title: Text(
            l10n.changePassword,
            style: TextStyle(fontSize: ResponsiveHelper.fontSize(18)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: true,
                  style: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
                  decoration: InputDecoration(
                    labelText: l10n.currentPassword,
                    labelStyle: TextStyle(fontSize: ResponsiveHelper.fontSize(14)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                ResponsiveHelper.spacing(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  style: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
                  decoration: InputDecoration(
                    labelText: l10n.newPassword,
                    labelStyle: TextStyle(fontSize: ResponsiveHelper.fontSize(14)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                ResponsiveHelper.spacing(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  style: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
                  decoration: InputDecoration(
                    labelText: l10n.confirmNewPassword,
                    labelStyle: TextStyle(fontSize: ResponsiveHelper.fontSize(14)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: Text(l10n.cancel),
            ),
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                return ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (newPasswordController.text !=
                              confirmPasswordController.text) {
                            context.showErrorSnackBar(
                              'Passwords do not match',
                            );
                            return;
                          }
                          if (newPasswordController.text.length < 6) {
                            context.showErrorSnackBar(
                              'Password must be at least 6 characters',
                            );
                            return;
                          }
                          context.read<AuthCubit>().changePassword(
                                currentPasswordController.text,
                                newPasswordController.text,
                              );
                        },
                  child: isLoading
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(strokeWidth: 2.w),
                        )
                      : Text(
                          l10n.updatePassword,
                          style: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.logout,
          style: TextStyle(fontSize: ResponsiveHelper.fontSize(18)),
        ),
        content: Text(
          l10n.areYouSureLogout,
          style: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              l10n.cancel,
              style: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthCubit>().logout();
              context.push('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(
              l10n.logout,
              style: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
            ),
          ),
        ],
      ),
    );
  }
}

