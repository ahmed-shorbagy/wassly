import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/extensions.dart';

class LoginSignupLinkWidget extends StatelessWidget {
  const LoginSignupLinkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            context.l10n.dontHaveAccount,
            style: const TextStyle(color: Colors.white),
          ),
          TextButton(
            onPressed: () => context.push('/signup'),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: Text(context.l10n.signup),
          ),
        ],
      ),
    );
  }
}
