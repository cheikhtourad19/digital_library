import 'package:digital_library/core/di/injection.dart';
import 'package:digital_library/core/navigation/app_router.dart';
import 'package:digital_library/core/utils/app_colors.dart';
import 'package:digital_library/models/user_model.dart';
import 'package:digital_library/service/auth_service.dart';
import 'package:flutter/material.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  AuthService get _authService => getIt<AuthService>();
  late User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
      debugPrint('Error loading user: $e');
    }
  }

  void _openAdminSection(BuildContext context, int index) {
    Navigator.of(
      context,
    ).pushReplacementNamed(AppRouter.admin, arguments: {'initialIndex': index});
  }

  @override
  Widget build(BuildContext context) {
    final shortcuts = <_AdminShortcutData>[
      _AdminShortcutData(
        title: 'Analytics',
        subtitle: 'Track sales, users, and growth trends',
        icon: Icons.analytics_rounded,
        pageIndex: 1,
      ),
      _AdminShortcutData(
        title: 'Books',
        subtitle: 'Create, edit, and organize your catalog',
        icon: Icons.library_books_rounded,
        pageIndex: 2,
      ),
      _AdminShortcutData(
        title: 'Users',
        subtitle: 'Review accounts and user activity',
        icon: Icons.group_rounded,
        pageIndex: 3,
      ),
      _AdminShortcutData(
        title: 'Profile',
        subtitle: 'Update your information and preferences',
        icon: Icons.manage_accounts_rounded,
        pageIndex: 4,
      ),
    ];

    return Container(
      color: AppColors.background,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              children: [
                _buildWelcomeCard(context),
                const SizedBox(height: 14),
                const Text(
                  'Quick Shortcuts',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                _buildShortcutGrid(context, shortcuts),
                const SizedBox(height: 14),
                _buildTutorialCard(),
              ],
            ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome ${_currentUser?.nom ?? 'Admin'}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.surface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This is your control center. Use shortcuts below to jump quickly between analytics, books, users, and your profile.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w500,
              color: AppColors.surface,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => _openAdminSection(context, 1),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.surface,
              side: const BorderSide(color: AppColors.surface),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            icon: const Icon(Icons.insights_rounded),
            label: const Text('Open Analytics'),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutGrid(
    BuildContext context,
    List<_AdminShortcutData> shortcuts,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width > 920
            ? 4
            : width > 700
            ? 2
            : 1;
        const spacing = 10.0;
        final cardWidth = (width - ((columns - 1) * spacing)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: shortcuts
              .map(
                (shortcut) => SizedBox(
                  width: cardWidth,
                  child: _ShortcutCard(
                    data: shortcut,
                    onTap: () => _openAdminSection(context, shortcut.pageIndex),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildTutorialCard() {
    const steps = <String>[
      'Start with Analytics to check revenue, users, and trends.',
      'Open Books to add new titles and verify uploaded files.',
      'Review Users and deactivate suspicious accounts if needed.',
      'Keep your Profile updated before ending your session.',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.school_rounded, color: AppColors.secondary),
              SizedBox(width: 8),
              Text(
                'Getting Started Tutorial',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...List.generate(
            steps.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      steps[index],
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  final _AdminShortcutData data;
  final VoidCallback onTap;

  const _ShortcutCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(data.icon, color: AppColors.secondary),
            ),
            const SizedBox(height: 10),
            Text(
              data.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.subtitle,
              style: const TextStyle(
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Open',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
                SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminShortcutData {
  final String title;
  final String subtitle;
  final IconData icon;
  final int pageIndex;

  const _AdminShortcutData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.pageIndex,
  });
}
