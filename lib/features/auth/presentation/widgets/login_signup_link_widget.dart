import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginSignupLinkWidget extends StatelessWidget {
  const LoginSignupLinkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            "ليس لديك حساب؟",
            style: TextStyle(color: Colors.white),
          ),
          TextButton(
            onPressed: () => context.push('/signup'),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('إنشاء حساب'),
          ),
        ],
      ),
    );
  }
}

