import 'package:digital_library/ui/components/buttons/app_button.dart';
import 'package:flutter/material.dart';
import '../../../core/di/injection.dart';
import '../../../core/utils/app_colors.dart';
import '../../../models/menu_model.dart';
import '../../../models/user_model.dart';
import '../../../service/auth_service.dart';
import '../modals/app_modal.dart';

class AppSidebar extends StatefulWidget {
  final List<MenuSection> menus;
  final int selectedIndex;
  final ValueChanged<int> onMenuTap;
  final VoidCallback onLogout;
  final VoidCallback? onMenuItemSelected;

  const AppSidebar({
    super.key,
    required this.menus,
    required this.selectedIndex,
    required this.onMenuTap,
    required this.onLogout,
    this.onMenuItemSelected,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final _authService = getIt<AuthService>();
  User? _currentUser;
  UserRole? _userRole;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUser();
    final role = await _authService.getUserRole();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _userRole = role;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _showLogoutConfirmation() {
    showAppModal(
      context: context,
      title: 'Confirm Logout',
      content: const Text('Are you sure you want to log out?'),
      actions: [
        AppButton.secondary(
          onPressed: () => Navigator.of(context).pop(),
          label: 'Cancel',
        ),
        AppButton.danger(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onLogout();
          },
          label: 'Logout',
          icon: Icons.logout,
        ),
      ],
    );
  }

  void _onMenuItemTapped(MenuItem item) {
    if (item.isLogout) {
      _showLogoutConfirmation();
      return;
    }
    if (item.pageIndex != null) {
      widget.onMenuTap(item.pageIndex!);
      widget.onMenuItemSelected?.call();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: widget.menus
                  .expand(
                    (section) => [
                      if (_isExpanded) _buildSectionLabel(section.title),
                      ...section.items.map((item) => _buildMenuItem(item)),
                      const SizedBox(height: 4),
                    ],
                  )
                  .toList(),
            ),
          ),
          Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final roleLabel = _userRole == UserRole.admin ? 'Administrator' : 'Client';
    final roleColor = _userRole == UserRole.admin
        ? Colors.amber.shade300
        : Colors.lightBlue.shade200;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 52, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(topRight: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo row ───────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              if (_isExpanded)
                FadeTransition(
                  opacity: _fadeAnim,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Digital Library',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        'Your reading space',
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          if (_isExpanded) ...[
            const SizedBox(height: 20),

            // ── Divider ────────────────────────────────────────
            Divider(color: Colors.white.withOpacity(0.15), height: 1),
            const SizedBox(height: 16),

            // ── User info ──────────────────────────────────────
            FadeTransition(
              opacity: _fadeAnim,
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _currentUser?.nom.isNotEmpty == true
                            ? _currentUser!.nom[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Email + Role
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentUser?.email ?? '—',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: roleColor.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: roleColor.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            roleLabel,
                            style: TextStyle(
                              color: roleColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 6),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    final bool isSelected =
        item.pageIndex != null && widget.selectedIndex == item.pageIndex;
    final bool isLogout = item.isLogout;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.secondary.withOpacity(0.15)
                  : isLogout
                  ? AppColors.error.withOpacity(0.08)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              item.icon,
              size: 18,
              color: isSelected
                  ? AppColors.secondary
                  : isLogout
                  ? AppColors.error
                  : AppColors.textMuted,
            ),
          ),
          title: _isExpanded
              ? FadeTransition(
                  opacity: _fadeAnim,
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.secondary
                          : isLogout
                          ? AppColors.error
                          : AppColors.textPrimary,
                    ),
                  ),
                )
              : null,
          trailing: isSelected && _isExpanded
              ? Container(
                  width: 3,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                )
              : null,
          onTap: () => _onMenuItemTapped(item),
        ),
      ),
    );
  }
}
