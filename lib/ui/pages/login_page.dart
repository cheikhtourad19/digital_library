import 'package:digital_library/core/di/injection.dart';
import 'package:digital_library/ui/components/buttons/app_button.dart';
import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/toast_service.dart';
import '../../service/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = getIt<AuthService>();

  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final result = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      ToastService.showSuccess('Welcome back!');

      
      Navigator.of(context).pushReplacementNamed(
        result.user.isAdmin ? AppRouter.admin : AppRouter.client,
      );
    } catch (e) {
      if (!mounted) return;
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      ToastService.showError(errorMsg);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildLogo() {
    return Container(
      width: 108,
      height: 108,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: ClipOval(
        child: Image.asset(
          'assets/images/app_logo.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.library_books,
            size: 46,
            color: AppColors.surface,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLogo(),
                          const SizedBox(height: 20),
                          Text(
                            'Digital Library',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Login to your account',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 28),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // ── Email ──────────────────────
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Email is required';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // ── Password ───────────────────
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(
                                      Icons.lock_outline,
                                      color: AppColors.secondary,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: AppColors.textMuted,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                    ),
                                  ),
                                  validator: (value) =>
                                      (value == null || value.isEmpty)
                                      ? 'Password is required'
                                      : null,
                                ),
                                const SizedBox(height: 24),

                                // ── Submit ─────────────────────
                                AppButton.primary(
                                  label: 'Login',
                                  expand: true,
                                  isLoading: _isSubmitting,
                                  onPressed: _isSubmitting
                                      ? null
                                      : _onLoginPressed,
                                ),
                                const SizedBox(height: 16),

                                // ── Sign up link ───────────────
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(
                                        context,
                                      ).pushNamed(AppRouter.signup),
                                      child: const Text('Sign up'),
                                    ),
                                  ],
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
            ),
          ),
        ),
      ),
    );
  }
}
