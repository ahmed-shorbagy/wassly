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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        child: Image.asset(
                          'assets/images/logo.jpeg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    context.l10n.newAccount,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.joinWasslyNow,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
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
                        // Note: In the customer app, only normal customers can sign up.
                        // User type is enforced to customer; no selection UI is shown.
                        const SizedBox(height: 8),

                        // Name Field
                        TextFormField(
                          controller: _nameController,
                          validator: Validators.validateName,
                          decoration: InputDecoration(
                            labelText: context.l10n.fullName,
                            prefixIcon: const Icon(Icons.person_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                          decoration: InputDecoration(
                            labelText: context.l10n.email,
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Phone Field (Egypt-only)
                        IntlPhoneField(
                          initialCountryCode: 'EG',
                          showDropdownIcon: false,
                          disableLengthCheck: false,
                          decoration: InputDecoration(
                            labelText: context.l10n.phoneNumber,
                            prefixIcon: const Icon(Icons.phone_outlined),
                            counterText: '',
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (phone) {
                            if (phone == null) {
                              return context.l10n.pleaseEnterPhoneNumber;
                            }
                            // Egyptian mobile numbers are 10 national digits (without +20) and start with 10/11/12/15
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
                            // Persist the full international number (+20xxxxxxxxxx)
                            _phoneController.text = phone.completeNumber;
                          },
                          onSaved: (phone) {
                            if (phone != null) {
                              _phoneController.text = phone.completeNumber;
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          validator: Validators.validatePassword,
                          decoration: InputDecoration(
                            labelText: context.l10n.password,
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
                        const SizedBox(height: 16),

                        // Confirm Password Field
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          validator: (value) =>
                              Validators.validateConfirmPassword(
                                value,
                                _passwordController.text,
                              ),
                          decoration: InputDecoration(
                            labelText: context.l10n.confirmPassword,
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Signup Button
                  BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state is AuthAuthenticated) {
                        // Customer app - always navigate to home (only customers sign up)
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
                        child: ElevatedButton(
                          onPressed: _signup,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(context.l10n.signup),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Login Link
                  Center(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          context.l10n.alreadyHaveAccount,
                          style: const TextStyle(color: Colors.white),
                        ),
                        TextButton(
                          onPressed: () => context.push('/login'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          child: Text(context.l10n.login),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
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
