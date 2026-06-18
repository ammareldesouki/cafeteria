
import 'package:cafeteria/core/constants/image_strings.dart';
import 'package:cafeteria/core/route/route_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../manager/auth_bloc.dart';
import '../widgets/app_text_field.dart';
import '../widgets/buttons.dart';
import '../widgets/language_theme_toggles.dart';
import '../widgets/phone_setup_dialog.dart';

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
      listener: (context, state) async {
        if (state is AuthSuccess) {
          final user = state.response.user;
          // Customers must have a phone (e.g. Google sign-in may lack one) so
          // the cafeteria can call about orders. Blocks until provided.
          final ok = await ensurePhoneNumber(context, user);
          if (!ok || !context.mounted) return;

          final role = user.role;
          final targetRoute =
              role == 'admin' ? RouteNames.cafeteriaPanel : RouteNames.layout;

          Navigator.pushReplacementNamed(
            context,
            targetRoute,
            arguments: {
              'userName': user.name.isNotEmpty
                  ? user.name
                  : user.email.split('@').first,
              'userId': user.id,
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
                    children: [
                      const Align(
                        alignment: Alignment.centerRight,
                        child: LanguageThemeToggles(key: ValueKey('login_toggles')),
                      ),
                      const SizedBox(height: 10),
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
                        label: AppLocalizations.of(context)!.email,
                        hint: 'you@cic-cairo.edu.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,

                      ),
                      const SizedBox(height: 16),

                      // ── Password ───────────────────────────────────────
                      AppTextField(
                        label: AppLocalizations.of(context)!.password,
                        controller: _passwordController,
                        hint: "******************",

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
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(
                                context,
                                RouteNames.forgotPassword,
                              ),
                          child: Text(
                            AppLocalizations.of(context)!.forgotPassword,
                              style: Theme
                                  .of(context)
                                  .textTheme!
                                  .bodyMedium
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),



                      // ── Sign Up button ─────────────────────────────────
                      PrimaryButton(
                        label: AppLocalizations.of(context)!.login,
                        isLoading: isLoading,
                        onTap: _onSignIn,
                      ),
                      const SizedBox(height: 16),

                      // ── Google Sign In button ──────────────────────────
                      PrimaryButton(
                        label: 'Sign in with Google',
                        icon: TImages.googleIcon,
                        onTap: isLoading
                            ? null
                            : () => context
                                .read<AuthBloc>()
                                .add(const SignUpWithGoogleEvent()),
                      ),
                      const SizedBox(height: 20),

                      // ── Divider ────────────────────────────────────────




                      // ── Sign In link ───────────────────────────────────
                      Center(
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, RouteNames.signUp),
                          child: RichText(
                            text: TextSpan(
                              text: AppLocalizations.of(context)!
                                  .dontHaveAccount,
                              style: Theme
                                  .of(context)
                                  .textTheme!
                                  .bodyMedium,

                              children: [
                                TextSpan(
                                  text: AppLocalizations.of(context)!
                                      .createAccount,
                                  style: Theme
                                      .of(context)
                                      .textTheme!
                                      .bodyMedium!
                                      .copyWith(
                                    color: const Color(0xFFE46822),
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
