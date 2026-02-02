import 'package:flutter/material.dart';
import '../../../../core/utils/extensions.dart';

class LoginForgotPasswordButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const LoginForgotPasswordButtonWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          context.l10n.forgotPassword,
          style: const TextStyle(color: Color(0xFF27AE60)),
        ),
      ),
    );
  }
}
