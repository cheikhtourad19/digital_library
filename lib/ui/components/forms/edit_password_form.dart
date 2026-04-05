import 'package:digital_library/ui/components/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../core/utils/app_colors.dart';

class EditPasswordForm extends StatelessWidget {
  final FormGroup form;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const EditPasswordForm({
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Change Password',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // ── Current Password ───────────
          ReactiveTextField<String>(
            formControlName: 'currentPassword',
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Current Password',
              prefixIcon: Icon(Icons.lock_outline, color: AppColors.secondary),
            ),
            validationMessages: {
              ValidationMessage.required: (_) => 'Current password is required',
            },
          ),
          const SizedBox(height: 16),

          // ── New Password ───────────────
          ReactiveTextField<String>(
            formControlName: 'newPassword',
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'New Password',
              prefixIcon: Icon(
                Icons.lock_open_outlined,
                color: AppColors.secondary,
              ),
            ),
            validationMessages: {
              ValidationMessage.required: (_) => 'New password is required',
              ValidationMessage.minLength: (_) =>
                  'Password must be at least 6 characters',
            },
          ),
          const SizedBox(height: 16),

          // ── Confirm Password ───────────
          ReactiveTextField<String>(
            formControlName: 'confirmPassword',
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirm New Password',
              prefixIcon: Icon(Icons.lock_outlined, color: AppColors.secondary),
            ),
            validationMessages: {
              ValidationMessage.required: (_) => 'Please confirm your password',
              ValidationMessage.mustMatch: (_) => 'Passwords do not match',
            },
          ),
          const SizedBox(height: 24),

          // ── Submit ─────────────────────
          ReactiveFormConsumer(
            builder: (context, form, _) => AppButton.primary(
              label: 'Update Password',
              expand: true,
              isLoading: isSubmitting,
              onPressed: isSubmitting ? null : onSubmit,
            ),
          ),
        ],
      ),
    );
  }
}
