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
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          context.l10n.forgotPassword,
          style: const TextStyle(
            color: Color(0xFF15BE77),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
