import 'package:cafeteria/core/route/route_name.dart';
import 'package:cafeteria/core/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../manager/auth_bloc.dart';
import '../widgets/app_text_field.dart';
import '../widgets/buttons.dart';
import '../widgets/language_theme_toggles.dart';

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
  final _nameController = TextEditingController();

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
              name: _nameController.text,


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
          final role = state.response.user.role;
          final targetRoute =
              role == 'admin' ? RouteNames.cafeteriaPanel : RouteNames.layout;

          Navigator.pushReplacementNamed(
            context,
            targetRoute,
            arguments: {
              'userName': state.response.user.name.isNotEmpty
                  ? state.response.user.name
                  : state.response.user.email.split('@').first,
              'userId': state.response.user.id,
              'role': role,
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

        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const LanguageThemeToggles(key: ValueKey('signup_toggles')),
                        ],
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


                      AppTextField(label: AppLocalizations.of(context)!
                          .firstName,
                        controller: _nameController,
                        hint: "Enter Name",),
                      const SizedBox(height: 16),

                      // ── Email ──────────────────────────────────────────
                      AppTextField(
                        label: AppLocalizations.of(context)!.email,
                        hint: 'you@example.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return AppLocalizations.of(context)!.emailRequired;
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                            return AppLocalizations.of(context)!.emailInvalid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ── Password ───────────────────────────────────────
                      AppTextField(
                        label: AppLocalizations.of(context)!.password,
                        hint: '********',
                        controller: _passwordController,
                        isPassword: true,
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return AppLocalizations.of(context)!
                                .passwordRequired;
                          if (v.length < 8) {
                            return AppLocalizations.of(context)!
                                .passwordTooShort;
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
                          label: AppLocalizations.of(context)!.phoneNumber,
                          hint: '0123456789',
                        controller:_phoneNumberController,
                        validator: Validator.validatePhoneNumber
                      ),
                      const SizedBox(height: 16),

                      Text(
                        AppLocalizations.of(context)!.gender,
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
                                    AppLocalizations.of(context)!.male,
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
                                    AppLocalizations.of(context)!.female,
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
                        label: AppLocalizations.of(context)!.signUp,
                        isLoading: isLoading,
                        onTap: _onSignUp,
                      ),
                      const SizedBox(height: 20),

                      // // ── Divider ────────────────────────────────────────
                      // Row(
                      //   children: const [
                      //     Expanded(child: Divider()),
                      //     Padding(
                      //       padding: EdgeInsets.symmetric(horizontal: 12),
                      //       child: Text(
                      //         'Or continue with',
                      //         style: TextStyle(
                      //           fontSize: 13,
                      //           color: Color(0xFF9E9E9E),
                      //         ),
                      //       ),
                      //     ),
                      //     Expanded(child: Divider()),
                      //   ],
                      // ),
                      // const SizedBox(height: 16),

                      // // ── Outlook button ────────────────────────────────
                      // SocialButton(
                      //   label: 'Sign up with Outlook',
                      //   iconAsset: 'assets/icons/logo.png',
                      //   onTap: isLoading ? null : _onOutlookSignUp,
                      // ),
                      // const SizedBox(height: 12),
                      //
                      // // ── Google button ─────────────────────────────────
                      // SocialButton(
                      //   label: 'Sign up with Google',
                      //   iconAsset: 'assets/icons/logo.png',
                      //   onTap: isLoading ? null : _onGoogleSignUp,
                      // ),
                      // const SizedBox(height: 24),

                      // ── Sign In link ───────────────────────────────────
                      Center(
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.pushReplacementNamed(context, RouteNames.signIn),
                          child: RichText(
                            text: TextSpan(
                              text: AppLocalizations.of(context)!
                                  .alreadyHaveAccount,
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyMedium,

                              children: [
                                TextSpan(
                                  text: AppLocalizations.of(context)!.login,
                                  style: TextStyle(
                                    color: Color(0xFFFF6107),
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
