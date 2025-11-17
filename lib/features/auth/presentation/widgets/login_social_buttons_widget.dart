import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/extensions.dart';

class LoginSocialButtonsWidget extends StatelessWidget {
  const LoginSocialButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // Divider with "or" text
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'أو',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 12),
        // Social Login Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  context.showInfoSnackBar(
                    l10n?.socialLoginComingSoon ??
                        'تسجيل الدخول عبر وسائل التواصل الاجتماعي قريباً',
                  );
                },
                icon: const Icon(Icons.g_mobiledata, size: 22),
                label: const Text('Google'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  context.showInfoSnackBar(
                    l10n?.socialLoginComingSoon ??
                        'تسجيل الدخول عبر وسائل التواصل الاجتماعي قريباً',
                  );
                },
                icon: const Icon(Icons.facebook, size: 20),
                label: const Text('Facebook'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

