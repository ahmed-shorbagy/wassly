import 'package:flutter/material.dart';
import '../../../../core/utils/extensions.dart';

class LoginHeaderWidget extends StatelessWidget {
  const LoginHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(10),
          child: Image.asset('assets/images/logo.jpeg', fit: BoxFit.contain),
        ),
        const SizedBox(height: 18),
        // Welcome Text
        Text(
          context.l10n.welcome,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        // Subtitle
        Text(
          context.l10n.loginToContinue,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }
}
