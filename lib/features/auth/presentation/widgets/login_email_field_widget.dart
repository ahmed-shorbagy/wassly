import 'package:flutter/material.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';

class LoginEmailFieldWidget extends StatelessWidget {
  final TextEditingController controller;

  const LoginEmailFieldWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      validator: Validators.validateEmail,
      decoration: InputDecoration(
        labelText: context.l10n.email,
        prefixIcon: const Icon(Icons.email_outlined),
      ),
    );
  }
}
