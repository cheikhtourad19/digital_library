import 'package:flutter/material.dart';
import '../../../core/utils/app_colors.dart';

class AppModal extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget content;
  final VoidCallback? onClose;
  final List<Widget>? actions;
  final bool isDismissible;
  final double? maxWidth;
  final IconData? titleIcon;

  const AppModal({
    super.key,
    required this.title,
    required this.content,
    this.subtitle,
    this.onClose,
    this.actions,
    this.isDismissible = true,
    this.maxWidth,
    this.titleIcon = Icons.question_mark,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? 480,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──────────────────────────────────────
              _buildHeader(context),

              // ── Content ─────────────────────────────────────
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: content,
                ),
              ),

              // ── Actions footer ───────────────────────────────
              if (actions != null && actions!.isNotEmpty) _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Optional icon badge
          if (titleIcon != null) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(titleIcon, size: 18, color: AppColors.secondary),
            ),
            const SizedBox(width: 12),
          ],

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Close button
          if (isDismissible)
            GestureDetector(
              onTap: () {
                onClose?.call();
                Navigator.of(context).pop();
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: actions!
            .map(
              (action) => Padding(
                padding: const EdgeInsets.only(left: 10),
                child: action,
              ),
            )
            .toList(),
      ),
    );
  }
}

/// Helper to show modal dialog
void showAppModal({
  required BuildContext context,
  required String title,
  required Widget content,
  String? subtitle,
  VoidCallback? onClose,
  List<Widget>? actions,
  bool isDismissible = true,
  double? maxWidth,
  IconData? titleIcon,
}) {
  showDialog(
    context: context,
    barrierDismissible: isDismissible,
    barrierColor: AppColors.primary.withOpacity(0.4),
    builder: (context) => AppModal(
      title: title,
      content: content,
      subtitle: subtitle,
      onClose: onClose,
      actions: actions,
      isDismissible: isDismissible,
      maxWidth: maxWidth,
      titleIcon: titleIcon,
    ),
  );
}
