import 'package:flutter/material.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';

class LoginPasswordFieldWidget extends StatefulWidget {
  final TextEditingController controller;

  const LoginPasswordFieldWidget({super.key, required this.controller});

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
        hintText: context.l10n.password,
        hintStyle: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 15),
        prefixIcon: const Icon(
          Icons.lock_outlined,
          color: Color(0xFF15BE77),
          size: 22,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFFB0BEC5),
            size: 22,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        filled: true,
        fillColor: const Color(0xFFF5F6FA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF15BE77), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE74C3C), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE74C3C), width: 1.5),
        ),
      ),
      style: const TextStyle(color: Color(0xFF1E272E), fontSize: 15),
    );
  }
}
