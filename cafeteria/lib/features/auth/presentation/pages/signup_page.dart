import 'package:cafeteria/core/route/route_name.dart';
import 'package:cafeteria/core/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../manager/auth_bloc.dart';
import '../widgets/app_text_field.dart';
import '../widgets/buttons.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String _selectedGender = 'male'; // default
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignUp() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            SignUpWithEmailEvent(
              email: _emailController.text,
              password: _passwordController.text,
              phoneNumber: _phoneNumberController.text,
              gender: _selectedGender,


            ),
          );
    }
  }

  void _onGoogleSignUp() {
    context.read<AuthBloc>().add(const SignUpWithGoogleEvent());
  }

  void _onOutlookSignUp() {
    context.read<AuthBloc>().add(const SignUpWithMicrosoftEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.pushReplacementNamed(
  context,
  RouteNames.layout,
  arguments: {
    'userName': state.response.user.name.isNotEmpty
        ? state.response.user.name
        : state.response.user.email.split('@').first,
    'userId': state.response.user.id,
  },
);

        } else if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(height: 20),

                      // Logo
                      Center(
                        child: Image.asset(
                          'assets/icons/logo.png',
                          height: 80,
                          errorBuilder: (_, __, ___) => Column(
                            children: const [
                              Icon(Icons.delivery_dining,
                                  size: 50, color: Color(0xFF3B1A08)),
                              Text(
                                'OnTheWay',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3B1A08),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Email ──────────────────────────────────────────
                      AppTextField(
                        label: 'Email',
                        hint: 'you@example.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ── Password ───────────────────────────────────────
                      AppTextField(
                        label: 'Password',
                        controller: _passwordController,
                        isPassword: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password is required';
                          if (v.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ── Confirm Password ───────────────────────────────
                      AppTextField(
                        label: 'Confirm Password',
                        controller: _confirmPasswordController,
                        isPassword: true,
                        validator: (v) {
                          if (v != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),


                      AppTextField(
                        label: 'Phone Number',
                        controller:_phoneNumberController,
                        isPassword: true,
                        validator: Validator.validatePhoneNumber
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Gender',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedGender = 'male';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedGender == 'male'
                                        ? const Color(0xFF3B1A08)
                                        : Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                  color: _selectedGender == 'male'
                                      ? const Color(0xFF3B1A08).withOpacity(0.05)
                                      : Colors.white,
                                ),
                                child: Center(
                                  child: Text(
                                    'Male',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: _selectedGender == 'male'
                                          ? const Color(0xFF3B1A08)
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedGender = 'female';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedGender == 'female'
                                        ? const Color(0xFF3B1A08)
                                        : Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                  color: _selectedGender == 'female'
                                      ? const Color(0xFF3B1A08).withOpacity(0.05)
                                      : Colors.white,
                                ),
                                child: Center(
                                  child: Text(
                                    'Female',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: _selectedGender == 'female'
                                          ? const Color(0xFF3B1A08)
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      // ── Sign Up button ─────────────────────────────────
                      PrimaryButton(
                        label: 'Sign Up',
                        isLoading: isLoading,
                        onTap: _onSignUp,
                      ),
                      const SizedBox(height: 20),

                      // ── Divider ────────────────────────────────────────
                      Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'Or continue with',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9E9E9E),
                              ),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Outlook button ────────────────────────────────
                      SocialButton(
                        label: 'Sign up with Outlook',
                        iconAsset: 'assets/icons/logo.png',
                        onTap: isLoading ? null : _onOutlookSignUp,
                      ),
                      const SizedBox(height: 12),

                      // ── Google button ─────────────────────────────────
                      SocialButton(
                        label: 'Sign up with Google',
                        iconAsset: 'assets/icons/logo.png',
                        onTap: isLoading ? null : _onGoogleSignUp,
                      ),
                      const SizedBox(height: 24),

                      // ── Sign In link ───────────────────────────────────
                      Center(
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.pushReplacementNamed(context, RouteNames.signIn),
                          child: RichText(
                            text: const TextSpan(
                              text: 'Already have an account? ',
                              style: TextStyle(
                                color: Color(0xFF9E9E9E),
                                fontSize: 13,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign In',
                                  style: TextStyle(
                                    color: Color(0xFF3B1A08),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
