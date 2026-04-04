import 'package:flutter/material.dart';
import '../../../core/utils/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// USAGE EXAMPLES:
//
// Primary   → AppButton.primary(label: 'Login', onPressed: _handleLogin)
// Secondary → AppButton.secondary(label: 'Cancel', onPressed: _handleCancel)
// Danger    → AppButton.danger(label: 'Delete', onPressed: _handleDelete)
//
// With icon → AppButton.primary(label: 'Save', icon: Icons.save, onPressed: ...)
// Loading   → AppButton.primary(label: 'Login', isLoading: true, onPressed: ...)
// Full width → AppButton.primary(label: 'Submit', expand: true, onPressed: ...)
// Disabled  → AppButton.primary(label: 'Submit', onPressed: null)
// ─────────────────────────────────────────────────────────────────────────────

enum _AppButtonVariant { primary, secondary, danger }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expand;
  final _AppButtonVariant variant;

  const AppButton._({
    required this.label,
    required this.variant,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = false,
  });

  // ── Constructors ──────────────────────────────────────────────

  factory AppButton.primary({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool expand = false,
  }) => AppButton._(
    label: label,
    variant: _AppButtonVariant.primary,
    onPressed: onPressed,
    icon: icon,
    isLoading: isLoading,
    expand: expand,
  );

  factory AppButton.secondary({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool expand = false,
  }) => AppButton._(
    label: label,
    variant: _AppButtonVariant.secondary,
    onPressed: onPressed,
    icon: icon,
    isLoading: isLoading,
    expand: expand,
  );

  factory AppButton.danger({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool expand = false,
  }) => AppButton._(
    label: label,
    variant: _AppButtonVariant.danger,
    onPressed: onPressed,
    icon: icon,
    isLoading: isLoading,
    expand: expand,
  );

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.04,
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Styling per variant ───────────────────────────────────────

  Color get _bgColor {
    if (widget.onPressed == null && !widget.isLoading) {
      return AppColors.textMuted.withOpacity(0.15);
    }
    return switch (widget.variant) {
      _AppButtonVariant.primary => AppColors.primary,
      _AppButtonVariant.secondary => Colors.transparent,
      _AppButtonVariant.danger => AppColors.error.withOpacity(0.08),
    };
  }

  Color get _labelColor {
    if (widget.onPressed == null && !widget.isLoading) {
      return AppColors.textMuted;
    }
    return switch (widget.variant) {
      _AppButtonVariant.primary => Colors.white,
      _AppButtonVariant.secondary => AppColors.primary,
      _AppButtonVariant.danger => AppColors.error,
    };
  }

  Border? get _border => switch (widget.variant) {
    _AppButtonVariant.secondary => Border.all(
      color: AppColors.border,
      width: 1.5,
    ),
    _ => null,
  };

  List<BoxShadow>? get _shadow => switch (widget.variant) {
    _AppButtonVariant.primary => [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.25),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
    _ => null,
  };

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool disabled = widget.onPressed == null && !widget.isLoading;

    Widget button = GestureDetector(
      onTapDown: disabled ? null : (_) => _controller.forward(),
      onTapUp: disabled
          ? null
          : (_) {
              _controller.reverse();
              if (!widget.isLoading) widget.onPressed?.call();
            },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(14),
            border: _border,
            boxShadow: disabled ? null : _shadow,
          ),
          child: Row(
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading) ...[
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _labelColor,
                  ),
                ),
                const SizedBox(width: 10),
              ] else if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: _labelColor),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _labelColor,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return widget.expand
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
