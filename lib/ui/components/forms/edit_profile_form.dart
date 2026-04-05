import 'package:digital_library/ui/components/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../core/utils/app_colors.dart';

class EditProfileForm extends StatelessWidget {
  final FormGroup form;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const EditProfileForm({
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
            'Personal Information',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // ── Full Name ──────────────────
          ReactiveTextField<String>(
            formControlName: 'fullName',
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline, color: AppColors.secondary),
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
              prefixIcon: Icon(Icons.email_outlined, color: AppColors.secondary),
            ),
            validationMessages: {
              ValidationMessage.required: (_) => 'Email is required',
              ValidationMessage.email: (_) => 'Please enter a valid email',
            },
          ),
          const SizedBox(height: 24),

          // ── Submit ─────────────────────
          ReactiveFormConsumer(
            builder: (context, form, _) => AppButton.primary(
              label: 'Save Changes',
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