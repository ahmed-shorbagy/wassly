import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../cubits/auth_cubit.dart';

class LoginButtonWidget extends StatelessWidget {
  final VoidCallback onLoginPressed;

  const LoginButtonWidget({super.key, required this.onLoginPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const LoadingWidget();
        }

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onLoginPressed,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(context.l10n.login),
          ),
        );
      },
    );
  }
}
