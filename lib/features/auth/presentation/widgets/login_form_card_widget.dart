import 'package:flutter/material.dart';
import 'login_email_field_widget.dart';
import 'login_password_field_widget.dart';
import 'login_forgot_password_button_widget.dart';
import 'login_button_widget.dart';
import 'login_social_buttons_widget.dart';

class LoginFormCardWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLoginPressed;
  final VoidCallback onForgotPasswordPressed;

  const LoginFormCardWidget({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onLoginPressed,
    required this.onForgotPasswordPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // Email Field
          LoginEmailFieldWidget(controller: emailController),
          const SizedBox(height: 16),
          // Password Field
          LoginPasswordFieldWidget(controller: passwordController),
          const SizedBox(height: 4),
          // Forgot Password Button
          LoginForgotPasswordButtonWidget(onPressed: onForgotPasswordPressed),
          const SizedBox(height: 20),
          // Login Button
          LoginButtonWidget(onLoginPressed: onLoginPressed),
          const SizedBox(height: 24),
          // Social Login Buttons
          const LoginSocialButtonsWidget(),
        ],
      ),
    );
  }
}
