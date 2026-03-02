import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/extensions.dart';

class LoginSignupLinkWidget extends StatelessWidget {
  const LoginSignupLinkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.l10n.dontHaveAccount,
            style: const TextStyle(color: Color(0xFF7F8C8D), fontSize: 14),
          ),
          TextButton(
            onPressed: () => context.push('/signup'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF15BE77),
              padding: const EdgeInsets.symmetric(horizontal: 6),
            ),
            child: Text(
              context.l10n.signup,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
