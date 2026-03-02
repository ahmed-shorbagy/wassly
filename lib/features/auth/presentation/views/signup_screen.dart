import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../cubits/auth_cubit.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 15),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF15BE77), size: 22),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF5F6FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FFF5),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF15BE77).withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Image.asset(
                        'assets/images/logo.jpeg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    context.l10n.newAccount,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF1E272E),
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.joinWasslyNow,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF7F8C8D),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    validator: Validators.validateName,
                    decoration: _buildInputDecoration(
                      hintText: context.l10n.fullName,
                      prefixIcon: Icons.person_outlined,
                    ),
                    style: const TextStyle(
                      color: Color(0xFF1E272E),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                    decoration: _buildInputDecoration(
                      hintText: context.l10n.email,
                      prefixIcon: Icons.email_outlined,
                    ),
                    style: const TextStyle(
                      color: Color(0xFF1E272E),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Phone Field (Egypt-only)
                  IntlPhoneField(
                    initialCountryCode: 'EG',
                    showDropdownIcon: false,
                    disableLengthCheck: false,
                    decoration: InputDecoration(
                      hintText: context.l10n.phoneNumber,
                      hintStyle: const TextStyle(
                        color: Color(0xFFB0BEC5),
                        fontSize: 15,
                      ),
                      prefixIcon: const Icon(
                        Icons.phone_outlined,
                        color: Color(0xFF15BE77),
                        size: 22,
                      ),
                      counterText: '',
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
                        borderSide: const BorderSide(
                          color: Color(0xFFEEEEEE),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF15BE77),
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFFE74C3C),
                          width: 1,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFFE74C3C),
                          width: 1.5,
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      color: Color(0xFF1E272E),
                      fontSize: 15,
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (phone) {
                      if (phone == null) {
                        return context.l10n.pleaseEnterPhoneNumber;
                      }
                      final national = phone.number;
                      final validPrefix =
                          national.startsWith('10') ||
                          national.startsWith('11') ||
                          national.startsWith('12') ||
                          national.startsWith('15');
                      if (!validPrefix || national.length != 10) {
                        return context.l10n.pleaseEnterValidPhoneNumber;
                      }
                      return null;
                    },
                    onChanged: (phone) {
                      _phoneController.text = phone.completeNumber;
                    },
                    onSaved: (phone) {
                      if (phone != null) {
                        _phoneController.text = phone.completeNumber;
                      }
                    },
                  ),
                  const SizedBox(height: 14),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: Validators.validatePassword,
                    decoration: _buildInputDecoration(
                      hintText: context.l10n.password,
                      prefixIcon: Icons.lock_outlined,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xFFB0BEC5),
                          size: 22,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    style: const TextStyle(
                      color: Color(0xFF1E272E),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    validator: (value) => Validators.validateConfirmPassword(
                      value,
                      _passwordController.text,
                    ),
                    decoration: _buildInputDecoration(
                      hintText: context.l10n.confirmPassword,
                      prefixIcon: Icons.lock_outlined,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xFFB0BEC5),
                          size: 22,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    style: const TextStyle(
                      color: Color(0xFF1E272E),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Signup Button
                  BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state is AuthAuthenticated) {
                        context.pushReplacement('/home');
                      } else if (state is AuthError) {
                        context.showErrorSnackBar(state.message);
                      }
                    },
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const LoadingWidget();
                      }
                      return SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF15BE77),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                          child: Text(context.l10n.signup),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Login Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.l10n.alreadyHaveAccount,
                          style: const TextStyle(
                            color: Color(0xFF7F8C8D),
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/login'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF15BE77),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                          child: Text(
                            context.l10n.login,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _signup() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signup(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        userType: AppConstants.userTypeCustomer,
      );
    }
  }
}
