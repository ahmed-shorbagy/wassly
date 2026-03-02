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
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFF0FFF5),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF15BE77).withOpacity(0.2),
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Image.asset('assets/images/logo.jpeg', fit: BoxFit.contain),
        ),
        const SizedBox(height: 24),
        // Welcome Text
        Text(
          context.l10n.welcome,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF1E272E),
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        // Subtitle
        Text(
          context.l10n.loginToContinue,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF7F8C8D),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
