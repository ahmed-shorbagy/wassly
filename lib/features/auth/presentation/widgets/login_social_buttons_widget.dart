import 'package:flutter/material.dart';
import '../../../../core/utils/extensions.dart';

class LoginSocialButtonsWidget extends StatelessWidget {
  const LoginSocialButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider with "or" text
        Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                context.l10n.or.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
          ],
        ),
        const SizedBox(height: 20),
        // Google Login Button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton.icon(
            onPressed: () {
              context.showInfoSnackBar(context.l10n.socialLoginComingSoon);
            },
            icon: Image.network(
              'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
              height: 20,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.g_mobiledata, color: Color(0xFF757575)),
            ),
            label: const Text('Google'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE0E0E0)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              foregroundColor: const Color(0xFF424242),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
