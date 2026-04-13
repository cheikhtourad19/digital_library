import 'package:digital_library/core/di/injection.dart';
import 'package:digital_library/core/utils/app_colors.dart';
import 'package:digital_library/core/utils/toast_service.dart';
import 'package:digital_library/models/user_model.dart';
import 'package:digital_library/service/auth_api_service.dart';
import 'package:digital_library/service/auth_service.dart';
import 'package:digital_library/service/user_service.dart';
import 'package:digital_library/ui/components/forms/edit_password_form.dart';
import 'package:digital_library/ui/components/forms/edit_profile_form.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _userService = getIt<UserService>();
  final _authService = getIt<AuthApiService>();
  final _authService2 = getIt<AuthService>();
  bool _isSubmittingProfile = false;
  bool _isSubmittingPassword = false;

  final _profileForm = FormGroup({
    'fullName': FormControl<String>(validators: [Validators.required]),
    'email': FormControl<String>(
      validators: [Validators.required, Validators.email],
    ),
  });

  final _passwordForm = FormGroup(
    {
      'currentPassword': FormControl<String>(validators: [Validators.required]),
      'newPassword': FormControl<String>(
        validators: [Validators.required, Validators.minLength(6)],
      ),
      'confirmPassword': FormControl<String>(validators: [Validators.required]),
    },
    validators: [Validators.mustMatch('newPassword', 'confirmPassword')],
  );

  // ── Helpers ──────────────────────────────────────────────────────────────

  FormControl<T> _control<T>(FormGroup form, String name) =>
      form.control(name) as FormControl<T>;

  // ── Handlers ─────────────────────────────────────────────────────────────
  Future<void> _loadUserInfo() async {
    try {
      final data = await _userService.fetchCurrentUser();
      _control<String>(_profileForm, 'fullName').value = data.user?['nom'];
      _control<String>(_profileForm, 'email').value = data.user?['email'];
    } catch (e) {
      debugPrint("Error loading user info: $e");
      if (!mounted) return;
      ToastService.showError('Failed to load profile information');
    }
  }

  Future<void> _onSaveProfile() async {
    if (_profileForm.invalid) {
      _profileForm.markAllAsTouched();
      return;
    }

    setState(() => _isSubmittingProfile = true);

    try {
      final result = await _userService.editInfo(
        nom: _control<String>(_profileForm, 'fullName').value?.trim(),
        email: _control<String>(_profileForm, 'email').value?.trim(),
      );
      if(result.user !=null){
        User updatedUser = User.fromJson(result.user!);
      await _authService2.updateSession(updatedUser);
      }
      

      if (!mounted) return;
      ToastService.showSuccess(result.message);
    } catch (e) {
      if (!mounted) return;
      ToastService.showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSubmittingProfile = false);
    }
  }

  Future<void> _onUpdatePassword() async {
    if (_passwordForm.invalid) {
      _passwordForm.markAllAsTouched();
      return;
    }

    setState(() => _isSubmittingPassword = true);

    try {
      final result = await _authService.editPassword(
        currentPassword: _control<String>(
          _passwordForm,
          'currentPassword',
        ).value!,
        newPassword: _control<String>(_passwordForm, 'newPassword').value!,
      );

      if (!mounted) return;
      ToastService.showSuccess(result.message);
      _passwordForm.reset();
    } catch (e) {
      if (!mounted) return;
      ToastService.showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSubmittingPassword = false);
    }
  }

  // ── Dispose ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _profileForm.dispose();
    _passwordForm.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.background,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // ── Avatar ───────────────────────
                      _buildAvatar(context),
                      const SizedBox(height: 28),

                      // ── Edit Profile Card ────────────
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: EditProfileForm(
                            form: _profileForm,
                            isSubmitting: _isSubmittingProfile,
                            onSubmit: _onSaveProfile,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Edit Password Card ───────────
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: EditPasswordForm(
                            form: _passwordForm,
                            isSubmitting: _isSubmittingPassword,
                            onSubmit: _onUpdatePassword,
                          ),
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
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
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
          child: const Icon(Icons.person, size: 48, color: AppColors.surface),
        ),
        const SizedBox(height: 12),
        Text(
          'My Profile',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage your account settings',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}
