import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../l10n/app_localizations.dart';
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
      body: Container(
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Image.asset('assets/images/logo.jpeg', fit: BoxFit.contain),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'أهلاً بك',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'سجّل دخولك للمتابعة',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  // Form Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
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
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                            child: Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context);
                                return TextButton(
                                  onPressed: () => _showForgotPasswordDialog(context),
                                  child: Text(l10n?.forgotPassword ?? 'نسيت كلمة المرور؟'),
                                );
                              },
                            ),
                        ),
                        const SizedBox(height: 4),
                        // Login Button
                        BlocConsumer<AuthCubit, AuthState>(
                          listener: (context, state) {
                            if (state is AuthAuthenticated) {
                              AppLogger.logNavigation(
                                'User authenticated, navigating to home',
                              );
                              final userType = state.user.userType;
                              AppLogger.logInfo('User type: $userType');
                              // Customer app only handles customer users
                              context.go('/home');
                            } else if (state is AuthPasswordResetSent) {
                              final l10n = AppLocalizations.of(context);
                              context.showSuccessSnackBar(
                                l10n?.passwordResetEmailSent ?? 'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
                              );
                            } else if (state is AuthError) {
                              AppLogger.logError(
                                'Login error displayed to user: ${state.message}',
                              );
                              context.showErrorSnackBar(state.message);
                            }
                          },
                          builder: (context, state) {
                            if (state is AuthLoading) {
                              return const LoadingWidget();
                            }
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(AppStrings.login),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: const [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('أو'),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  final l10n = AppLocalizations.of(context);
                                  context.showInfoSnackBar(
                                    l10n?.socialLoginComingSoon ?? 'تسجيل الدخول عبر وسائل التواصل الاجتماعي قريباً',
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
                                  final l10n = AppLocalizations.of(context);
                                  context.showInfoSnackBar(
                                    l10n?.socialLoginComingSoon ?? 'تسجيل الدخول عبر وسائل التواصل الاجتماعي قريباً',
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
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          AppStrings.dontHaveAccount,
                          style: const TextStyle(color: Colors.white),
                        ),
                        TextButton(
                          onPressed: () => context.go('/signup'),
                          style: TextButton.styleFrom(foregroundColor: Colors.white),
                          child: const Text(AppStrings.signup),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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

  void _showForgotPasswordDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n?.resetPassword ?? 'إعادة تعيين كلمة المرور'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n?.enterEmailForPasswordReset ?? 'أدخل بريدك الإلكتروني لإرسال رابط إعادة تعيين كلمة المرور'),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: AppStrings.email,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                validator: Validators.validateEmail,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n?.cancel ?? 'إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(dialogContext).pop();
                context.read<AuthCubit>().resetPassword(
                      emailController.text.trim(),
                    );
              }
            },
            child: Text(l10n?.send ?? 'إرسال'),
          ),
        ],
      ),
    );
  }
}
