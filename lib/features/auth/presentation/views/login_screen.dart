import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubits/auth_cubit.dart';
import '../widgets/login_header_widget.dart';
import '../widgets/login_form_card_widget.dart';
import '../widgets/login_signup_link_widget.dart';
import '../widgets/forgot_password_dialog_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: _handleAuthStateChanges,
      child: Scaffold(
        backgroundColor: const Color(0xFF27AE60),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with Logo and Welcome Text
                  const LoginHeaderWidget(),
                  const SizedBox(height: 20),
                  // Form Card
                  LoginFormCardWidget(
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    onLoginPressed: _handleLogin,
                    onForgotPasswordPressed: _showForgotPasswordDialog,
                  ),
                  const SizedBox(height: 16),
                  // Sign Up Link
                  const LoginSignupLinkWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleAuthStateChanges(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      AppLogger.logNavigation('User authenticated, navigating to home');
      AppLogger.logInfo('User type: ${state.user.userType}');

      final userType = state.user.userType;
      if (userType == 'restaurant') {
        context.pushReplacement('/restaurant');
      } else if (userType == 'market') {
        context.pushReplacement('/market');
      } else if (userType == 'driver') {
        context.pushReplacement('/driver');
      } else {
        context.pushReplacement('/home');
      }
    } else if (state is AuthPasswordResetSent) {
      final l10n = AppLocalizations.of(context);
      context.showSuccessSnackBar(
        l10n?.passwordResetEmailSent ??
            'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
      );
    } else if (state is AuthError) {
      AppLogger.logError('Login error displayed to user: ${state.message}');
      context.showErrorSnackBar(state.message);
    }
  }

  void _handleLogin() {
    AppLogger.logInfo('Login button pressed');
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      AppLogger.logAuth('Form validated, attempting login with email: $email');
      context.read<AuthCubit>().login(email, password);
    } else {
      AppLogger.logWarning('Login form validation failed');
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => const ForgotPasswordDialogWidget(),
    );
  }
}
