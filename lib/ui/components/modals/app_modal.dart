import 'package:flutter/material.dart';

class AppModal extends StatelessWidget {
  final String title;
  final Widget content;
  final VoidCallback? onClose;
  final List<Widget>? actions;
  final bool isDismissible;
  final double? maxWidth;

  const AppModal({
    super.key,
    required this.title,
    required this.content,
    this.onClose,
    this.actions,
    this.isDismissible = true,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? 500,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isDismissible)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        onClose?.call();
                        Navigator.of(context).pop();
                      },
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: content,
                ),
              ),
            ),
            // Actions footer
            if (actions != null && actions!.isNotEmpty) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ...actions!.map(
                      (action) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: action,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Helper to show modal dialog
void showAppModal({
  required BuildContext context,
  required String title,
  required Widget content,
  VoidCallback? onClose,
  List<Widget>? actions,
  bool isDismissible = true,
  double? maxWidth,
}) {
  showDialog(
    context: context,
    barrierDismissible: isDismissible,
    builder: (context) => AppModal(
      title: title,
      content: content,
      onClose: onClose,
      actions: actions,
      isDismissible: isDismissible,
      maxWidth: maxWidth,
    ),
  );
}
