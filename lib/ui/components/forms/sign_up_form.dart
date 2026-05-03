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
          const SizedBox(height: 16),

          // ── Birth Date (optional) ─────────
          ReactiveDatePicker<DateTime>(
            formControlName: 'dateNaissance',
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            builder: (context, picker, child) {
              final value = picker.value;
              final label = value == null
                  ? 'Select birth date (optional)'
                  : '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
              return InkWell(
                onTap: picker.showPicker,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Birth Date',
                    prefixIcon: Icon(
                      Icons.calendar_today_rounded,
                      color: AppColors.secondary,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: value == null
                          ? AppColors.textMuted
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // ── Gender (optional) ─────────────
          ReactiveDropdownField<String>(
            formControlName: 'sexe',
            decoration: const InputDecoration(
              labelText: 'Gender',
              prefixIcon: Icon(Icons.wc_rounded, color: AppColors.secondary),
            ),
            items: const [
              DropdownMenuItem<String>(
                value: 'Homme',
                child: Text('Homme'),
              ),
              DropdownMenuItem<String>(
                value: 'Femme',
                child: Text('Femme'),
              ),
            ],
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
