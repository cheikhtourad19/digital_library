import 'package:digital_library/core/di/injection.dart';
import 'package:digital_library/core/navigation/app_router.dart';
import 'package:digital_library/service/user_service.dart';
import 'package:digital_library/ui/components/buttons/app_button.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/app_colors.dart';
import '../../../models/user_model.dart';
import '../../components/modals/app_modal.dart';

class AdminUserDetailPage extends StatelessWidget {
  final User user;

  const AdminUserDetailPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        title: const Text(
          'User Detail',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile card ─────────────────────────────────
            _buildProfileCard(),
            const SizedBox(height: 20),

            // ── Info section ─────────────────────────────────
            _buildInfoSection(),
            const SizedBox(height: 20),
            _buildActionButtonsRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonsRow(BuildContext context) {
    return Row(
      children: [
        AppButton.danger(
          label: "delete",
          onPressed: () {
            final _userService = getIt<UserService>();
            showAppModal(
              context: context,
              title: 'Confirm deletion',
              content: const Text('Are you sure you want to delete this user?'),
              actions: [
                AppButton.secondary(
                  onPressed: () => Navigator.of(context).pop(),
                  label: 'Cancel',
                ),
                AppButton.danger(
                  onPressed: () async {
                    await _userService.deleteUser(this.user.id);
                    Navigator.of(context).pop(); // close modal
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRouter.admin,
                      (route) => false, // removes everything
                      arguments: {'initialIndex': 3},
                    );
                  },
                  label: 'delete',
                  icon: Icons.delete,
                ),
              ],
            );
          },
        ),
        AppButton.secondary(label: "deactivate account ", onPressed: () {}),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                user.nom[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nom,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (user.isAdmin ? AppColors.accent : AppColors.secondary)
                            .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          (user.isAdmin
                                  ? AppColors.accent
                                  : AppColors.secondary)
                              .withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    user.isAdmin ? 'Admin' : 'Client',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: user.isAdmin
                          ? AppColors.accent
                          : AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              'ACCOUNT INFO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Divider(height: 1, color: AppColors.border),
          _buildInfoRow('User ID', user.id),
          Divider(height: 1, color: AppColors.border),
          _buildInfoRow('Full Name', user.nom),
          Divider(height: 1, color: AppColors.border),
          _buildInfoRow('Email', user.email),
          Divider(height: 1, color: AppColors.border),
          _buildInfoRow('Role', user.isAdmin ? 'Administrator' : 'Client'),
          Divider(height: 1, color: AppColors.border),
          _buildInfoRow('Status', 'Active'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
