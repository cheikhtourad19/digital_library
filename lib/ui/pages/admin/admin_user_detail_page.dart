import 'package:digital_library/core/di/injection.dart';
import 'package:digital_library/core/navigation/app_router.dart';
import 'package:digital_library/core/utils/toast_service.dart';
import 'package:digital_library/service/user_service.dart';
import 'package:digital_library/ui/components/buttons/app_button.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/app_colors.dart';
import '../../../models/user_model.dart';
import '../../components/modals/app_modal.dart';

class AdminUserDetailPage extends StatelessWidget {
  final User user;

  const AdminUserDetailPage({super.key, required this.user});

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Unknown';
    }
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

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
            _buildProfileCard(),
            const SizedBox(height: 14),
            _buildQuickFactsCard(),
            const SizedBox(height: 20),
            _buildInfoSection(),
            const SizedBox(height: 20),
            _buildActionSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Manage this account directly from this page.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 520;
              if (compact) {
                return Column(
                  children: [
                    AppButton.secondary(
                      label: 'Deactivate Account',
                      icon: Icons.person_off_rounded,
                      onPressed: () {
                        ToastService.showInfo(
                          'Deactivate action will be added soon',
                        );
                      },
                      expand: true,
                    ),
                    const SizedBox(height: 10),
                    AppButton.danger(
                      label: 'Delete User',
                      icon: Icons.delete_rounded,
                      onPressed: () => _confirmDelete(context),
                      expand: true,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: 'Deactivate Account',
                      icon: Icons.person_off_rounded,
                      onPressed: () {
                        ToastService.showInfo(
                          'Deactivate action will be added soon',
                        );
                      },
                      expand: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton.danger(
                      label: 'Delete User',
                      icon: Icons.delete_rounded,
                      onPressed: () => _confirmDelete(context),
                      expand: true,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final userService = getIt<UserService>();

    showAppModal(
      context: context,
      title: 'Confirm Deletion',
      content: Text(
        'Delete ${user.nom} permanently? This action cannot be undone.',
      ),
      actions: [
        AppButton.secondary(
          onPressed: () => Navigator.of(context).pop(),
          label: 'Cancel',
        ),
        AppButton.danger(
          onPressed: () async {
            try {
              await userService.deleteUser(user.id);
              if (!context.mounted) {
                return;
              }
              Navigator.of(context).pop();
              ToastService.showSuccess('User deleted successfully');
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRouter.admin,
                (route) => false,
                arguments: {'initialIndex': 3},
              );
            } catch (_) {
              if (!context.mounted) {
                return;
              }
              Navigator.of(context).pop();
              ToastService.showError('Failed to delete user');
            }
          },
          label: 'Delete',
          icon: Icons.delete_rounded,
        ),
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
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                user.nom[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.surface,
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
                const SizedBox(height: 6),
                Text(
                  'Member since ${_formatDate(user.dateCreation)}',
                  style: const TextStyle(
                    fontSize: 12,
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

  Widget _buildQuickFactsCard() {
    final historyCount = user.historiqueRecherche?.length ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FactTile(
              icon: Icons.history_rounded,
              label: 'Search History',
              value: '$historyCount entries',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _FactTile(
              icon: Icons.verified_user_rounded,
              label: 'Account Type',
              value: user.isAdmin ? 'Administrator' : 'Client',
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
          const Divider(height: 1, color: AppColors.border),
          _buildInfoRow('User ID', user.id),
          const Divider(height: 1, color: AppColors.border),
          _buildInfoRow('Full Name', user.nom),
          const Divider(height: 1, color: AppColors.border),
          _buildInfoRow('Email', user.email),
          const Divider(height: 1, color: AppColors.border),
          _buildInfoRow('Role', user.isAdmin ? 'Administrator' : 'Client'),
          const Divider(height: 1, color: AppColors.border),
          _buildInfoRow('Status', 'Active'),
          const Divider(height: 1, color: AppColors.border),
          _buildInfoRow('Created On', _formatDate(user.dateCreation)),
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

class _FactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _FactTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.secondary),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
