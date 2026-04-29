import 'package:animate_do/animate_do.dart';
import 'package:cafeteria/core/constants/colors.dart';
import 'package:flutter/material.dart';

import '../../../../core/network/dio_handler.dart';
import '../../../../core/route/route_name.dart';

class ResetPasswordPage extends StatefulWidget {
  final Map<String, String>? arguments;
  const ResetPasswordPage({super.key, this.arguments});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _codeController;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.arguments?['email'] ?? '');
    _codeController = TextEditingController(text: widget.arguments?['code'] ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);
    try {
      await NetworkDioHandler().dio.post(
        '/auth/verify-otp-reset',
        data: {
          'email': _emailController.text.trim(),
          'code': _codeController.text.trim(),
          'newPassword': _passwordController.text,
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully!'),
          backgroundColor: TColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Navigate back to Sign In and clear stack
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.signIn,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: TColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: const Text(
                    'Create New Password',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: TColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: const Text(
                    'Your new password must be unique from those previously used.',
                    style: TextStyle(
                      fontSize: 14,
                      color: TColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Read-only email and code if provided
                if (widget.arguments != null) ...[
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: TextFormField(
                      controller: _emailController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: TColors.background,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: TextFormField(
                      controller: _codeController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Verification Code',
                        prefixIcon: const Icon(Icons.verified_user_outlined),
                        filled: true,
                        fillColor: TColors.background,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: TColors.textSecondary,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please enter a password';
                      if (v.length < 8) return 'Password must be at least 8 characters';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 700),
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscurePassword,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock_reset_outlined),
                    ),
                    validator: (v) {
                      if (v != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 40),
                FadeInUp(
                  delay: const Duration(milliseconds: 800),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _loading ? null : _reset,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Reset Password',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

