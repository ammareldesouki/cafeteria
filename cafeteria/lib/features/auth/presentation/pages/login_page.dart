
import 'package:cafeteria/core/constants/image_strings.dart';
import 'package:cafeteria/core/route/route_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../manager/auth_bloc.dart';
import '../widgets/app_text_field.dart';
import '../widgets/buttons.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  void _onSignIn() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        SignInEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          // Navigate to home / dashboard after successful sign-up
          Navigator.pushReplacementNamed(context, RouteNames.layout);
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
                          TImages.logoRemove,
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

                        Align(
                          alignment: AlignmentGeometry.centerRight,
                            child: Text("Forget Password ?",style:  TextStyle(fontSize: 15,))),

                      const SizedBox(height: 16),



                      // ── Sign Up button ─────────────────────────────────
                      PrimaryButton(
                        label: 'Log In',
                        isLoading: isLoading,
                        onTap: _onSignIn,
                      ),
                      const SizedBox(height: 20),

                      // ── Divider ────────────────────────────────────────




                      // ── Sign In link ───────────────────────────────────
                      Center(
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.pushReplacementNamed(context,RouteNames.signUp),
                          child: RichText(
                            text: const TextSpan(
                              text: ' Don\'t Have An Account ? ',
                              style: TextStyle(
                                color: Color(0xFF9E9E9E),
                                fontSize: 13,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Create Account',
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
