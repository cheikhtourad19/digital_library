import 'package:digital_library/core/navigation/app_router.dart';
import 'package:digital_library/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/app_colors.dart';

class LibraryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isAdmin;
  final VoidCallback? onCartTap;

  const LibraryAppBar({
    super.key,
    required this.title,
    required this.isAdmin,
    this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: kToolbarHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Hamburger (drawer toggle) ──────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: Builder(
                  builder: (context) => IconButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const _AnimatedMenuIcon(),
                    tooltip: 'Menu',
                  ),
                ),
              ),

              // ── Centered Title ─────────────────────────────
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_stories_rounded,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.surface,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),

              // ── Right Actions ──────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: isAdmin
                    ? _AdminBadge()
                    : Builder(
                        builder: (context) {
                          // Watch cart count for badge reactivity
                          final cartCount = context
                              .watch<CartProvider>()
                              .totalCount;
                          return _CartIconButton(
                            count: cartCount,
                            onTap:
                                onCartTap ??
                                () => Navigator.of(
                                  context,
                                ).pushNamed(AppRouter.clientCartPage),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 0);
}

// ── Cart icon with animated badge ─────────────────────────────
class _CartIconButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _CartIconButton({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            onPressed: onTap,
            tooltip: 'Cart',
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: AppColors.surface,
            ),
          ),
          if (count > 0)
            Positioned(
              top: 4,
              right: 4,
              child: IgnorePointer(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Container(
                    key: ValueKey(count),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Admin role badge ───────────────────────────────────────────
class _AdminBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withOpacity(0.6)),
      ),
      child: const Text(
        'ADMIN',
        style: TextStyle(
          color: AppColors.accent,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Subtle animated menu icon ──────────────────────────────────
class _AnimatedMenuIcon extends StatelessWidget {
  const _AnimatedMenuIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.menu_rounded, color: AppColors.surface, size: 26);
  }
}
