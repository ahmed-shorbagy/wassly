import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class LoginForgotPasswordButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const LoginForgotPasswordButtonWidget({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          l10n?.forgotPassword ?? 'نسيت كلمة المرور؟',
          style: const TextStyle(color: Color(0xFF27AE60)),
        ),
      ),
    );
  }
}

