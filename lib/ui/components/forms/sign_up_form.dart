import 'package:digital_library/ui/components/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../core/navigation/app_router.dart';
import '../../../core/utils/app_colors.dart';

class SignUpForm extends StatelessWidget {
  final FormGroup form;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const SignUpForm({
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
          // ── Full Name ──────────────────
          ReactiveTextField<String>(
            formControlName: 'fullName',
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person, color: AppColors.secondary),
            ),
            validationMessages: {
              ValidationMessage.required: (_) => 'Name is required',
            },
          ),
          const SizedBox(height: 16),

          // ── Email ──────────────────────
          ReactiveTextField<String>(
            formControlName: 'email',
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email, color: AppColors.secondary),
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
              prefixIcon: Icon(Icons.lock, color: AppColors.secondary),
            ),
            validationMessages: {
              ValidationMessage.required: (_) => 'Password is required',
              ValidationMessage.minLength: (_) =>
                  'Password must be at least 6 characters',
            },
          ),
          const SizedBox(height: 24),

          // ── Submit ─────────────────────
          ReactiveFormConsumer(
            builder: (context, form, child) => AppButton.secondary(
              label: 'Sign Up',
              expand: true,
              isLoading: isSubmitting,
              onPressed: isSubmitting ? null : onSubmit,
            ),
          ),
          const SizedBox(height: 16),

          // ── Login link ─────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).popAndPushNamed(AppRouter.login),
                child: const Text('Login'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
