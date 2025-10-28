import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../cubits/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Center(
                  child: Container(
                    width: 150,
                    height: 90,
                    margin: const EdgeInsets.only(bottom: 32),
                    child: Image.asset(
                      'assets/images/logo.jpeg',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.restaurant,
                          size: 80,
                          color: Colors.orange,
                        );
                      },
                    ),
                  ),
                ),
                // Title
                Text(
                  AppStrings.login,
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome back to Wassly',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                  decoration: InputDecoration(
                    labelText: AppStrings.email,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: Validators.validatePassword,
                  decoration: InputDecoration(
                    labelText: AppStrings.password,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Button
                BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state is AuthAuthenticated) {
                      AppLogger.logNavigation(
                        'User authenticated, navigating to home',
                      );
                      // Navigate based on user type
                      final userType = state.user.userType;
                      AppLogger.logInfo(
                        'User type: $userType, navigating to appropriate home',
                      );
                      if (userType == 'customer') {
                        context.go('/customer');
                      } else if (userType == 'restaurant') {
                        context.go('/restaurant');
                      } else if (userType == 'driver') {
                        context.go('/driver');
                      } else {
                        context.go('/customer'); // Default fallback
                      }
                    } else if (state is AuthError) {
                      AppLogger.logError(
                        'Login error displayed to user: ${state.message}',
                      );
                      context.showErrorSnackBar(state.message);
                      // Don't navigate on error - let user retry or signup
                    }
                  },
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return const LoadingWidget();
                    }

                    return ElevatedButton(
                      onPressed: _login,
                      child: const Text(AppStrings.login),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Signup Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.dontHaveAccount),
                    TextButton(
                      onPressed: () => context.go('/signup'),
                      child: const Text(AppStrings.signup),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _login() {
    AppLogger.logInfo('Login button pressed');
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      AppLogger.logAuth('Form validated, attempting login with email: $email');
      context.read<AuthCubit>().login(email, password);
    } else {
      AppLogger.logWarning('Login form validation failed');
    }
  }
}
