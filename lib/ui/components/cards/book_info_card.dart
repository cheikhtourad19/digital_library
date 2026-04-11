import 'package:digital_library/core/utils/app_colors.dart';
import 'package:digital_library/models/livre_model.dart';
import 'package:flutter/material.dart';

class BookInfoCard extends StatelessWidget {
  final Livre livre;
  final bool showDescription;

  const BookInfoCard({
    super.key,
    required this.livre,
    this.showDescription = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCover(),
                Expanded(child: _buildInfo()),
              ],
            ),
          ),
          if (showDescription) ...[
            Divider(height: 1, thickness: 0.5, color: AppColors.border),
            _buildDescription(),
          ],
        ],
      ),
    );
  }

  Widget _buildCover() {
    final imageUrl = livre.couvertureUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return SizedBox(
      width: 110,
      child: hasImage
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _coverPlaceholder(),
            )
          : _coverPlaceholder(),
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      color: AppColors.background,
      alignment: Alignment.center,
      child: const Icon(
        Icons.menu_book_rounded,
        size: 32,
        color: AppColors.textMuted,
      ),
    );
  }

  Widget _buildInfo() {
    final catNom = livre.categorieObj?.nom;
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (catNom != null) ...[
            _CategoryBadge(label: catNom),
            const SizedBox(height: 8),
          ],
          Text(
            livre.titre,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            livre.auteur.join(', '),
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          Text(
            '${livre.prix.toStringAsFixed(2)} TND',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _buildMetaGrid(),
        ],
      ),
    );
  }

  Widget _buildMetaGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _MetaCell(label: 'Pages', value: '${livre.nombrePages}'),
            const SizedBox(width: 16),
            _MetaCell(label: 'Langue', value: livre.langue.toUpperCase()),
          ],
        ),
        const SizedBox(height: 8),
        _StarRating(note: livre.noteMoyenne, nombreAvis: livre.nombreAvis),
      ],
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DESCRIPTION',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            livre.description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  final String label;
  const _CategoryBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _MetaCell extends StatelessWidget {
  final String label;
  final String value;
  const _MetaCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textMuted,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _StarRating extends StatelessWidget {
  final double note;
  final int nombreAvis;
  const _StarRating({required this.note, required this.nombreAvis});

  @override
  Widget build(BuildContext context) {
    const filled = Color(0xFFE4A435);
    const empty = AppColors.border;
    final fullStars = note.floor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'NOTE',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textMuted,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            ...List.generate(
              5,
              (i) => Icon(
                Icons.star_rounded,
                size: 14,
                color: i < fullStars ? filled : empty,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              note.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '($nombreAvis avis)',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ],
    );
  }
}
