import 'package:digital_library/ui/components/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../core/navigation/app_router.dart';
import '../../../core/utils/app_colors.dart';

class LoginForm extends StatelessWidget {
  final FormGroup form;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const LoginForm({
    super.key,
    required this.form,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return ReactiveForm(
      formGroup: form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Email ──────────────────────
          ReactiveTextField<String>(
            formControlName: 'email',
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(
                Icons.email_outlined,
                color: AppColors.secondary,
              ),
            ),
            validationMessages: {
              ValidationMessage.required: (_) => 'Email is required',
              ValidationMessage.email: (_) => 'Please enter a valid email',
            },
          ),
          const SizedBox(height: 16),

          // ── Password ───────────────────
          ReactiveTextField<String>(
            formControlName: 'password',
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(
                Icons.lock_outline,
                color: AppColors.secondary,
              ),
            ),
            validationMessages: {
              ValidationMessage.required: (_) => 'Password is required',
            },
          ),
          const SizedBox(height: 24),

          // ── Submit ─────────────────────
          ReactiveFormConsumer(
            builder: (context, form, child) => AppButton.primary(
              label: 'Login',
              expand: true,
              isLoading: isSubmitting,
              onPressed: isSubmitting ? null : onSubmit,
            ),
          ),
          const SizedBox(height: 16),

          // ── Sign up link ───────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRouter.signup),
                child: const Text('Sign up'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}