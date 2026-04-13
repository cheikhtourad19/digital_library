import 'package:digital_library/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../core/navigation/app_router.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/toast_service.dart';
import '../../service/auth_service.dart';
import '../components/forms/login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authService = getIt<AuthService>();
  bool _isSubmitting = false;

  final _form = FormGroup({
    'email': FormControl<String>(
      validators: [Validators.required, Validators.email],
    ),
    'password': FormControl<String>(validators: [Validators.required]),
  });

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    if (_form.invalid) {
      _form.markAllAsTouched();
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await _authService.login(
        email: (_form.control('email') as FormControl<String>).value!.trim(),
        password: (_form.control('password') as FormControl<String>).value!,
      );

      if (!mounted) return;
      ToastService.showSuccess('Welcome back!');

      Navigator.of(context).pushReplacementNamed(
        result.user.isAdmin ? AppRouter.admin : AppRouter.client,
      );
    } catch (e) {
      if (!mounted) return;
      ToastService.showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildLogo() {
    return Container(
      width: 108,
      height: 108,
      decoration: BoxDecoration(
        color: AppColors.primary,
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
        color: AppColors.background,
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
                          LoginForm(
                            form: _form,
                            isSubmitting: _isSubmitting,
                            onSubmit: _onLoginPressed,
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
