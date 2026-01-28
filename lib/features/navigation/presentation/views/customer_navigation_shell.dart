import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/customer_navigation_cubit.dart';

class CustomerNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CustomerNavigationShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) =>
          CustomerNavigationCubit(initialIndex: navigationShell.currentIndex),
      child: BlocListener<CustomerNavigationCubit, CustomerNavigationState>(
        listenWhen: (previous, current) =>
            previous.changeId != current.changeId,
        listener: (context, state) {
          navigationShell.goBranch(
            state.index,
            initialLocation: state.resetToInitialLocation,
          );
        },
        child: BlocBuilder<CustomerNavigationCubit, CustomerNavigationState>(
          builder: (context, state) {
            return Scaffold(
              body: navigationShell,
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: state.index,
                onTap: (index) =>
                    context.read<CustomerNavigationCubit>().selectTab(index),
                type: BottomNavigationBarType.fixed,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: AppColors.textSecondary,
                selectedLabelStyle: TextStyle(
                  fontSize: ResponsiveHelper.fontSize(12),
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: ResponsiveHelper.fontSize(12),
                  fontWeight: FontWeight.w500,
                ),
                selectedIconTheme: IconThemeData(
                  size: ResponsiveHelper.iconSize(24),
                ),
                unselectedIconTheme: IconThemeData(
                  size: ResponsiveHelper.iconSize(24),
                ),
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: l10n.navHome,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.receipt_long_outlined),
                    activeIcon: Icon(Icons.receipt_long),
                    label: l10n.navOrders,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: l10n.navProfile,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
