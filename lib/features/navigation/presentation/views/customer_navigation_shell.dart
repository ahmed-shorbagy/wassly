import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/customer_navigation_cubit.dart';

class CustomerNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CustomerNavigationShell({
    super.key,
    required this.navigationShell,
  });

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
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.home_outlined),
                    activeIcon: const Icon(Icons.home),
                    label: l10n.navHome,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.receipt_long_outlined),
                    activeIcon: const Icon(Icons.receipt_long),
                    label: l10n.navOrders,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.person_outline),
                    activeIcon: const Icon(Icons.person),
                    label: l10n.navProfile,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.payment_outlined),
                    activeIcon: const Icon(Icons.payment),
                    label: l10n.navPay,
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

