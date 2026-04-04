import 'package:flutter/material.dart';
import '../../../core/utils/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Generic reusable table component
//
// USAGE:
//   AppTable<UserModel>(
//     columns: const ['Name', 'Email', 'Role', 'Status', ''],
//     rows: _users,
//     rowBuilder: (user) => [
//       AppTableCell.text(user.fullName),
//       AppTableCell.text(user.email),
//       AppTableCell.badge(user.isAdmin ? 'Admin' : 'Client',
//           color: user.isAdmin ? AppColors.accent : AppColors.secondary),
//       AppTableCell.status(user.isActive),
//       AppTableCell.action(onTap: () => _viewUser(user)),
//     ],
//     isLoading: _isLoading,
//     emptyMessage: 'No users found',
//   )
// ─────────────────────────────────────────────────────────────────────────────

// ── Cell model ────────────────────────────────────────────────────────────────

enum _CellType { text, badge, status, action, avatar }

class AppTableCell {
  final _CellType type;
  final String? text;
  final Color? badgeColor;
  final bool? isActive;
  final VoidCallback? onTap;
  final String? avatarLabel;
  final IconData? actionIcon;

  const AppTableCell._({
    required this.type,
    this.text,
    this.badgeColor,
    this.isActive,
    this.onTap,
    this.avatarLabel,
    this.actionIcon,
  });

  factory AppTableCell.text(String value) =>
      AppTableCell._(type: _CellType.text, text: value);

  factory AppTableCell.badge(String label, {Color? color}) =>
      AppTableCell._(type: _CellType.badge, text: label, badgeColor: color);

  factory AppTableCell.status(bool isActive) =>
      AppTableCell._(type: _CellType.status, isActive: isActive);

  factory AppTableCell.action({
    required VoidCallback onTap,
    IconData icon = Icons.arrow_forward_ios_rounded,
  }) => AppTableCell._(type: _CellType.action, onTap: onTap, actionIcon: icon);

  factory AppTableCell.avatar(String label, {String? subtitle}) =>
      AppTableCell._(
        type: _CellType.avatar,
        text: label,
        avatarLabel: subtitle,
      );
}

// ── Table widget ──────────────────────────────────────────────────────────────

class AppTable<T> extends StatelessWidget {
  final List<String> columns;
  final List<T> rows;
  final List<AppTableCell> Function(T item) rowBuilder;
  final bool isLoading;
  final String emptyMessage;
  final String? title;
  final Widget? trailing; // e.g. search bar or add button

  const AppTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.rowBuilder,
    this.isLoading = false,
    this.emptyMessage = 'No data found',
    this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header bar ─────────────────────────────────────
          if (title != null || trailing != null) _buildTitleBar(),

          // ── Column headers ─────────────────────────────────
          _buildColumnHeaders(),

          // ── Body ───────────────────────────────────────────
          if (isLoading)
            _buildLoader()
          else if (rows.isEmpty)
            _buildEmpty()
          else
            _buildRows(),
        ],
      ),
    );
  }

  Widget _buildTitleBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }

  Widget _buildColumnHeaders() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border)),
        borderRadius: title == null
            ? const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              )
            : null,
      ),
      child: Row(
        children: columns.map((col) {
          final isLast = col == columns.last && col.isEmpty;
          return Expanded(
            flex: isLast ? 0 : 1,
            child: isLast
                ? const SizedBox(width: 60)
                : Text(
                    col.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRows() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rows.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.border),
      itemBuilder: (context, index) {
        final cells = rowBuilder(rows[index]);
        return _TableRow(cells: cells, isEven: index.isEven);
      },
    );
  }

  Widget _buildLoader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.secondary,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, size: 36, color: AppColors.border),
          const SizedBox(height: 10),
          Text(
            emptyMessage,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ── Single row ────────────────────────────────────────────────────────────────

class _TableRow extends StatelessWidget {
  final List<AppTableCell> cells;
  final bool isEven;

  const _TableRow({required this.cells, required this.isEven});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isEven
          ? Colors.transparent
          : AppColors.background.withOpacity(0.4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: cells.map((cell) {
          final isAction = cell.type == _CellType.action;
          return Expanded(
            flex: isAction ? 0 : 1,
            child: isAction
                ? SizedBox(width: 60, child: _buildCell(cell))
                : _buildCell(cell),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCell(AppTableCell cell) {
    switch (cell.type) {
      case _CellType.text:
        return Text(
          cell.text ?? '',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        );

      case _CellType.avatar:
        return Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  (cell.text ?? '?')[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cell.text ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (cell.avatarLabel != null)
                    Text(
                      cell.avatarLabel!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        );

      case _CellType.badge:
        final color = cell.badgeColor ?? AppColors.secondary;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            cell.text ?? '',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        );

      case _CellType.status:
        final active = cell.isActive ?? false;
        return Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: active ? const Color(0xFF4CAF50) : AppColors.textMuted,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              active ? 'Active' : 'Inactive',
              style: TextStyle(
                fontSize: 12,
                color: active ? const Color(0xFF4CAF50) : AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );

      case _CellType.action:
        return GestureDetector(
          onTap: cell.onTap,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
            ),
            child: Icon(
              cell.actionIcon ?? Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.secondary,
            ),
          ),
        );
    }
  }
}
