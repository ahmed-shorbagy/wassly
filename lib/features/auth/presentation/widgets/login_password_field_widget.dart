import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';

class LoginPasswordFieldWidget extends StatefulWidget {
  final TextEditingController controller;

  const LoginPasswordFieldWidget({
    super.key,
    required this.controller,
  });

  @override
  State<LoginPasswordFieldWidget> createState() =>
      _LoginPasswordFieldWidgetState();
}

class _LoginPasswordFieldWidgetState extends State<LoginPasswordFieldWidget> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscurePassword,
      validator: Validators.validatePassword,
      decoration: InputDecoration(
        labelText: AppStrings.password,
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
    );
  }
}

